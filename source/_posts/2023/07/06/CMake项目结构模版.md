---
title: CMake项目结构模版
mathjax: false
abbrlink: d235
date: 2023-07-06 20:35:20
tags:
- C++
- CMake
category: C++学习笔记
---


# 整体结构

```txt
.
├── .gitignore
├── .gitmodules
├── CMakeLists.txt
├── LICENSE
├── README.md
├── build
├── cmake
│   ├── CMakeLists.txt
│   └── ...
├── data
│   ├── .gitkeep
│   └── ...
├── extern
│   ├── CMakeLists.txt
│   └── ...
├── src
│   ├── CMakeLists.txt
│   ├── glad
│   ├── lumos
│   └── stb
└── test
    ├── CMakeLists.txt
    ├── test_gl.cpp
    ├── test_imageio.cpp
    ├── test_imgui.cpp
    ├── test_pcg.cpp
    ├── test_random_permutation.cpp
    └── test_viewer.cpp
```

<!-- more -->

含义：

- `CMakeLists.txt`：组织项目的源代码，不会包含具体的编译细节，仅包含项目的声明、跨平台控制等，示例如下：

  ```cmake
  cmake_minimum_required(VERSION 3.20.0)
  project(Lumos)
  
  # used with command `cmake -DENABLE_TESTING=ON -B build -S .`
  # Define an option with default value OFF (disabled)
  option(ENABLE_TESTING "Enable testing" OFF)
  
  cmake_path(SET DATA_PATH NORMALIZE ${PROJECT_SOURCE_DIR}/data)
  
  add_subdirectory(cmake)
  add_subdirectory(extern)
  add_subdirectory(src)
  
  if (ENABLE_TESTING)
    enable_testing()
    add_subdirectory(test)
  endif()
  ```

- `src`、`test`、`extern` 分别代表源代码、测试代码以及第三方依赖库，每一个都会包含各自的 `CMakeLists.txt`，用来管理代码，对于 `src` 中的库代码（自定义的 library），个人推荐将头文件（`.h`）和源代码文件 （`.cpp`） 分开放，同时 include 目录时设定好文件夹层级，示例如下：

  ```
  .
  ├── CMakeLists.txt
  ├── core
  │   ├── CMakeLists.txt
  │   ├── include
  │   │   └── lumos
  │   │       └── core
  │   └── src
  └── gui
      ├── CMakeLists.txt
      ├── include
      │   └── lumos
      │       └── gui
      └── src
  ```

  这样做稍微有点繁琐，但是代码的组织逻辑比较清晰

  对于 `extern` 文件夹，其用来添加第三方依赖，推荐使用 `git submodule` 来管理版本，下载时使用 `git clone --recursive <repo-url>` 即可。

# 依赖管理

## 添加 submodule

```bash
git submodule add <repo-url> <local-submodule-path>
```

例如

```bash
git submodule add https://github.com/ocornut/imgui.git extern/imgui
```



## 使用指定 commit

为确保代码稳定性，我们可能需要使用特定版本的代码，例如 imgui 中我们想使用 tag 为 `v1.89.7-docking`，我们需要进入 submodule 目录手动切换一下

```bash
cd extern/imgui
git checkout v1.89.7-docking
```

当我们提交后 github 就会默认链接到该 repo 对应的 commit 了



## 删除 submodule

在 git 中删除 submodule 较为繁琐，没有一个直接删除的方法，参考网上的操作大概有以下5个步骤：

1. 删除子模块目录

   ```bash
   rm -rf extern/imgui
   ```

2. 删除 `.git` 的缓存

    ```bash
    git rm --cached extern/imgui
    ```

3. 删除 `.gitmodules` 中对应的子模块

   ```
   [submodule "extern/imgui"]
   	path = extern/imgui
   	url = https://github.com/ocornut/imgui.git
   ```

4. 删除 `.git/config` 中相应条目

    ```bash
    [core]
        repositoryformatversion = 0
        filemode = true
        bare = false
        logallrefupdates = true
        ignorecase = true
        precomposeunicode = true
    ...
[submodule "extern/imgui"]
	url = https://github.com/ocornut/imgui.git
...
5. 删除 `.git` 中子模块目录

    ```bash
    rm -rf .git/modules/extern/imgui
    ```

   

   

# 个人偏好命名方式

命名方式有很多，选择自己喜欢的就行，关键在于**统一**

**文件名**

小写下划线，例如 `image_utils.h`，`imgae_utils.cpp`

**命名空间**

小写（尽量不要添加下划线，使用子命名空间即可），例如 `lumos::xxx`，`lumos::core::xxx`

**类名**

首字母大写驼峰命名，对于全部大写的当成单词仅首字母大写，例如 `HTML` 写成 `Html`，`RGBA` 写成 `Rgba`

函数 

**类函数名**

对于 `public / protected` 方法而言使用首字母大写驼峰命名，例如 `Initialize`，对于 `private` 方法使用首字母小写驼峰命名，例如 `createContext`

**类变量**

全部以 `m_` 开头，小写下划线，例如 `m_handle`

**变量名**

小写下划线，例如 `image_data`

**常量**

全部大写，例如 `BUFFER_SIZE`

**cmake文件名**

以 `-` 连接，例如 `add-imgui.cmake`

**cmake函数名**

小写下划线（类似于 cmake 的函数命名方式），例如 `add_imgui`
