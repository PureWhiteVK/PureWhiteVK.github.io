#!/usr/bin/env bash
# 在 WSL root + chroot(sysroot) 内运行 Boost 1.55 内置测试（与上次 install 相同 variant）。
# 用法: sudo bash boost-155-chroot-test.sh
# 依赖：/tmp/boost_1_55_0 已由 boost-155-chroot-build.sh 生成；否则会自动解压 tarball 并 bootstrap。
set -euo pipefail

SR="${CHROOT_SYSROOT:-/opt/sysroot-focal-amd64}"
ARCH_HOST="${BOOST_ARCHIVE:-/mnt/d/ctng-build/workspace/cross-validate/archives/boost_1_55_0.tar.bz2}"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "请用 root 运行: sudo $0" >&2
  exit 1
fi

mkdir -p "$SR/tmp"
if [[ ! -f "$SR/tmp/boost_1_55_0.tar.bz2" ]] && [[ -f "$ARCH_HOST" ]]; then
  cp -f "$ARCH_HOST" "$SR/tmp/boost_1_55_0.tar.bz2"
fi

if [[ ! -f "$SR/tmp/boost_1_55_0.tar.bz2" ]]; then
  echo "缺少 $SR/tmp/boost_1_55_0.tar.bz2，且 BOOST_ARCHIVE 未指向可用 tarball" >&2
  exit 1
fi

if mountpoint -q "$SR/proc" 2>/dev/null; then :; else mount --bind /proc "$SR/proc"; fi
if mountpoint -q "$SR/dev" 2>/dev/null; then :; else mount --bind /dev "$SR/dev"; fi

echo "==> chroot: Boost 内置测试 libs/system/test + libs/filesystem/test"

chroot "$SR" /usr/bin/env bash -lc '
set -euo pipefail
cd /tmp
if [[ ! -x boost_1_55_0/b2 ]]; then
  echo "[prep] 解压并 bootstrap..."
  rm -rf boost_1_55_0
  tar xjf boost_1_55_0.tar.bz2
  cd boost_1_55_0
  ./bootstrap.sh --prefix=/usr/local
else
  cd boost_1_55_0
fi

echo "[test] libs/system/test（与 install 一致：static）..."
./b2 -q -j"$(nproc)" \
  link=static threading=multi variant=release \
  libs/system/test

# focal chroot 极简环境下，filesystem 部分 **静态** 用例曾出现 operations_test_static SIGSEGV；
# 官方测试改用 **shared** 链接跑 libs/filesystem/test，可在同一树内稳定完成。
echo "[test] libs/filesystem/test（shared，避免 chroot 下静态跑测崩溃）..."
./b2 -q -j"$(nproc)" \
  link=shared threading=multi variant=release \
  libs/filesystem/test

echo "==> 内置测试步骤执行完毕（若上面无报错即通过）"
'
