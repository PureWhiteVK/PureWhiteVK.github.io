# Ubuntu focal sysroot + ct-ng gcc：必须 -B（crt）与 -isystem（bits 头）。
# debootstrap 解压后经 port_sysroot.sh --fix-only，libdl 等应解析到 .so；本文件不再强行拆分 pthread/dl。
#
#用法：cmake -DCMAKE_TOOLCHAIN_FILE=.../toolchain-focal-sysroot.cmake ...

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

set(_P "${CMAKE_CURRENT_LIST_DIR}")
set(CMAKE_C_COMPILER "${_P}/bin/x86_64-linux-gnu-gcc")
set(CMAKE_CXX_COMPILER "${_P}/bin/x86_64-linux-gnu-g++")

set(_SYS "${_P}/x86_64-linux-gnu/sysroot-focal")
set(_LIB "${_SYS}/usr/lib/x86_64-linux-gnu")
set(_INC "${_SYS}/usr/include/x86_64-linux-gnu")
set(CMAKE_SYSROOT "${_SYS}")
set(CMAKE_FIND_ROOT_PATH "${_SYS}")

set(CMAKE_C_FLAGS_INIT "-B${_LIB} -isystem ${_INC}")
set(CMAKE_CXX_FLAGS_INIT "-B${_LIB} -isystem ${_INC}")
set(CMAKE_EXE_LINKER_FLAGS_INIT "-Wl,-rpath-link,${_LIB}")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "-Wl,-rpath-link,${_LIB}")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
