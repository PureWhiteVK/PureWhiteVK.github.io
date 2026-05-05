# 【不可用】仅 CMAKE_SYSROOT：链接测试程序会报找不到 crt1.o / crti.o（须在 usr/lib/<triplet>，须 -B）。
# 保留本文件作对照；正式请用 toolchain-focal-sysroot.cmake。

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

set(_P "${CMAKE_CURRENT_LIST_DIR}")
set(CMAKE_C_COMPILER "${_P}/bin/x86_64-linux-gnu-gcc")
set(CMAKE_CXX_COMPILER "${_P}/bin/x86_64-linux-gnu-g++")

set(_SYS "${_P}/x86_64-linux-gnu/sysroot-focal")
set(CMAKE_SYSROOT "${_SYS}")
set(CMAKE_FIND_ROOT_PATH "${_SYS}")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
