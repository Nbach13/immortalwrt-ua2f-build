#!/usr/bin/env python3
# Read an OpenWrt opkg status file, emit CONFIG_PACKAGE_* lines for all packages.
import sys
status_path = sys.argv[1] if len(sys.argv) > 1 else "status"
pkgs, pkg = [], None
for line in open(status_path, encoding="utf-8", errors="replace"):
    line = line.strip()
    if line.startswith("Package: "):
        pkg = line.split(None, 1)[1].strip()
    elif line == "":
        if pkg: pkgs.append(pkg)
        pkg = None
if pkg: pkgs.append(pkg)
skip = {"kernel", "libc", "libgcc", "base-files"}
seen = set()
for p in sorted(set(pkgs)):
    if p in skip or not p or p in seen: continue
    seen.add(p)
    print("CONFIG_PACKAGE_%s=y" % p)
