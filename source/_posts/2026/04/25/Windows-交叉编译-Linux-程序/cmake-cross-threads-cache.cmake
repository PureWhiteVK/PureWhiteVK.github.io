# 供 cmake -C 预加载：交叉时 FindThreads 的 try_compile 常失败，提前给定结果。
# 用法： cmake -C .../cmake-cross-threads-cache.cmake ...
set(Threads_FOUND TRUE CACHE INTERNAL "")
set(CMAKE_THREAD_LIBS_INIT "-lpthread" CACHE INTERNAL "")
set(CMAKE_HAVE_LIBC_PTHREAD TRUE CACHE INTERNAL "")
