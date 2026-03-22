---
title: Conan创建Package
mathjax: true
abbrlink: '7331'
tags:
  - C++
  - CMake
  - Python
category: C++学习笔记
date: 2026-03-21 18:30:31
---



在前一篇[笔记](/posts/2944)中，我们介绍了如何使用 Conan 管理 C++ 程序的依赖，但是 Conan Center 中可用的包较少，我们时常需要自行创建 Conan Package，便于依赖管理。这一篇笔记我们将着重介绍如何通过编写 conanfile.py 创建 Conan Package，并简要介绍 Conan-Center 的 GitHub 仓库是如何维护的。

$\require{physics}$
<!-- more -->

# 基础流程

先给出一个最常用的流程，后面再展开细节：

1. 使用 `conan new` 生成模板项目
2. 修改 `conanfile.py`（包信息、构建、打包、导出依赖信息）
3. 用 `conan create` 在本地构建并生成 Package
4. 用 `test_package` 或单独工程验证该 Package 可用
5. （可选）上传到私有远端，或者按 Conan Center 规范准备仓库


# 生成模板

先准备 Conan 配置：

```bash
conan --version
conan profile detect --force
```

创建一个基于 CMake 的库模板：

```bash
conan new cmake_lib -d name=hello -d version=0.1.0
```

生成后重点看这几个文件：

- `conanfile.py`：配方核心
- `CMakeLists.txt` + `src/` + `include/`：库源码
- `test_package/`：用于验证包是否可被下游工程正确消费


# conanfile.py 最小必备项

这里给一个常见的最小结构（省略了和主题无关的细节）：

```python
from conan import ConanFile
from conan.tools.cmake import CMake, CMakeDeps, CMakeToolchain, cmake_layout


class HelloRecipe(ConanFile):
  name = "hello"
  version = "0.1.0"
  package_type = "library"

  settings = "os", "compiler", "build_type", "arch"
  options = {"shared": [True, False], "fPIC": [True, False]}
  default_options = {"shared": False, "fPIC": True}

  exports_sources = "CMakeLists.txt", "src/*", "include/*"

  def layout(self):
    cmake_layout(self)

  def generate(self):
    deps = CMakeDeps(self)
    deps.generate()
    tc = CMakeToolchain(self)
    tc.generate()

  def build(self):
    cmake = CMake(self)
    cmake.configure()
    cmake.build()

  def package(self):
    cmake = CMake(self)
    cmake.install()

  def package_info(self):
    self.cpp_info.libs = ["hello"]
```

几个最容易踩坑的点：

- `exports_sources` 漏文件会导致 `conan create` 时源码不完整
- `package_info` 里 `self.cpp_info.libs` 名字要和实际生成库名一致
- 如果支持 `shared=True`，Windows 下通常要额外关注符号导出（例如 `__declspec(dllexport/dllimport)`）


# 本地创建 Package

在配方根目录执行：

```bash
conan create . -s build_type=Release --build=missing
```

如果需要区分用户/通道：

```bash
conan create . --user=myteam --channel=stable -s build_type=Release --build=missing
```

`conan create` 会完成这几件事：

1. 导出 recipe 到 Conan cache
2. 拉取并安装依赖
3. 构建和打包
4. 运行 `test_package`（默认模板通常会带）


# 在其他工程中消费

例如在新工程中安装依赖：

```bash
conan install . --requires=hello/0.1.0 --build=missing -s build_type=Release
```

如果你使用了 `user/channel`，引用格式对应为：

```text
hello/0.1.0@myteam/stable
```

然后通过 Conan 生成的 CMake 配置（`CMakeDeps`）做 `find_package` + `target_link_libraries` 即可。


# 上传到私有远端（可选）

如果团队有自建 Artifactory 或 Conan Remote：

```bash
conan remote list
conan upload hello/0.1.0@myteam/stable -r=myremote --confirm
```

注意事项：

- 先确认远端权限（上传/覆盖策略）
- 版本一旦被下游依赖，尽量不要覆盖同版本内容
- 二进制兼容性变化（ABI 变化）建议升级版本号，而不是“偷偷重发”


# Conan Center 仓库维护方式（简述）

Conan Center Index（CCI）本质上是一个 recipe 仓库。每个包通常有类似结构：

```text
recipes/
  <pkg>/
    config.yml
    all/
      conandata.yml
      conanfile.py
      patches/
```

核心思路：

1. 在 `conandata.yml` 中声明源码 URL、校验和、补丁信息
2. 在 `conanfile.py` 中实现跨平台构建逻辑
3. 通过 CI 在多平台、多编译器矩阵下验证可构建与可消费

所以如果你准备贡献到 Conan Center，重点不是“本机能编过”，而是 recipe 是否足够通用、可复现、可维护。


## 维护个人 Conan Index（实践）

我目前维护了一个自己的 index 仓库：

- https://github.com/PureWhiteVK/conan-center-index

这个仓库是从官方 CCI fork 出来的，适合做两类事情：

1. 给个人项目补充 CCI 暂时没有的包
2. 给已有 recipe 打临时补丁（例如编译选项、平台兼容修复）

日常维护建议按下面流程来：

### 1) 定期同步上游

不要长期脱离 `conan-io/conan-center-index`，否则后面冲突会越来越大。

```bash
git remote add upstream https://github.com/conan-io/conan-center-index.git
git fetch upstream
git rebase upstream/master
```

### 2) 新增或更新 recipe

保持 CCI 风格的目录结构（你现在仓库也是这个风格）：

```text
recipes/
  <pkg>/
    config.yml
    all/
      conandata.yml
      conanfile.py
      patches/
```

更新时通常改三类内容：

- `conandata.yml`：源码地址、sha256、补丁声明
- `conanfile.py`：构建逻辑、选项、平台分支
- `config.yml`：版本到目录的映射关系

### 3) 本地先做最小验证

至少先验证一个你实际使用的配置：

```bash
conan create recipes/<pkg>/all --version=<ver> -s build_type=Release --build=missing
```

如果你的项目覆盖多个配置，建议再补一个 Debug 或不同编译器组合。

### 4) CI 通过后再发布二进制

这里有个关键边界要注意：

- **index 仓库存的是 recipe 源码，不是二进制包本体**
- 下游真正安装到的包来自 Conan remote（例如自建 Artifactory）

所以一个常见流程是：

1. 在 index 仓库提交 recipe 变更
2. CI 验证 recipe 可构建
3. 用 `conan upload` 把对应包上传到你的私有 remote

示例：

```bash
conan upload "<pkg>/<ver>*" -r=<your-remote> --confirm
```

### 5) 版本策略尽量保守

对于已被项目引用的版本，建议遵循两条：

- 不覆盖同版本内容（避免下游不可预期）
- 有 ABI 或行为变化时升版本，不做 silent replace

这样后面排查问题会轻松很多。


# 小结

自己创建 Conan Package 的关键其实就三件事：

- recipe 信息完整（`conanfile.py`）
- 本地验证闭环完整（`conan create` + `test_package`）
- 版本与发布策略清晰（尤其是团队协作时）

先把最小可用包跑通，再逐步加选项、平台适配和 CI，是更稳妥的实践路径。

