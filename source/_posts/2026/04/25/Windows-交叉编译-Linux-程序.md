---
title: Windows 交叉编译 Linux 程序
mathjax: false
abbrlink: 5bfa
tags:
  - CMake
  - Linux
  - cross-compile
category:
  - C++学习笔记
date: 2026-04-25 19:43:06
---

最近碰到一个需求是要在 Windows 上交叉编译 Linux 程序，用于做 Windows 代码的跨平台编译检查，发现里面弯弯绕绕还挺多的（主要是 Windows 和 Linux 系统层面的一些差异需要注意），就通过一篇博客记录一下整个交叉编译的流程，也加深对于交叉编译流程的理解。

整个交叉编译包含2个主要步骤：sysroot 准备和交叉编译工具链的构建。

- sysroot 在 WSL 上使用 debootstrap 创建

- 交叉编译工具链通过 Cygwin 和 crosstool-ng 生成

<!-- more -->

# 安装 WSL

使用 WSL（**W**indows **S**ubsystem for **L**inux）主要是为了以下两件事：

1. 创建交叉编译的 sysroot

2. 验证交叉编译产物结果

通过 WSL 可以方便的同 Windows 文件系统进行交互，便于使用

## 导入 WSL 镜像

可以在清华镜像站上的 Ubuntu 的 [WSL 镜像](https://mirrors.tuna.tsinghua.edu.cn/ubuntu-releases/20.04.6)（本次使用的是 Ubuntu 20.04.6）：

使用如下命令导入 WSL 镜像：

```powershell
wsl --import <发行版名称> <本机目录> <镜像路径>
```

完整命令示例如下：

```powershell
wsl --import Ubuntu-20.04 D:\VM\WSL\Ubuntu-20.04 D:\Download\ubuntu-20.04.6-wsl-amd64.wsl
```

导入完成后可通过如下命令启动指定 Linux 发行版：

```powershell
wsl -d <发行版名称>
```

> [!TIP]
>
> 直接 `--import` 的实例默认只有 `root`，与商店安装的「自动创建用户」不同，需要手动建普通用户并设为默认登录用户。

## （可选）创建普通用户

在 WSL 内执行如下命令创建用户

```bash
adduser <user-name>
usermod -aG sudo <user-name>
```

编辑 `/etc/wsl.conf` 设置默认用户：

```ini
[boot]
systemd=true

[user]
default=<user-name>
```

在 Windows 侧执行 `wsl --shutdown` 后重新进入 WSL，确认已以普通用户登录。

## （可选）更换软件源

参照[阿里云 Ubuntu 软件源](https://developer.aliyun.com/mirror/ubuntu/)说明，根据实际使用的 Ubuntu 版本替换 `/etc/apt/sources.list` 中地址即可

替换之后记得执行 update

```bash
sudo apt update
```



# 准备 sysroot

sysroot（system root） 是用于编译/交叉编译的“目标系统根目录视图”，**仅包含编译时需要的部分**（头文件、库文件、动态链接器）等，**无法通过 chroot 方式执行程序**。

rootfs（root filesystem）则是用于运行阶段的完整系统根目录，**包含完整的 Linux 系统结构**（`/bin`，`/sbin`，`/etc`，`/usr`，`/var` 等），**可以通过 chroot 方式进入并执行程序**。

对 rootfs 裁剪掉不必要的文件后可得到 sysroot。

## 安装依赖

```bash
sudo apt install debootstrap systemd-container qemu-user-static binfmt-support
```

- **debootstrap**：从镜像站拉取包并初始化 rootfs。
- **systemd-container**：以容器方式进入 rootfs，并自动挂载目录。
- **qemu-user-static**：用于支持在非本机 ISA（Instruction Set Architecture，指令集架构） 的 rootfs 里执行目标程序（例如做 **arm64 的 sysroot** 时很有用）
- **binfmt-support**：让 Linux 支持运行非本机 ISA 的 ELF 程序，可以自动调用 qemu 执行 arm 应用。

## 初始化 rootfs

通过如下命令初始化 rootfs

```bash
sudo debootstrap \
    --arch=amd64 \
    --variant=minbase \
    focal \
    /opt/rootfs-focal-amd64 \
    https://mirrors.aliyun.com/ubuntu/
```

执行完成后会提示 “Base system installed successfully”（基础系统成功安装）

<img src="Windows-交叉编译-Linux-程序/image-20260505212830069.png" alt="image-20260505212830069" style="zoom: 67%;" />

## 进入 rootfs

直接通过 chroot 可以进入 rootfs 安装程序，但是通常运行时需要手动挂载 dev、run、proc 等目录，为简化操作，可通过 systemd-nspawn 以容器方式进入 rootfs，命令如下：

```bash
#!/bin/bash
set -euo pipefail

SYSROOT=/opt/rootfs-focal-amd64
SRC=/home/xiao/devenv

sudo systemd-nspawn \
        -D "$SYSROOT" \
        --bind="$SRC:/mnt/project" \
        --bind=/etc/resolv.conf \
        --setenv=HOME=/root \
        --setenv=TERM="$TERM" \
        --hostname=sysroot-env \
        --console=interactive \
        /bin/bash
```

将脚本保存到本地执行即可，成功进入rootfs输出如下所示：

<img src="Windows-交叉编译-Linux-程序/image-20260505213158260.png" alt="image-20260505213158260" style="zoom:67%;" />

## 安装依赖

由于 debootstrap 创建 rootfs 时默认仅使用 focal 和 main 的软件，在安装依赖前需要重新调整软件源，命令如下所示：

```bash
tee /etc/apt/sources.list > /dev/null <<'EOF'
deb https://mirrors.aliyun.com/ubuntu/ focal main universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ focal-updates main universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ focal-security main universe multiverse
EOF
```

然后通过如下命令更新软件源和软件。

```bash
apt update
apt upgrade -y
```

为满足后续验证需要，我们在 rootfs 内安装下列依赖

```bash
apt install -y \
    build-essential \
    pkg-config \
    ca-certificates \
    tzdata \
    locales \
    git \
    python3 \
    python3-pip \
    python3-venv
```

同时配置 pip 镜像并安装 conan、cmake 和 ninja（通过 pip 安装的 cmake 和 ninja 版本更新）：

```bash
pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/
pip install conan cmake ninja
```

若后续要在 sysroot 内编译或验证 GLFW 一类依赖 X11/Wayland 的库，可额外安装开发包（体积较大，可按需装）：

```bash
apt install -y libwayland-dev libxkbcommon-dev xorg-dev
```

配置完成后使用 `exit` 命令退出 rootfs。

## 创建 sysroot

rootfs 创建完成后，可拷贝 lib、include 和 pkgconfig 目录以生成 sysroot，具体命令如下：

```bash
#!/usr/bin/env bash
set -e

SRC=$1
DST=$2

if [ -z "$SRC" ] || [ -z "$DST" ]; then
  echo "Usage: $0 <rootfs> <sysroot>"
  exit 1
fi

mkdir -p "$DST"

echo "[1/3] Copy essential directories..."

rsync -aHAXm --numeric-ids -m \
  --include="/usr/***" \
  --include="/lib" \
  --include="/lib64" \
  --include="/lib32" \
  --include="/libx32" \
  --include="*/" \
  --exclude="*" \
  "$SRC"/ "$DST"/

fix_absolute_symlinks_for_sysroot() {
  local SYSROOT="$1"
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
  mkdir -p "$SYSROOT/lib64"
  if [[ -f "$SYSROOT/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2" ]]; then
    ln -sf ../lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 \
      "$SYSROOT/lib64/ld-linux-x86-64.so.2"
  fi
}

ensure_lib64_ld_linux_symlink "$DST"
fix_absolute_symlinks_for_sysroot "$DST"

echo "[2/3] Ensure loader exists..."

find "$DST" -name "ld-linux*" || {
  echo "ERROR: dynamic loader not found"
  exit 1
}

echo "[3/3] Basic validation..."

echo "- libc:"
find "$DST" -name "libc.so*"

echo "- interpreter candidates:"
find "$DST" -name "ld-linux*"

echo "Done."
```

## 打包和解压

打包命令（在 WSL 中执行）

```bash
tar --numeric-owner \
    --xattrs \
    --acls \
    -czf sysroot-focal.tar.gz \
    -C "<sysroot_dir 在 WSL 中的位置，例如 /home/xiao/devenv/sysroot-focal>" .
```

解压命令（在 Cygwin 中执行）

```bash
sysroot_dir="<sysroot_dir 在 Cygwin 中的位置，例如 /cygdrive/d/sysroot-focal>"
mkdir -p $sysroot_dir
tar -xzf sysroot-focal.tar.gz \
    --no-same-owner \
    --no-same-permissions \
    -C "$sysroot_dir"
```



# 安装 Cygwin

为在 Windows 上编译 Linux 的可执行程序，需要模拟出 Linux 运行环境（基本上就是模拟出 POSIX 接口），由于 MSYS2 的工具链更新太过激进且并不是完全兼容 POSIX 接口，因此选择 Cygwin 作为构建的基础环境。

## 安装依赖

从官网下载 `setup-x86_64.exe`，在包列表中勾选下列依赖（具体版本参考下文的完整安装列表）：

- autoconf, automake, bison, flex, gawk, 
- help2man, texinfo, diffutils, patch, make, 
- cmake, ninja, gcc-g++, git, wget, xz, zip, unzip, 
- libtool, gperf, libncurses-devel, python312-devel

**完整安装列表**见：[cygcheck-c.txt](cygcheck-c.txt)（通过 `cygcheck -c` 输出）

> [!NOTE]
>
> 建议将 `setup-x86_64.exe` 放在 Cygwin 的安装目录下面，因为该程序将作为 cygwin 的包管理器，有可能需要频繁使用该程序安装包。

## 设置环境变量

在 **Cygwin 的 shell 配置文件**（如 `~/.bashrc`）末尾中加入下列内容：

```bash
export CYGWIN=winsymlinks:sys
export PATH="/usr/local/bin:/usr/bin"
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export http_proxy="http://127.0.0.1:7890"
export https_proxy="http://127.0.0.1:7890"
# 可选：少数工具只认 ALL_PROXY
# export ALL_PROXY="$https_proxy"
```

其中 **代理地址本机长期按 `127.0.0.1:7890` 使用**（与常见 Clash 等 **HTTP 代理端口** 一致），若实际端口或协议不同，只改最后两行中的 URL 即可。

## （可选）卸载 Cygwin

仅删除安装目录时可能残留注册表项；可用下列 PowerShell 脚本（需 **PowerShell 7+**，删 `HKLM` 需管理员权限）。保存为 `uninstall_cygwin.ps1` 后执行：

```powershell
#requires -Version 7.0
# uninstall_cygwin.ps1 — 仅删除安装目录 + 清理 Cygwin 相关注册表项
# 请用 PowerShell 7 运行: pwsh -NoProfile -File .\uninstall_cygwin.ps1
# 运行前请手动关闭所有 Cygwin / mintty 窗口，否则删除目录可能失败。
# 删除 HKLM 下项需要管理员权限。

Write-Host "== Cygwin 卸载（目录 + 注册表）=="

# -------- 可配置路径（若安装在其他盘符，请在此添加）--------
$cygwinPaths = @(
    "C:\cygwin64",
    "C:\cygwin"
)

$regPaths = @(
    "HKCU:\Software\Cygwin",
    "HKLM:\SOFTWARE\Cygwin",
    "HKLM:\SOFTWARE\WOW6432Node\Cygwin"
)

Write-Host "[1/2] 删除安装目录..."
foreach ($path in $cygwinPaths) {
    if (Test-Path -LiteralPath $path) {
        Write-Host "  正在删除: $path"
        Remove-Item -LiteralPath $path -Recurse -Force -ErrorAction Stop
    }
    else {
        Write-Host "  跳过（不存在）: $path"
    }
}

Write-Host "[2/2] 清理注册表..."
foreach ($reg in $regPaths) {
    if (Test-Path -LiteralPath $reg) {
        Write-Host "  正在删除: $reg"
        Remove-Item -LiteralPath $reg -Recurse -Force -ErrorAction Stop
    }
}

Write-Host "== 完成 =="
Write-Host "若曾把 Cygwin 加入系统 PATH，请自行在「环境变量」中删掉含 cygwin 的条目。"
```

---

# 构建交叉编译工具链

## 配置工作目录

执行下列命令设置文件夹路径大小写敏感（需要管理员权限，Win11 下开启开发者模式也可以）

```powershell
fsutil.exe file SetCaseSensitiveInfo "D:\workspace" enable
```

> [!TIP]
>
> 如果觉得路径太长，也可以直接将该路径链接到 `~`
>
> ```bash 
> ln -s /cygdriver/d/workspace ~/workspace
> ```

## 安装 crosstool-ng

源码（示例版本 **1.28.0**）：<http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.28.0.tar.xz>

解压后在源码目录外建 `build`：

```bash
mkdir build && cd build
../configure --prefix=<ct-ng-install-path>
make -j
make install
```

将安装前缀下的 `bin` 加入 `PATH`：

```bash
export PATH="<ct-ng-install-path>/bin:/usr/local/bin:/usr/bin"
```

例如：

```bash
export PATH="/home/xiao/workspace/local/bin:/usr/local/bin:/usr/bin"
```

检查：

```bash
ct-ng version
```

<!-- 截图：`ct-ng version` 输出 -->

## （可选）配置工具链

使用菜单进行配置或直接拷贝既有 `.config`：

```bash
ct-ng menuconfig
```

配置时的一些注意事项：

1. **Linux 头文件版本**：在满足程序需求的前提下尽量别追新，减少与旧 sysroot 不匹配。
2. **glibc / gcc / binutils** 组合要与目标环境匹配；一般直接对齐某个发行版即可（例如 Ubuntu 20.04：`glibc 2.31` + `gcc 9` + `binutils 2.34` 一类组合，具体以你 sysroot 为准）。
3. 下载 tarball 慢时，可在配置里改为国内镜像（例如清华 **GNU 镜像**）再 `ct-ng build`。

<!-- 截图：`menuconfig` 中与目标架构、内核头、glibc 版本相关的界面（可多张） -->

## 构建工具链

```bash
ct-ng build
```

构建时间长，日志里若出现下载失败，多半是网络或镜像问题。

<!-- 截图：构建成功结束时的最后若干行日志 -->

## 基本编译验证

下面为本机 **已跑通** 的一次最小验证（**prefix** 以 `ct-ng` 样本为准，这里是 **`x86_64-linux-gnu`**；若你的三元组是 `x86_64-unknown-linux-gnu`，把命令里的前缀名整体替换即可）。

**工具链根目录**（PATH 与 CMake 都会用到）：

`D:\ctng-build\workspace\cross-tools\toolchains\x86_64-linux-gnu`

在 **Cygwin** 里先把交叉编译器放进 PATH（每次新开终端都要 export，或写入 `~/.bashrc`）：

```bash
export PATH="/cygdrive/d/ctng-build/workspace/cross-tools/toolchains/x86_64-linux-gnu/bin:/usr/local/bin:/usr/bin"
```

确认编译器可用：

```bash
x86_64-linux-gnu-gcc --version
x86_64-linux-gnu-g++ --version
```

示例输出（节选）：

```text
x86_64-linux-gnu-gcc (crosstool-NG 1.28.0) 9.5.0
...
x86_64-linux-gnu-g++ (crosstool-NG 1.28.0) 9.5.0
...
```

**最小 C 程序**：单独建目录便于以后清理（例如 `D:\ctng-build\workspace\cross-validate\smoke-hello`）。

```bash
mkdir -p /cygdrive/d/ctng-build/workspace/cross-validate/smoke-hello
cd /cygdrive/d/ctng-build/workspace/cross-validate/smoke-hello
printf 'int main(void) { return 0; }\n' > hello.c
x86_64-linux-gnu-gcc hello.c -o hello
file hello
```

`file` 在 Cygwin 下应看到 **ELF 64-bit、x86-64、interpreter /lib64/ld-linux-x86-64.so.2** 等，即已得到 **Linux 可执行文件**（目标内核版本会随工具链 `ct-ng` 配置变化，以你本机 `file` 为准）。

在 **WSL** 中直接跑 Windows 盘上的同一路径（本机为 `/mnt/d/...`）：

```bash
/mnt/d/ctng-build/workspace/cross-validate/smoke-hello/hello
echo $?
```

期望最后一行输出 **`0`**。也可先确认解释器与 `libc` 链接正常：

```bash
file /mnt/d/ctng-build/workspace/cross-validate/smoke-hello/hello
ldd  /mnt/d/ctng-build/workspace/cross-validate/smoke-hello/hello
```

`ldd` 中应能解析到 `libc.so.6` 与 `ld-linux-x86-64.so.2`（具体路径随 WSL 发行版可能是 `/lib/x86_64-linux-gnu/...`）。

<!-- 截图：可选：Cygwin 里 `file hello`；WSL 里 `./hello` 后 `echo $?` 为 0，以及 `ldd` 输出 -->

> [!NOTE]
>
> **坑点**
>
> 1. 能 `gcc` 出 ELF 不代表 **sysroot/链接参数** 与后文 CMake 一致；做库级验证时以同一套 **`toolchain.cmake`** 为准（见下节），少手搓 `--sysroot`。
> 2. 本仓库里与 `ct-ng` 安装布局对应的文件名为 **`toolchain.cmake`**（在 `x86_64-linux-gnu` 目录下），不是 `toolchains.cmake`；若复制网上示例命令，注意文件名与 `CMAKE_FIND_ROOT_PATH` 是否一致。
> 3. 启动 `wsl` 时若出现 **localhost / 代理 / NAT** 相关英文警告但命令仍成功，一般可忽略；若二进制无法运行再查 **WSL 与工具链 glibc 版本** 是否差太多。

---

# 交叉编译验证（CMake）

目标：**在 Windows(Cygwin) 侧用交叉编译器 + sysroot 编译**，在 **WSL** 侧运行（或至少 `ldd` / 动态加载）验证。下表为 **本机** 使用的一套路径，换盘符或换 prefix 时自行替换：

- Cygwin：`C:\cygwin64`
- sysroot 压缩包示例：`D:\ctng-build\sysroot-focal.tar.gz`（解压后的目录参与 `CMAKE_SYSROOT`）
- 工具链安装前缀：`D:\ctng-build\workspace\cross-tools\toolchains\x86_64-linux-gnu`（其下的 **`toolchain.cmake`** 供 CMake 使用）
- 建议验证工作区：`D:\ctng-build\workspace\cross-validate`（本文 **`smoke-hello`** 目录即最小示例）

通用步骤（`-DCMAKE_TOOLCHAIN_FILE` 指向 **与你前缀目录同级** 的 `toolchain.cmake`）：

```bash
export PATH="/cygdrive/d/ctng-build/workspace/cross-tools/toolchains/x86_64-linux-gnu/bin:/usr/local/bin:/usr/bin"
cd /cygdrive/d/ctng-build/workspace/cross-validate/<project>
cmake -S . -B build \
  -DCMAKE_TOOLCHAIN_FILE=/cygdrive/d/ctng-build/workspace/cross-tools/toolchains/x86_64-linux-gnu/toolchain.cmake \
  -DCMAKE_BUILD_TYPE=Release
cmake --build build
```

将产物拷到 WSL 或通过共享目录运行测试。

## {fmt}

发行包：<https://github.com/fmtlib/fmt/releases/download/12.1.0/fmt-12.1.0.zip>

**建议用库自带的 GTest 单测**（`FMT_TEST=ON`），在 Cygwin 里交叉编出 **Linux ELF**，再到 **WSL** 里**执行 `build/bin` 下各测试可执行文件**（脚本按顺序跑完），与「自己写几行 `fmt::print`」相比更能覆盖头文件/链接/ABI。

本机把流程固化成两个脚本（与源码同目录，在 **`D:\ctng-build\workspace\cross-validate\fmt-12.1.0\`** 下；换机器时只改脚本里的 `CTNG_ROOT` / 构建目录名）：

| 脚本 | 作用 |
| --- | --- |
| `build-cross.sh` | 设好 `PATH` 与 `toolchain.cmake`，`Ninja` 配置并编译，**打开官方 `FMT_TEST`**（并关 `FMT_DOC` / `FMT_MODULE` 等以减轻交叉场景负担）。 |
| `run-ctest-wsl.sh` | **仅给 WSL/Linux 执行**的 bash：按顺序跑 **`build-linux-cross/bin/`** 下各 ELF（**不调用 `ctest`**）。在 Windows / Cygwin 侧请用 **`wsl bash /mnt/d/.../run-ctest-wsl.sh`** 调用，不要把 `wsl` 写进脚本里。脚本须 **LF** 换行。 |

在 Cygwin 中（先 `chmod +x` 一次即可）：

```bash
cd /cygdrive/d/ctng-build/workspace/cross-validate/fmt-12.1.0
./build-cross.sh
wsl bash /mnt/d/ctng-build/workspace/cross-validate/fmt-12.1.0/run-ctest-wsl.sh
```

若 CMake/Ninja 缓存坏了需要重来：`FULL_CLEAN=1 ./build-cross.sh`。默认会做 **增量** 重新配置（不删 `build-linux-cross`）；若要干净目录，同样用 `FULL_CLEAN=1`。

构建目录默认为源码下的 **`build-linux-cross`**；若你改过 `BLD` 或盘符，请同步修改 **`run-ctest-wsl.sh` 里的 `BLD=`**（`/mnt/d/...`）。

> [!NOTE]
>
> 交叉主机上 **不要** 在 Cygwin 里直接执行 Linux ELF：应在 **WSL**（或真机 Linux）里跑。脚本名字仍叫 `run-ctest-wsl.sh` 只是历史命名；**不要求 WSL 安装 `ctest`**，只要 `/mnt/d/.../bin/` 可读可执行即可。
>
> 若你希望 **与 CMake 登记的顺序、筛选完全一致**，仍可改用 `ctest`（需在 WSL 安装 cmake），并自行保证构建目录与测试工作目录在 WSL 下路径一致。

<!-- 截图：WSL 中脚本末尾 `Done: N program(s), 0 failed` 或某条 FAILED 行 -->

## Catch2

源码：<https://github.com/catchorg/Catch2/archive/refs/tags/v3.14.0.tar.gz>

与 **{fmt}** 同属 CMake：**Cygwin 里配置 + 交叉链接**，产物在 **WSL** 里跑官方测试。差别在于 Catch2 的「整套」单测打成一个可执行文件 **`build-linux-cross/tests/SelfTest`**（不是散落在 `bin/` 里）。

打开 SelfTest 时，上游把 **`CATCH_DEVELOPMENT_BUILD`** 与测试 CMake 绑在一起；仅开 **`BUILD_TESTING=ON`** 往往编不出 SelfTest。交叉场景建议顺带关掉 **`CATCH_ENABLE_WERROR`**（避免 `-Werror` 在交叉器上误伤），并关掉 benchmark/fuzzer/extra_tests/coverage/docs 以减负：

- **`CATCH_DEVELOPMENT_BUILD=ON`**、**`BUILD_TESTING=ON`**
- **`CATCH_ENABLE_WERROR=OFF`**
- **`CATCH_BUILD_BENCHMARKS=OFF`**、**`CATCH_BUILD_FUZZERS=OFF`**、**`CATCH_BUILD_EXTRA_TESTS=OFF`**、**`CATCH_ENABLE_COVERAGE=OFF`**、**`CATCH_INSTALL_DOCS=OFF`**
- **`CMAKE_CXX_STANDARD=17`**（与上游默认一致即可）

配置阶段若启用 SelfTest，CMake 会用到 **构建主机上的 Python3**（本机在 Cygwin 下为 **`/usr/bin/python3`**）；不必在 sysroot 里为「跑测试」装 Python——测试二进制仍是普通 Linux ELF，只在 WSL 里执行。

本机脚本（与源码同目录，在 **`D:\ctng-build\workspace\cross-validate\Catch2-3.14.0\`**；换机器时只改 **`CTNG_ROOT`** / **`run-ctest-wsl.sh`** 里的 `/mnt/d/...`）：

| 脚本 | 作用 |
| --- | --- |
| `build-cross.sh` | 设好 `PATH` 与 `toolchain.cmake`，`Ninja` 配置并编译，打开 **`CATCH_DEVELOPMENT_BUILD`** 与上述开关。 |
| `run-ctest-wsl.sh` | **仅 WSL/Linux** 执行 **`tests/SelfTest`**（**不调用 `ctest`**）。宿主机用 **`wsl bash /mnt/d/.../run-ctest-wsl.sh`**；可选参数会传给 SelfTest。汇总里 **「failed as expected」** 为预期；**退出码 0** 即通过。脚本须 **LF**。 |

在 Cygwin 中（先 `chmod +x` 一次即可；脚本须 **LF** 换行，否则 `set -euo pipefail` 可能异常）：

```bash
cd /cygdrive/d/ctng-build/workspace/cross-validate/Catch2-3.14.0
./build-cross.sh
wsl bash /mnt/d/ctng-build/workspace/cross-validate/Catch2-3.14.0/run-ctest-wsl.sh
```

若 CMake/Ninja 缓存坏了需要重来：`FULL_CLEAN=1 ./build-cross.sh`。默认 **`build-linux-cross`**；若改过 **`BLD`** 或 WSL 盘符路径，请同步修改 **`run-ctest-wsl.sh`** 中的 **`BLD=`**。

需要附加 Catch2 参数时，写在 **`wsl bash .../run-ctest-wsl.sh`** 后面即可（会传给 SelfTest）；也可在 WSL 内直接执行 **`.../build-linux-cross/tests/SelfTest ...`**。

<!-- 截图：WSL 中 SelfTest 末尾汇总（如 test cases: … passed … failed as expected） -->

## sqlite

源码：<https://sqlite.org/2026/sqlite-autoconf-3530000.tar.gz>

发行包内已含 **amalgamation**（`sqlite3.c` / `sqlite3.h`），可不用先跑 `configure` 就编库。经典 **Autotools** 交叉流程是 **`./configure --host=x86_64-linux-gnu CC=...`** 等；但**官方随源码的回归测试大量依赖 [Tcl](https://www.tcl.tk/)**（`test/*.test` 等），在「只装交叉器 + sysroot」的主机上往往**既不想、也不必**为跑测去整理一套 **目标 Linux 上的 Tcl + 与构建机路径一致** 的环境，因此本文**不跑**上游 Tcl 单测，改为在源码树里增加子目录 **`cross-smoke/`**，用自写 C 程序 **`smoke.c`** 做**最小可执行验证**（`:memory:` 建表、**`sqlite3_exec`**、**`sqlite3_prepare_v2` / `bind` / `step`**），与 {fmt} 一样：**在 Cygwin 里配好 `cmake` / `ninja` 与 `PATH` 后交叉编译**，再在 **WSL** 里跑 ELF。

**说明**：下列 **`cmake` / `ninja` / 交叉 `gcc` 均指 Cygwin 环境**（与全文「准备 Cygwin」一致）；不要在未配置工具链的 Windows 宿主上单独找「裸」CMake——交叉验证的一贯入口是 Cygwin shell。

本机布局（**`D:\ctng-build\workspace\cross-validate\sqlite-autoconf-3530000\`**）：

| 路径 | 作用 |
| --- | --- |
| `sqlite3.c`、`sqlite3.h` | 官方 amalgamation（与 `cross-smoke` 同级）。 |
| `cross-smoke/CMakeLists.txt` | 静态库 **`sqlite3`** + 可执行文件 **`smoke`**。 |
| `cross-smoke/smoke.c` | 替代 Tcl 套件的微型验证逻辑。 |
| `cross-smoke/build-cross.sh` | Cygwin：写 **`PATH`**、**`toolchain.cmake`**，**Ninja** Release 构建到 **`build-linux-cross/`**。 |
| `cross-smoke/run-validate-wsl.sh` | **仅 WSL/Linux**：运行 **`build-linux-cross/smoke`**；宿主机执行 **`wsl bash /mnt/d/.../run-validate-wsl.sh`**。脚本须 **LF**。 |

在 **Cygwin** 中：

```bash
cd /cygdrive/d/ctng-build/workspace/cross-validate/sqlite-autoconf-3530000/cross-smoke
./build-cross.sh
wsl bash /mnt/d/ctng-build/workspace/cross-validate/sqlite-autoconf-3530000/cross-smoke/run-validate-wsl.sh
```

成功时 WSL 终端应打印 **`sqlite cross-smoke: OK`**，退出码 **0**。清理重配：**`FULL_CLEAN=1 ./build-cross.sh`**。若改过 **`BLD`** 或盘符，同步修改 **`run-validate-wsl.sh`** 里的 **`BLD=`**。

> [!NOTE]
>
> 若你仍希望走 **Autotools** 安装 CLI **`sqlite3`** 或动态库，可在 **`sqlite-autoconf-*`** 根目录对 **`configure`** 使用 **`--host=`** 与 **`CC=`** 指向 **`x86_64-linux-gnu-gcc`**；与 amalgamation 小测互不冲突，按需选用即可。

<!-- 截图：WSL 中 `sqlite cross-smoke: OK` 一行 -->

## Abseil（及 googletest）

- Abseil：<https://github.com/abseil/abseil-cpp/releases/download/20260107.1/abseil-cpp-20260107.1.tar.gz>
- GoogleTest：<https://github.com/google/googletest/releases/download/v1.17.0/googletest-1.17.0.tar.gz>

在 **`cross-validate`** 下将二者**解压为同级目录**（与全文约定一致），例如 **`abseil-cpp-20260107.1/`** 与 **`googletest-1.17.0/`**。**不再额外写聚合用的顶层 `CMakeLists.txt`**：直接在 **Abseil 源码根** 上配置 CMake，并通过上游变量 **`ABSL_LOCAL_GOOGLETEST_DIR`** 指向本地 googletest 根目录（内含其顶层 **`CMakeLists.txt`**）。脚本 **`abseil-cross-smoke/build-cross.sh`** 默认把该变量设为「脚本上一级目录下的 **`googletest-1.17.0`**」，你也可以在环境里覆盖 **`ABSL_SRC`** / **`ABSL_LOCAL_GOOGLETEST_DIR`** 后再执行脚本。

配置示例（由 **`build-cross.sh`** 代为拼接；手动 cmake 时同理）：

```bash
cmake -S /path/to/abseil-cpp-20260107.1 -B build-linux-cross -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE=.../toolchain.cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=17 \
  -DCMAKE_CXX_STANDARD_REQUIRED=ON \
  -DBUILD_TESTING=ON \
  -DABSL_BUILD_TESTING=ON \
  -DABSL_ENABLE_INSTALL=OFF \
  -DABSL_LOCAL_GOOGLETEST_DIR=/path/to/googletest-1.17.0
```

在 **Cygwin** 中：

```bash
cd /cygdrive/d/ctng-build/workspace/cross-validate/abseil-cross-smoke
./build-cross.sh
wsl bash /mnt/d/ctng-build/workspace/cross-validate/abseil-cross-smoke/run-validate-wsl.sh
```

运行阶段在 **WSL** 里执行 **`run-validate-wsl.sh`**：与 **{fmt}** 一样**按文件名顺序**运行 **`build-linux-cross/bin/`** 下各 Linux ELF（**不要求安装 `ctest`**），末尾汇总 **`Done: N program(s), M failed.`**。若本地路径、gmock 头文件或 Abseil 自带的 googletest 集成脚本在你的环境下报错，再按 CMake 输出逐项调整即可。个别与**时限 / 调度**相关的用例在 **WSL** 上可能偶发失败，可改期再跑一次对照。

## GLFW

源码：<https://github.com/glfw/glfw/archive/refs/tags/3.4.tar.gz>

依赖 **X11**（及可选 Wayland）相关开发包：前文 **debootstrap → chroot → `apt install`** 一节若已安装 **`xorg-dev`** 等并打入 tar，解压后的 **sysroot-focal** 即可供交叉链接使用。（交叉主机侧若无 **`wayland-scanner`**，下文示例关闭 Wayland。）

下面是一套在 **Cygwin + ct-ng + focal sysroot** 下 **配置、编译、运行 `examples/offscreen`** 的完整验证流程；仓库辅助文件在 **`D:\Code\Note\ctng-toolchain-extras`** 与 **`D:\Code\Note\scripts`**。

### 1. sysroot 如何准备

1. **在 WSL 内**按前文 **`pack-sysroot.sh`** 打出 **`sysroot-focal.tar.gz`**（或等价包），拷到 Windows，例如 **`D:\ctng-build\sysroot-focal-packed.tar.gz`**。
2. **解压到工具链前缀下**，使目录树为：
   - **`…/toolchains/x86_64-linux-gnu/x86_64-linux-gnu/sysroot`**（ct-ng 自带，勿覆盖）
   - **`…/toolchains/x86_64-linux-gnu/x86_64-linux-gnu/sysroot-focal`**（debootstrap focal）
   若压缩包顶层是 **`sysroot/`**，解压后应改名为 **`sysroot-focal`**（与同目录 **`extract-sysroot-focal.sh`** 行为一致）。
3. **（强烈建议）软链修正**：在 **Cygwin** 中对 **`sysroot-focal`** 执行 **`port_sysroot.sh --fix-only`**（见前文「解压到工具链旁与软链修正」）。否则 **`usr/lib/x86_64-linux-gnu/libdl.so` → `/lib/...`** 一类绝对路径在 **`--sysroot` + Cygwin** 下容易导致 **`-ldl` 落到 `libdl.a`**，链接共享库时出现 **`__dlopen` / `preinit_array`** 等错误。
4. 将 **`toolchain-focal-sysroot.cmake`** 复制到 **`…/toolchains/x86_64-linux-gnu/`**，与 **`toolchain.cmake`**、**`bin/x86_64-linux-gnu-gcc`** 同级（脚本内用 **`CMAKE_CURRENT_LIST_DIR`** 定位编译器）。

### 2. `toolchain-focal-sysroot.cmake` 为什么不能像 `toolchain.cmake` 那样极简

自带的 **`toolchain.cmake`** 只设 **`CMAKE_FIND_ROOT_PATH`** 指向 ct-ng **内置 sysroot**，交叉 **gcc** 的默认 **`--sysroot`** 本就与之一致，布局也是「非 Ubuntu multiarch」的简单树。

**Ubuntu focal debootstrap** 则是 **multiarch**：**crt** 在 **`usr/lib/x86_64-linux-gnu`**，**glibc 头**依赖 **`usr/include/x86_64-linux-gnu/bits`**。因此 **仅靠 `CMAKE_SYSROOT` + CMake 查找**，链接阶段仍会 **找不到 `crt1.o` / `crti.o`**，编译阶段 **`stdint.h`** 也会 **找不到 `bits/...`**。工具链里 **始终需要**：

- **`-B${_SYS}/usr/lib/x86_64-linux-gnu`**（crt 搜索路径）；
- **`-isystem ${_SYS}/usr/include/x86_64-linux-gnu`**（`bits/` 等多架构头）；
- **`CMAKE_FIND_ROOT_PATH_*`** 与 **`toolchain.cmake`** 相同，避免搜到 Windows 主机库。

可选再加 **`CMAKE_EXE_LINKER_FLAGS` / `CMAKE_SHARED_LINKER_FLAGS`** 里的 **`-Wl,-rpath-link,${_LIB}`**，便于解析依赖 `.so` 的符号。

仓库 **`toolchain-focal-sysroot.cmake`** 当前仅保留上述 **` -B` / `-isystem` / `rpath-link`**；**`-D_REENTRANT`**、**`-pthread` / `-ldl` 拆分**、**`CMAKE_FIND_LIBRARY_SUFFIXES` 优先 `.so`** 等，是在 **`port_sysroot.sh` 尚未修正绝对路径软链**、链接器容易误用 **`libdl.a` / `libpthread.a`** 时的保守写法。**对 sysroot 做完 `--fix-only` 后**，用 **GLFW 3.4** 实测 **共享库 + `offscreen`** 可在 **不含** 这些额外项的情况下完整编过；根因仍是 **`libdl.so` 等指向 `/lib/...` 的绝对软链**，而非「CMake 找不到库」本身。

若换其它工程或 CMake 未正确传递 **`Threads::Threads`** / **`-ldl`**，仍可按需在工具链里恢复 **显式 `-pthread`、`-Wl,-Bdynamic`** 等；若在全局 **`CMAKE_C_FLAGS` 里写 `-pthread`**，仍须留意 **共享库**链接行是否被带上 **`libpthread.a`**（DSO **`.preinit_array`** 一类错误）。

仓库里的 **`toolchain-focal-sysroot-minimal.cmake`**（仅 **`CMAKE_SYSROOT` + `FIND_ROOT_PATH`**）可作对照：**CMake 编译器自检即会因缺少 crt 失败**，证明 **不能**去掉 **`-B` / `-isystem`**。

### 3. CMake 如何配置与编译（Cygwin）

准备 **`scripts/cmake-cross-threads-cache.cmake`**：交叉时 **FindThreads** 的 **try_compile** 常失败，用 **`-C` 预置缓存**更稳。

示例（路径按本机修改；**`RT_LIBRARY`** 指向 **`librt-2.31.so` 真实版本文件**，避免 **`librt.so` 符号链接在 NTFS/Cygwin 上异常**）：

```bash
export PATH="/cygdrive/d/ctng-build/workspace/cross-tools/toolchains/x86_64-linux-gnu/bin:/usr/local/bin:/usr/bin"

TC=/cygdrive/d/ctng-build/workspace/cross-tools/toolchains/x86_64-linux-gnu
SR=$TC/x86_64-linux-gnu/sysroot-focal/usr/lib/x86_64-linux-gnu/librt-2.31.so
CACHE=/cygdrive/d/Code/Note/scripts/cmake-cross-threads-cache.cmake
SRC=/cygdrive/d/ctng-build/workspace/cross-validate/glfw-3.4
BLD=$SRC/build-glfw-focal

cmake -S "$SRC" -B "$BLD" -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE=$TC/toolchain-focal-sysroot.cmake \
  -C "$CACHE" \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON \
  -DRT_LIBRARY="$SR" \
  -DGLFW_BUILD_EXAMPLES=ON \
  -DGLFW_BUILD_TESTS=OFF \
  -DGLFW_BUILD_DOCS=OFF \
  -DGLFW_BUILD_WAYLAND=OFF

cmake --build "$BLD" --target examples/offscreen
```

- **`BUILD_SHARED_LIBS=ON`**：生成 **`libglfw.so`**，链接命令需依赖上文 **共享库 linker flags**。
- 若改为 **`BUILD_SHARED_LIBS=OFF`**：得到 **`libglfw3.a`**，示例可执行文件 **静态链入 GLFW**，在 WSL 运行时 **一般不必再为 `libglfw` 设 `LD_LIBRARY_PATH`**（仍动态依赖 **`libc` / `libdl` / X11 与 GL 等**，后者在 GLFW 里可能以 **`dlopen`** 加载）。

### 4. 在 WSL 里运行 `offscreen`

示例 **`offscreen`** 会生成 **`offscreen.png`**（依赖 OpenGL / GLX；无 GPU 时可 **`export LIBGL_ALWAYS_SOFTWARE=1`**）。

- **共享库版**：可执行文件若带 **Cygwin 下写入的 RPATH（`/cygdrive/d/...`）**，Linux 动态加载器不认，需在 WSL 中设置：
  **`export LD_LIBRARY_PATH=/mnt/d/.../build-glfw-focal/src`**（路径对应你的构建目录）。
- **静态 GLFW 版**：通常可直接运行：
  **`/mnt/d/.../build.../examples/offscreen`**，在工作目录得到 **`offscreen.png`**。

```bash
mkdir -p /tmp/offscreen-test && cd /tmp/offscreen-test
export LD_LIBRARY_PATH=/mnt/d/ctng-build/workspace/cross-validate/glfw-3.4/build-glfw-focal/src
export LIBGL_ALWAYS_SOFTWARE=1
/mnt/d/ctng-build/workspace/cross-validate/glfw-3.4/build-glfw-focal/examples/offscreen
ls -la offscreen.png
```

图形窗口类示例需在 **带图形栈的 WSL / 真机**上验证；**offscreen** 侧重「交叉链接 + 离屏读回」链路。

<!-- 截图：交叉链接成功 + WSL 侧 `offscreen.png` 或 `file offscreen.png` -->

## Qt（5.9.7）

需求：**sysroot 内有 Linux 版 Qt 5.9.7 的头文件与库**；**moc、rcc、uic** 等代码生成工具常在 **构建主机** 上运行，因此实际工程中常见 **「Windows 主机 Qt 工具 + Linux 目标 Qt 库」** 的混搭，版本必须一致（此处固定 **5.9.7**）。

可选思路（待你实践后把可行的一条写死）：

- 使用官方或第三方 **Qt 安装包** 分别安装 Windows 与 Linux 包；
- 或调研 **aqtinstall**（Python）一类工具按版本拉取组件。

> [!NOTE]
>
> **坑点**：Qt 交叉编译的踩坑集中在 **qmake/CMake 的 Qt5_DIR**、**主机工具路径**、以及 **plugins/platforms** 部署；运行时还要保证 WSL 侧 **xcb/wayland** 与 **插件路径** 一致。

<!-- 截图：Qt Creator 或 CMake 日志里 Qt 版本与工具路径解析正确 -->

## Boost（1.55）

源码（官方归档，bz2）：<https://archives.boost.io/release/1.55.0/source/boost_1_55_0.tar.bz2>

老版本 Boost 常用 **`bootstrap.sh` + `b2`**；交叉编译需设置 `toolset` 与 `target-os`，并指向交叉编译器与 sysroot（具体 **`user-config.jam`** 待按工具链前缀补全）。

**统一下载目录（只下一遍）**：将 tarball 放到 **`D:\ctng-build\workspace\cross-validate\archives\`**，供 **WSL chroot**、**WSL 本机**、**Cygwin 交叉** 共用，避免多处重复拉取。仓库脚本 **`scripts/download-boost-1.55-to-cross-validate.sh`** 默认写入上述路径；执行前在 shell 里导出与 **「准备 Cygwin」** 一致的代理（本机长期 **`http://127.0.0.1:7890`**）：

```bash
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890
chmod +x /cygdrive/d/Code/Note/scripts/download-boost-1.55-to-cross-validate.sh
/cygdrive/d/Code/Note/scripts/download-boost-1.55-to-cross-validate.sh
```

若文件已存在，脚本会 **跳过下载**。 tarball 绝对路径示例：**`/cygdrive/d/ctng-build/workspace/cross-validate/archives/boost_1_55_0.tar.bz2`**。

<!-- 截图：`b2` 构建摘要或任意一个小库编译成功日志 -->