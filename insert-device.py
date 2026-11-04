#!/usr/bin/env python3
# Insert the oray_x1-pro device definition into filogic.mk (idempotent)
import sys
path = "target/linux/mediatek/image/filogic.mk"
block = '''define Device/oray_x1-pro
  DEVICE_VENDOR := Oray
  DEVICE_MODEL := X1 Pro
  DEVICE_DTS := mt7981b-oray-x1-pro
  DEVICE_DTS_DIR := ../dts
  SUPPORTED_DEVICES += oray,x1-pro
  SUPPORTED_DEVICES += cudy,tr3000-v1
  UBINIZE_OPTS := -E 5
  BLOCKSIZE := 128k
  PAGESIZE := 2048
  IMAGE_SIZE := 114688k
  KERNEL_IN_UBI := 1
  IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
  DEVICE_PACKAGES := kmod-usb3 kmod-mt7915e kmod-mt7981-firmware mt7981-wo-firmware automount
endef
TARGET_DEVICES += oray_x1-pro

'''
s = open(path, encoding="utf-8").read()
if "Device/oray_x1-pro" in s:
    print("already inserted"); sys.exit(0)
anchor = "define Device/cudy_wr3000-v1"
if anchor not in s:
    print("ERROR: anchor not found"); sys.exit(1)
s = s.replace(anchor, block + anchor, 1)
open(path, "w", encoding="utf-8").write(s)
print("device oray_x1-pro inserted into filogic.mk")
