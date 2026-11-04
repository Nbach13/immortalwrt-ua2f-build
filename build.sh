#!/usr/bin/env bash
# Build ImmortalWrt (mediatek/filogic) + UA2F for the Oray X1 Pro (oray_x1-pro).
set -euo pipefail
cd "$(dirname "$0")"
ROOT="$PWD"
JOBS="$(nproc)"
export FORCE_UNSAFE_CONFIGURE=1

STOCK_BIN="${STOCK_BIN:-$ROOT/stock/stock.bin}"

echo "== [1/7] obtaining ImmortalWrt source (master) =="
if [ ! -d src/.git ]; then
  git init -q src
  cd src
  git remote add origin https://github.com/immortalwrt/immortalwrt.git
  git fetch -q --depth 1 origin master
  git checkout -q --detach FETCH_HEAD
  cd "$ROOT"
fi
cd src
echo "Using immortalwrt master @ $(git rev-parse HEAD)"

echo "== [2/7] applying device + kernel patches =="
cp -f ../overlay/target/linux/mediatek/dts/*.dts target/linux/mediatek/dts/
python3 ../insert-device.py
GCFG="$(ls target/linux/generic/config-6.* 2>/dev/null | head -1)"
if [ -n "$GCFG" ] && ! grep -q NETFILTER_NETLINK_GLUE_CT "$GCFG"; then
  echo "CONFIG_NETFILTER_NETLINK_GLUE_CT=y" >> "$GCFG"
  echo "appended CONFIG_NETFILTER_NETLINK_GLUE_CT=y to $GCFG"
fi

echo "== [3/7] adding UA2F package (Zxilly/UA2F) =="
rm -rf package/UA2F
git clone -q --depth 1 https://github.com/Zxilly/UA2F.git package/UA2F

echo "== [4/7] feeds =="
./scripts/feeds update -a >/dev/null
./scripts/feeds install -a >/dev/null

echo "== [5/7] generating .config =="
cp ../config/ua2f.seed .config
rm -f ../.config.part
if [ -f "$STOCK_BIN" ]; then
  echo "  extracting stock firmware package list from $STOCK_BIN"
  rm -rf ../stock-work && mkdir -p ../stock-work && cd ../stock-work
  if tar -xf "$STOCK_BIN" && [ -f sysupgrade-oray_x1-pro/root ] && unsquashfs -q -d root sysupgrade-oray_x1-pro/root 2>/dev/null; then
    if [ -f root/usr/lib/opkg/status ]; then
      python3 ../gen-config.py root/usr/lib/opkg/status > ../.config.part || echo "  WARN: gen-config failed"
      echo "  package parity lines: $(wc -l < ../.config.part)"
    fi
  else
    echo "  WARN: could not extract stock rootfs; using seed config only"
  fi
  cd "$ROOT"
fi
# robust: return to the source tree regardless of where we are
cd "$ROOT/src"
if [ -f ../.config.part ]; then
  cat ../.config.part >> .config
elif [ -f ../config/status.txt ]; then
  echo "  using pre-extracted stock package list (config/status.txt)"
  python3 ../gen-config.py ../config/status.txt > ../.config.part || echo "  WARN: gen-config failed"
  cat ../.config.part >> .config
fi
make defconfig >/dev/null
grep -q "CONFIG_TARGET_mediatek_filogic_DEVICE_oray_x1-pro=y" .config || { echo "ERROR: device oray_x1-pro not in .config"; exit 1; }
echo "device enabled in .config"

echo "== [6/7] building (this takes 2-5 h) =="
make -j"$JOBS" V=s 2>&1 | tee ../build.log | tail -n 200

echo "== [7/7] collecting output =="
cd "$ROOT"
mkdir -p artifacts
cp -v src/bin/targets/mediatek/filogic/*oray_x1-pro* artifacts/ 2>/dev/null || true
cp -v src/bin/targets/mediatek/filogic/sha256sums artifacts/ 2>/dev/null || true
pkgbin="$(find src/bin/packages -name "ua2f_*.ipk" 2>/dev/null | head -1)"
if [ -n "$pkgbin" ]; then cp -v "$pkgbin" artifacts/; fi
gzip -9 -c build.log > build.log.gz 2>/dev/null || true
echo "DONE. artifacts:"
ls -la artifacts/
