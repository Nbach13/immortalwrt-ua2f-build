# WSL2 本地编译步骤(管理员 + 重启一次)

1. 管理员 PowerShell 执行:
   wsl --install -d Ubuntu-24.04
   完成后重启电脑,再打开 Ubuntu 创建用户。

2. Ubuntu 内装依赖:
   sudo apt update && sudo apt install -y build-essential clang flex bison gawk gettext git libssl-dev python3 unzip rsync swig file wget squashfs-tools

3. 把本工程放到 WSL(如 ~/immortalwrt-ua2f-build),执行:
   cd ~/immortalwrt-ua2f-build && chmod +x build.sh
   STOCK_BIN="/mnt/c/Users/nb306/Desktop/im主线6.18内核/immortalwrt-mediatek-filogic-oray_x1-pro-squashfs-sysupgrade260913 (1).bin" bash build.sh

4. 完成后 ls -la artifacts/,把 .bin 拷回 Windows 桌面即可刷机。
