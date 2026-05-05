#!/usr/bin/env bash
# 将 sysroot-focal.tar.gz 解压为与本工具链默认 sysroot 同级目录：
#   .../x86_64-linux-gnu/x86_64-linux-gnu/sysroot          （ct-ng 自带，勿动）
#   .../x86_64-linux-gnu/x86_64-linux-gnu/sysroot-focal    （debootstrap focal）
# 包内顶层目录名为 sysroot/，解压后改名为 sysroot-focal，避免覆盖前者。
#
# 用法（Cygwin）： chmod +x extract-sysroot-focal.sh && ./extract-sysroot-focal.sh
# 可选： TAR=/path/to/sysroot-focal.tar.gz ./extract-sysroot-focal.sh
# 须 LF 换行。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
TARGET_PARENT="${SCRIPT_DIR}/x86_64-linux-gnu"
TARGET="${TARGET_PARENT}/sysroot-focal"
TAR="${TAR:-/cygdrive/d/ctng-build/sysroot-focal.tar.gz}"

if [[ -f "${TARGET}/usr/include/stdlib.h" ]]; then
  echo "已存在，跳过: ${TARGET}"
  exit 0
fi

if [[ ! -f "${TAR}" ]]; then
  echo "找不到 tarball: ${TAR}" >&2
  exit 1
fi

mkdir -p "${TARGET_PARENT}"
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT

echo "==> 解压 ${TAR} -> ${TARGET}"
tar xzf "${TAR}" -C "${tmp}"
if [[ ! -d "${tmp}/sysroot" ]]; then
  echo "包内未找到顶层目录 sysroot/，请检查压缩包结构。" >&2
  exit 1
fi

mv "${tmp}/sysroot" "${TARGET}"
trap - EXIT
rm -rf "${tmp}"

echo "==> OK: ${TARGET}"
