#!/usr/bin/env bash
# Cygwin：用 ct-ng x86_64-linux-gnu-g++ + focal sysroot 交叉编译 Boost 1.55（仅 system + filesystem）。
# 用法见下文；依赖 archives 下 tarball、sysroot-focal 且建议已执行 port_sysroot.sh --fix-only。
set -euo pipefail

TC="${CTNG_PREFIX:-/cygdrive/d/ctng-build/workspace/cross-tools/toolchains.old/x86_64-linux-gnu}"
CXX_TOOL="${TC}/bin/x86_64-linux-gnu-g++"
SYSROOT="${TC}/x86_64-linux-gnu/sysroot-focal"
LIB="${SYSROOT}/usr/lib/x86_64-linux-gnu"
INC="${SYSROOT}/usr/include/x86_64-linux-gnu"

ARCH="${BOOST_ARCHIVE:-/cygdrive/d/ctng-build/workspace/cross-validate/archives/boost_1_55_0.tar.bz2}"
ROOT="${BOOST_ROOT:-/cygdrive/d/ctng-build/workspace/cross-validate/boost_1_55_0}"

if [[ ! -x "$CXX_TOOL" ]]; then
  echo "找不到交叉 g++: $CXX_TOOL" >&2
  exit 1
fi
if [[ ! -d "$SYSROOT/usr/include" ]]; then
  echo "找不到 sysroot: $SYSROOT" >&2
  exit 1
fi
if [[ ! -f "$ARCH" ]]; then
  echo "找不到 tarball: $ARCH" >&2
  exit 1
fi

if [[ ! -f "$ROOT/project-config.jam" ]] || [[ ! -x "$ROOT/b2" ]]; then
  echo "==> 解压 Boost..."
  rm -rf "$ROOT"
  mkdir -p "$(dirname "$ROOT")"
  tar xjf "$ARCH" -C "$(dirname "$ROOT")"
fi

cd "$ROOT"

# Boost.Build 自动读取 $HOME/user-config.jam
if [[ -f "${HOME}/user-config.jam" ]]; then
  cp "${HOME}/user-config.jam" "${HOME}/user-config.jam.bak.boost155.$$"
  echo "已备份原 user-config.jam -> ${HOME}/user-config.jam.bak.boost155.$$"
fi
cat > "${HOME}/user-config.jam" <<-EOF
using gcc : focal : "${CXX_TOOL}" :
    <compileflags>"--sysroot=${SYSROOT}"
    <compileflags>"-B${LIB}"
    <compileflags>"-isystem${INC}"
    <linkflags>"--sysroot=${SYSROOT}"
    <linkflags>"-Wl,-rpath-link,${LIB}"
    ;
EOF
echo "已写入 ${HOME}/user-config.jam（交叉 focal）；原文件若有备份需求请自行处理"

echo "==> bootstrap（jam0 用 Cygwin gcc；tools/build/v2/engine/build.sh 仅在 toolset=cc 时把 \$CFLAGS 传给 jam0）..."
if [[ ! -x ./b2 ]]; then
  export CC=gcc
  export CFLAGS="${CFLAGS:--DCYGWIN_VERSION_CYGWIN_CONV}"
  ./bootstrap.sh --with-toolset=cc
fi

# bootstrap 在 --with-toolset=cc 时会把「using cc」写进 project-config.jam，但 Boost.Build 没有 cc.init；
# 不改上游源码，只替换 **生成文件**：仅用 \$HOME/user-config.jam 里的 gcc~focal。
echo "==> 重写 project-config.jam（去掉 using cc，默认 gcc-focal）"
cat > "${ROOT}/project-config.jam" <<'JAM'
# 由 boost-155-cygwin-cross-build.sh 覆盖：交叉工具链仅在 ~/user-config.jam 声明

import option ;
import feature ;

project : default-build <toolset>gcc-focal ;

libraries = ;

option.set prefix : /usr/local ;
option.set exec-prefix : /usr/local ;
option.set libdir : /usr/local/lib ;
option.set includedir : /usr/local/include ;
option.set keep-going : false ;
JAM

echo "==> b2 cross toolset=gcc-focal + target-os=linux（否则在 Cygwin 上会变 -mthreads，Linux g++ 不认）..."
./b2 -q -j"$(nproc)" \
  toolset=gcc-focal \
  target-os=linux \
  link=static threading=multi variant=release \
  --with-system --with-filesystem

echo "==> 完成: stage 库在 $ROOT/stage/lib"
