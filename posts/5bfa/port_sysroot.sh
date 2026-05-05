#!/usr/bin/env bash
set -euo pipefail

########################################
# Ubuntu multiarch sysroot 在 Cygwin / NTFS 上与 ct-ng 交叉链配合时的两件事：
#
# （核心）修正绝对路径软链
#   debootstrap 树里常见 lib*.so -> /lib/<triplet>/...、/usr/lib/<triplet>/...
#   在 Windows 侧解析或 ld --sysroot 查库时，这类「指向根目录绝对路径」的链接容易让
#   -ldl / -lpthread 落到错误的候选（例如退回 libdl.a），出现 __dlopen、preinit_array 等。
#   改成相对路径后，在同一棵 sysroot 树内解析，行为与在 Linux 上接近。
#
# （可选）打包副本
#   若希望单独一棵目录供 CMAKE_SYSROOT（与 ct-ng 自带 sysroot 并列），可从 Ubuntu root
#   拷出 include / lib/<triplet> / usr/lib/<triplet>，再在副本上跑同一套修复。
#
# 不要做的事：整棵 usr/lib 打平、glibc 的 libc.so 链接脚本依赖的路径会被破坏。
#
# 用法:
#   ./port_sysroot.sh [--fix-only] <SRC> [DST]
#
#   --fix-only <SRC>              只在已有 sysroot 上原地修正软链（不拷贝）。SRC 即 CMAKE_SYSROOT。
#   <SRC> <DST>                   从 Ubuntu root（SRC）拷到 DST，最后自动修复 DST。
#
# 示例:
#   ./port_sysroot.sh --fix-only "$PWD/sysroot-focal"
#   ./port_sysroot.sh /mnt/ubuntu-root /opt/my-sysroot
########################################

fix_absolute_symlinks_for_sysroot() {
  local SYSROOT="$1"
  echo "[fix] 绝对路径 → 相对路径（usr/lib、lib 下的 *.so 链）"
  while IFS= read -r -d '' link; do
    tgt=$(readlink "$link")
    case "$tgt" in
      /lib/*-linux-gnu/*)
        base="${tgt##*/}"
        tri="${tgt#/lib/}"
        tri="${tri%%/*}"
        ln -sf "../../../lib/$tri/$base" "$link"
        ;;
      /usr/lib/*-linux-gnu/*)
        base="${tgt##*/}"
        ln -sf "$base" "$link"
        ;;
    esac
  done < <(find "$SYSROOT/usr/lib" -type l -print0 2>/dev/null)

  while IFS= read -r -d '' link; do
    tgt=$(readlink "$link")
    case "$tgt" in
      /lib/*-linux-gnu/*)
        base="${tgt##*/}"
        ln -sf "$base" "$link"
        ;;
    esac
  done < <(find "$SYSROOT/lib" -type l -print0 2>/dev/null)
}

ensure_lib64_ld_linux_symlink() {
  local SYSROOT="$1"
  echo "[fix] lib64/ld-linux-x86-64.so.2（若存在 triplet loader）"
  mkdir -p "$SYSROOT/lib64"
  if [[ -f "$SYSROOT/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2" ]]; then
    ln -sf ../lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 \
      "$SYSROOT/lib64/ld-linux-x86-64.so.2"
  fi
}

merge_pkgconfig_hints() {
  local SYSROOT="$1"
  echo "[extra] 聚合 pkgconfig 到 usr/lib/pkgconfig（可选）"
  for d in "$SYSROOT"/usr/lib/*-linux-gnu; do
    [[ -d "$d/pkgconfig" ]] || continue
    mkdir -p "$SYSROOT/usr/lib/pkgconfig"
    cp -a "$d/pkgconfig/"*.pc "$SYSROOT/usr/lib/pkgconfig/" 2>/dev/null || true
  done
}

copy_ubuntu_to_sysroot() {
  local UBUNTU_ROOT="$1"
  local SYSROOT="$2"

  echo "[copy] Create sysroot dir: $SYSROOT"
  rm -rf "$SYSROOT"
  mkdir -p "$SYSROOT"

  echo "[copy] usr/include"
  mkdir -p "$SYSROOT/usr"
  cp -a "$UBUNTU_ROOT/usr/include" "$SYSROOT/usr/"

  echo "[copy] lib/<triplet>"
  mkdir -p "$SYSROOT/lib"
  for d in "$UBUNTU_ROOT"/lib/*-linux-gnu; do
    [[ -d "$d" ]] || continue
    cp -a "$d" "$SYSROOT/lib/"
  done

  echo "[copy] usr/lib/<triplet>"
  mkdir -p "$SYSROOT/usr/lib"
  for d in "$UBUNTU_ROOT"/usr/lib/*-linux-gnu; do
    [[ -d "$d" ]] || continue
    cp -a "$d" "$SYSROOT/usr/lib/"
  done

  merge_pkgconfig_hints "$SYSROOT"
  ensure_lib64_ld_linux_symlink "$SYSROOT"
  fix_absolute_symlinks_for_sysroot "$SYSROOT"

  echo ""
  echo "✔ Sysroot ready: $SYSROOT"
  echo "  设置 CMAKE_SYSROOT=$SYSROOT（或与 toolchain-*-sysroot.cmake 中的路径一致）。"
  echo ""
}

if [[ "${1:-}" == "--fix-only" ]]; then
  SYSROOT=${2:?用法: $0 --fix-only /path/to/sysroot}
  [[ -d "$SYSROOT/usr" ]] || [[ -d "$SYSROOT/lib" ]] || {
    echo "error: 不像 sysroot 目录: $SYSROOT" >&2
    exit 1
  }
  echo "[mode] --fix-only（原地修正，不拷贝） $SYSROOT"
  merge_pkgconfig_hints "$SYSROOT"
  ensure_lib64_ld_linux_symlink "$SYSROOT"
  fix_absolute_symlinks_for_sysroot "$SYSROOT"
  echo ""
  echo "✔ 软链已按交叉链接用途修正: $SYSROOT"
  echo ""
  exit 0
fi

UBUNTU_ROOT=${1:-/path/to/ubuntu-root}
SYSROOT=${2:-/opt/ctng-sysroot}

if [[ ! -d "$UBUNTU_ROOT/usr" ]]; then
  echo "error: $UBUNTU_ROOT 不像 Ubuntu root（缺少 usr）" >&2
  exit 1
fi

copy_ubuntu_to_sysroot "$UBUNTU_ROOT" "$SYSROOT"
