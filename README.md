# ImmortalWrt + UA2F 固件编译工程(蒲公英 X1 Pro / oray_x1-pro)

为 Oray X1 Pro(蒲公英 X1 Pro)路由器编译内置 UA2F 的 ImmortalWrt 固件
(mediatek/filogic, MT7981, SPI-NAND/UBI, 内核 6.18),产出可直接在 LuCI「系统→备份/升级」
刷入的 sysupgrade 镜像,格式与原厂同源 ImmortalWrt SNAPSHOT 一致。

## 设备与版本依据

- 原固件: immortalwrt-mediatek-filogic-oray_x1-pro-squashfs-sysupgrade260913 (1).bin
  - 版本 ImmortalWrt SNAPSHOT (r0-3e24625),内核 6.18.44,target=mediatek/filogic,board=oray_x1-pro
- 硬件: MT7981 (Filogic 820) / aarch64_cortex-a53;SPI-NAND 分区
  bl2/u-boot-env/Factory/fip/bdinfo/kpanic/ubi;与 Cudy TR3000 v1 同平台
  (设备树兼容串同时含 oray,x1-pro 与 cudy,tr3000-v1)。
- 设备树 mt7981b-oray-x1-pro.dts 直接取自原固件(stock/oray_x1-pro.dtb),闪存布局、网口、
  指示灯、按键、WiFi(MT7981 wmac/mt7915e)与原系统完全一致。
- UA2F 来源: https://github.com/Zxilly/UA2F (原作者仓库已删,使用活跃维护分支)。
- 内核额外开启 CONFIG_NETFILTER_NETLINK_GLUE_CT=y(UA2F connmark 需要),并包含
  kmod-nft-queue / kmod-nft-tproxy / kmod-ipt-nfqueue / iptables-mod-nfqueue 等配套。

## 产物

编译成功后 artifacts/ 下:

- immortalwrt-mediatek-filogic-oray_x1-pro-squashfs-sysupgrade.bin(主产物,完整系统镜像)
- ua2f_*.ipk(可选安装包,aarch64_cortex-a53)
- sha256sums(校验和)

## 方式一: GitHub Actions 云编译(推荐,无需本地 Linux)

1. 准备 GitHub 账号与令牌 PAT(repo + workflow 权限,仓库建议 private)。
2. 把本目录内容推到该仓库(含 stock/stock.bin 和 .github/workflows/build.yml)。
3. 推送即自动触发编译(或 Actions 页手动 Run workflow),约 2~5 小时。
4. 完成后在 Actions 页面下载工件 immortalwrt-ua2f-oray_x1-pro。

## 方式二: 本机 WSL2 / 任意 Ubuntu 机器编译

1. Ubuntu/WSL(>=20.04,>=8GB 内存,>=15GB 空闲磁盘)安装依赖:
   sudo apt install -y build-essential clang flex bison gawk gettext git libssl-dev python3 unzip rsync swig file wget squashfs-tools
2. 进入本目录执行:
   chmod +x build.sh && bash build.sh
   (可用环境变量 STOCK_BIN 指向原固件 .bin 路径)
3. 完成后取 artifacts/ 下的固件。

> WSL2 安装提示(需管理员并重启一次): 管理员 PowerShell 运行 wsl --install -d Ubuntu-24.04,重启后初始化,再按上执行。

## 刷机与 UA2F 使用

- 刷机: LuCI → 系统 → 备份/升级 → 选择 ...sysupgrade.bin(升级时按需选择是否保留配置)。
- 启用 UA2F(默认未启用):
  uci set ua2f.enabled.enabled=1
  uci commit ua2f
  service ua2f enable
  service ua2f start
- 日志: logread | grep UA2F
- 可选自定义 UA/模式:
  uci set ua2f.main.custom_ua="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
  uci set ua2f.main.mode=NFQUEUE   # 或 REDIRECT/TPROXY
  uci commit ua2f && service ua2f restart

## 常见问题

- 不触碰 bl2/fip(U-Boot),仅重刷 kernel+rootfs,与官方 sysupgrade 同机制。
- 编译失败: 看 Actions 日志或 build.log;常见原因是网络/磁盘/feed 差异,重跑即可。
- 需要更多插件: 在 config/ua2f.seed 增加对应 CONFIG_PACKAGE_* 后重新编译,或刷好后 opkg 安装。
