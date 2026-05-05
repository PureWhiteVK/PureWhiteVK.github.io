# 与 port_sysroot.sh 生成的 sysroot 配套；须 -B / -isystem。软链已修时与 toolchain-focal-sysroot 同型即可。
# 默认: .../x86_64-linux-gnu/sysroot-focal-ported

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

set(_TC "${CMAKE_CURRENT_LIST_DIR}")
set(CMAKE_C_COMPILER "${_TC}/bin/x86_64-linux-gnu-gcc")
set(CMAKE_CXX_COMPILER "${_TC}/bin/x86_64-linux-gnu-g++")

set(_SYS "${_TC}/x86_64-linux-gnu/sysroot-focal-ported")
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
