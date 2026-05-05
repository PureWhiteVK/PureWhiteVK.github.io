# 工具链旁路文件（请复制到本机 crosstool 目录）

将以下文件复制到 **`…/cross-tools/toolchains/x86_64-linux-gnu/`**（与现有 **`toolchain.cmake`** 同级）：

| 文件 | 说明 |
| --- | --- |
| `toolchain-focal-sysroot.cmake` | 使用 **`x86_64-linux-gnu/sysroot-focal`** 作为 `CMAKE_SYSROOT`，不修改原版 **`toolchain.cmake`** |
| `extract-sysroot-focal.sh` | 把 **`sysroot-focal.tar.gz`** 解压为 **`sysroot-focal`**（与 **`sysroot`** 并列） |

解压目标路径（与 ct-ng 默认 sysroot 同级）：

```text
…/toolchains/x86_64-linux-gnu/x86_64-linux-gnu/sysroot          # ct-ng 自带
…/toolchains/x86_64-linux-gnu/x86_64-linux-gnu/sysroot-focal    # debootstrap focal
```

 tarball 默认：**`/cygdrive/d/ctng-build/sysroot-focal.tar.gz`**（可在脚本里设 **`TAR=`** 覆盖）。
