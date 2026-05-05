#!/usr/bin/env bash
# 在 WSL root 下：向 /opt/sysroot-focal-amd64 chroot，解压 archives 中的 Boost 1.55 并完成 ./bootstrap.sh + ./b2 install。
# 用法（WSL 内）: sudo bash boost-155-chroot-build.sh
# 依赖：已挂载或拷贝 archives/boost_1_55_0.tar.bz2；sysroot 内已有 build-essential（gcc、g++、bjam 会通过 bootstrap 生成 b2）。
set -euo pipefail

SR="${CHROOT_SYSROOT:-/opt/sysroot-focal-amd64}"
ARCH_HOST="${BOOST_ARCHIVE:-/mnt/d/ctng-build/workspace/cross-validate/archives/boost_1_55_0.tar.bz2}"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "请用 root 运行: sudo $0" >&2
  exit 1
fi

if [[ ! -d "$SR" ]]; then
  echo "不存在: $SR" >&2
  exit 1
fi

if [[ ! -f "$ARCH_HOST" ]]; then
  echo "找不到 tarball: $ARCH_HOST" >&2
  exit 1
fi

mkdir -p "$SR/tmp"
cp -f "$ARCH_HOST" "$SR/tmp/boost_1_55_0.tar.bz2"

if mountpoint -q "$SR/proc" 2>/dev/null; then :; else mount --bind /proc "$SR/proc"; fi
if mountpoint -q "$SR/dev" 2>/dev/null; then :; else mount --bind /dev "$SR/dev"; fi

echo "==> chroot build Boost 1.55 in $SR"

chroot "$SR" /usr/bin/env bash -lc '
set -euo pipefail
cd /tmp
rm -rf boost_1_55_0
echo "[1/3] extract..."
tar xjf boost_1_55_0.tar.bz2
cd boost_1_55_0
echo "[2/3] bootstrap.sh --prefix=/usr/local"
./bootstrap.sh --prefix=/usr/local
echo "[3/3] b2 install (system + filesystem, static, release)..."
# 先只编少数库，缩短首通时间；需要全量可改 --with-*
./b2 -j"$(nproc)" \
  link=static threading=multi variant=release \
  --with-system --with-filesystem \
  install
echo "==> done"
'

echo "==> 完成: Boost 1.55 已安装到 ${SR}/usr/local"
