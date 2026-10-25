#!/bin/sh
# 从 OpenWrt 源码 + 本仓库补丁构建 BE7000 固件。
# 要求：Linux（或 WSL2）、约 40 GB 磁盘空间、OpenWrt 编译依赖包：
#   https://openwrt.org/docs/guide-developer/toolchain/install-buildsystem
# 用法：./build.sh [目录] [线程数]
#   MINI=1 ./build.sh … — 最小版本（原版 OpenWrt 组成 + BE7000 支持）
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
DIR=${1:-openwrt-be7000}
JOBS=${2:-$(nproc)}
rev() { awk -v n="$1" '$1==n{print $2}' "$HERE/source/feeds.lock"; }

[ -d "$DIR/.git" ] || git clone https://github.com/openwrt/openwrt.git "$DIR"
cd "$DIR"
git checkout -q "$(rev openwrt)"
git am -q "$HERE"/source/patches/*.patch

# 软件源 — 使用与发布版相同的提交
cp feeds.conf.default feeds.conf
for f in packages luci routing telephony video; do
	sed -i "s|^\(src-git $f [^ ;^]*\).*|\1^$(rev $f)|" feeds.conf
done
./scripts/feeds update -a
./scripts/feeds install -a
./feed-patches/apply.sh

SFX=${MINI:+-mini}
rm -rf files && cp -a "$HERE/source/files$SFX" files
cp "$HERE/source/diffconfig$SFX" .config
make defconfig
make download -j"$JOBS"
# IGNORE_ERRORS=m：编译不过的可选模块（给软件源用的 kmod）直接跳过
make -j"$JOBS" IGNORE_ERRORS=m
ls -la bin/targets/qualcommbe/ipq95xx/*factory.ubi
