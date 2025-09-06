---
title: Conan使用
mathjax: false
abbrlink: '2944'
tags:
  - C++
  - CMake
  - Python
category: C++学习笔记
date: 2025-08-27 21:32:59
---



[Conan](https://conan.io/) 作为一个 C++ 包管理工具，相对于之前介绍的 CMake FetchContent 或者 ExternalProject 方式添加第三方依赖会更加简单，但是<del>凡是碰上了 C++，都简单不到哪去，</del>学习成本还是有一点的，就用一篇笔记介绍一下 Conan 的基本使用。

# 安装 Conan

由于我们后面会大量使用 conanfile.py，且为使用 Python 插件进行 `conanfile.py` 的代码补全，直接使用 pyhton 库的方式安装 conan，使用如下命令进行安装

```bash
python -m pip install conan
```

安装之后例行检查一下版本

```bash
conan --version
```

![image-20250905214611421](Conan使用/image-20250905214611421.png)

<!-- more -->

# Conan 模板项目

通过 `conan new` 命令可以快速创建 c++ 模板项目

对于基于 cmake 的 c++ 程序而言，使用 `cmake_exe` 和 `cmake_lib`，conan 也支持自行指定代码模板，稍后会结合 VS Code 提供一个添加 vscode 支持的 conan cmake 模板。

```bash
conan new cmake_exe -d name=hello-conan
```

执行命令后，其会自动帮我创建好一些必要的文件，如下图所示

![image-20250905215352708](Conan使用/image-20250905215352708.png)

其目录结构如下所示

<img src="Conan使用/image-20250905215605185.png" alt="image-20250905215605185" style="zoom: 80%;" />

c++ 源码和头文件放在 `src` 目录下，同时还生成了一个 test_package 目录，用于测试当前包，但是暂时用不上

# Hello World

之后我们依次输入以下命令，完成样例项目的编译和运行

```bash
conan profile detect --force
conan install . --building=missing
cmake --list-presets
cmake . --preset conan-default
cmake --list-presets build
cmake --build --preset conan-release
cmake --install build --prefix install
./install/bin/hello-conan.exe
```

下面简单介绍一下每一步在做什么

step1（代码行1）：生成编译工具链配置

step2（代码行2）：下载并安装三方库依赖

step3（代码行3~4）：查看当前 cmake configure 预设配置，并进行 configure，生成当前项目的编译配置

step4（代码行5~6）：查看当前 cmake 的编译预设配置，并进行编译

step5（代码行7）：执行 cmake 安装，将可执行文件安装到 `install` 目录

step6（代码行8）：执行程序

最后执行结果输出如下：

<img src="Conan使用/image-20250905222445701.png" alt="image-20250905222445701" style="zoom:67%;" />



# VS Code 支持

目前我们都是使用命令行进行简单的操作，但是真正进行开发的时候还需要IDE的代码提示和调试功能才行，下面也简略介绍一下如何基于 VS Code 配置一个结合 conan 的 c++ 开发环境。

## 安装C++开发插件

- C/C++ Extension Pack
- CMake Tools
- clangd
- CodeLLDB

## 添加自定义 Tasks

> [!TIP]
>
> 如何在 vscode 中添加自定义 task 可以参考 [tasks 使用文档](https://code.visualstudio.com/docs/debugtest/tasks)

通过快捷键 <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd> 打开配置面板，输入 `task`，选择 "***任务：配置任务***"

<img src="Conan使用/image-20250905225129587.png" alt="image-20250905225129587" style="zoom:67%;" />

然后点击 "***使用模板创建 tasks.json 文件***" ，这样就会自动创建一个可用的 tasks.json 

<img src="Conan使用/image-20250905225333434.png" alt="image-20250905225333434" style="zoom: 67%;" />

之后还可以选择 tasks 的模板，这里直接选择 “***Others 运行任意外部命令的示例***”

<img src="Conan使用/image-20250905225957119.png" alt="image-20250905225957119" style="zoom:67%;" />

创建好的模板 tasks.json 内容如下

> [!TIP]
>
> 如果招不到文件入口，也可以直接手动创建 `.vscode/tasks.json` 文件，并复制下列内容

```json
{
    // See https://go.microsoft.com/fwlink/?LinkId=733558
    // for the documentation about the tasks.json format
    "version": "2.0.0",
    "tasks": [
        {
            "label": "echo",
            "type": "shell",
            "command": "echo Hello"
        }
    ]
}
```

根据前一节的操作步骤，可以将其化为3个部分：

- Conan 准备步骤
  - `conan profile detect`
  - `conan install`
- CMake 配置编译步骤
  - `cmake --preset <selected-configure-preset>`
  - `cmake --build --preset <selected-build-preset>`
  - `cmake --install`
- 程序运行
  - `.\hello-conan`

在 VS Code 中已经集成了 CMake 的插件，可以直接读取 Conan 生成好的 CMakePresets.json，进行配置和编译，为此，我们只需要在 Tasks 中编写 Conan 的相关操作即可。

剩下可以直接通过 <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd> 调出命令面板，执行 CMake 相关操作即可，如下图所示

<img src="Conan使用/image-20250906151057744.png" alt="image-20250906151057744" style="zoom:67%;" />

其中

- `CMake: 选择配置预设`  对应命令行 `cmake --list-presets`
- `CMake: 配置` 就对应命令行 `cmake . --preset <selected-configure-preset>`
-  `CMake: 生成` 就对应命令行 `cmake --build --preset <selected-build-preset>`

封装 Conan 工具链检查和依赖安装的 tasks.json 内容如下：

```json5
{
    // See https://go.microsoft.com/fwlink/?LinkId=733558
    // for the documentation about the tasks.json format
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Conan: Detect Profile",
            "type": "shell",
            "command": "conan",
            "args": [
                "profile",
                "detect",
                "--force"
            ],
            "group": "build",
        },
        {
            "label": "Conan: Install Dependency [Debug]",
            "type": "shell",
            "command": "conan",
            "args": [
                "install",
                "-s='build_type=Debug'",
                "-of='${workspaceFolder}/build/Debug'",
                ".",
                "--build=missing"
            ],
            "hide": true
        },
        {
            "label": "Conan: Install Dependency [Release]",
            "type": "shell",
            "command": "conan",
            "args": [
                "install",
                "-s='build_type=Release'",
                "-of='${workspaceFolder}/build/Release'",
                ".",
                "--build=missing"
            ],
            "hide": true
        },
        {
            "label": "CMake: Select Configure Preset",
            "command": "${command:cmake.selectConfigurePreset}",
            "hide": true
        },
        {
            "label": "CMake: Configure",
            "command": "${command:cmake.configure}",
            "hide": true
        },
        {
            "label": "Conan: Install & CMake: Configure",
            "group": "build",
            "dependsOn": [
                "Conan: Install Dependency [Debug]",
                "Conan: Install Dependency [Release]",
                "CMake: Select Configure Preset",
                "CMake: Configure"
            ],
            "dependsOrder": "sequence"
        },
    ],
}
```

我们定义了 6 个 task：

- `Conan: Detect Profile`：对应 `conan profile detect --force`

- `Conan: Install Dependency [Debug]`：对应 `conan install`（安装 Debug 编译模式下的依赖）

- `Conan: Install Dependency [Release]`：对应 `conan install`（安装 Release 编译模式下的依赖）

- `CMake: Select Configure Preset`：通过 `${command:cmake.selectConfigurePreset}` 执行 CMake 插件提供的命令

- `CMake: Configure`：同上，通过 `${command:cmake.configure}` 执行 CMake 插件提供的命令

  > [!NOTE]
  >
  > 这里 `${command:cmake.configure}` 会执行插件提供的命令，并使用命令输出进行字符串替换，中间可能会报错，但是我们的主要目标是在 tasks 中执行 VS Code 的一些命令（有点邪道？），具体可以参考 VS Code 对变量替换的[说明文档](https://code.visualstudio.com/docs/reference/variables-reference#_command-variables)
  >
  > <img src="Conan使用/image-20250906162550232.png" alt="image-20250906162550232" style="zoom: 80%;" />

- `Conan: Install & CMake: Configure`，同时安装 Debug 和 Release 模式下的依赖，并选择预设配置进行生成

 由于我们设置 task 的 group 为 `build`，可以直接通过快捷键 <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>B</kbd> 快速调用（调用生成任务），如下所示

<img src="Conan使用/image-20250906161922307.png" alt="image-20250906161922307" style="zoom:67%;" />

这样，再使用 VS Code 进行开发时，只需要以下 3 个步骤：

- **[可选]** Conan 检测工具链
- **[首次执行/三方库更新时]** Debug / Release 三方库依赖
- 调用 CMake 配置和编译

## 配置 clangd

为了实现多平台统一的开发体验，使用 clangd 进行代码补全，同样，还是需要一系列的配置，这一次主要修改 `.vscode/settings.json`，相关配置如下：

```json5
{
    "editor.tabSize": 2,
    "C_Cpp.intelliSenseEngine": "disabled",
    "C_Cpp.formatting": "clangFormat",
    "clangd.arguments": [
        "--compile-commands-dir=${workspaceFolder}/build",
        "--all-scopes-completion",
        "--background-index",
        "--background-index-priority=background",
        "--clang-tidy",
        "--completion-style=bundled",
        "--header-insertion=never",
        "--pch-storage=disk",
        "-j=8"
    ],
    "cmake.exportCompileCommandsFile": true,
    "cmake.copyCompileCommands": "${workspaceFolder}/build/compile_commands.json",
}
```

其中比较关键的配置项有 4 项：

1. `C_Cpp.intelliSenseEngine`：禁用 C/C++ 插件自带的代码提示引擎，其会和 clangd 冲突，一般在安装 clangd 插件时就会自动提示禁用了

2. `cmake.exportCompileCommandsFile`：设置 cmake 插件在 configure 时导出 `compile_commands.json`，这一步实际上是在 cmake configure 的时候添加 `-DCMAKE_EXPORT_COMPILE_COMMANDS` 选项

   <img src="Conan使用/image-20250906154021456.png" alt="image-20250906154021456" style="zoom: 50%;" /> 

   clangd 依赖 compile_commands.json 进行代码补全

3. `cmake.copyCompileCommandsFile`：将 compile_commands.json 拷贝到指定位置，因为我们目前使用的是 Ninja 进行编译，其是单配置方式，**Debug 模式和 Release 模式的 compile_commands.json 会输出到不同的目录下**，因此需要通过该选项，将不同编译配置下的 compile_commands.json 输出到一个固定位置，便于 clangd 读取

   > [!TIP]
   >
   > 单配置模式：Debug 和 Release 需要单独的 CMake Configure，例如 Make 和 Ninja
   >
   > 多配置模式：Debug 和 Release 可以共用同一套 CMake Configure，例如 Visual Studio 的 Solution

4. `clangd.arguments` ：配置 clangd 如何进行代码补全，具体可以通过 `clangd --help` 查看，这里配置的是个人觉得比较好用的一些配置，其中比较关键的一个是 `--compile-commands-dir=${workspaceFolder}/build`，其指定了 `compile_commands.json` 所在目录，这一个需要与前一个配置的路径相对应，否则 clangd 也会有问题
5. `editor.tabSize` 和 `C_Cpp.formating` 是代码格式化的配置，可根据个人喜好进行配置

填写好相关配置后，可以重启 clangd（同样在命令面板中进行操作）

<img src="Conan使用/image-20250906155307215.png" alt="image-20250906155307215" style="zoom:67%;" />

并在输出中观察 clangd 是否正常工作

<img src="Conan使用/image-20250906155411208.png" alt="image-20250906155411208" style="zoom: 50%;" />

如果看到 clangd 的相关日志有刚才配置好的命令行选项，并成功加载了 compile_commands.json 文件，则说明已经配置完成，可以编写代码了

## 配置调试

还有最后一步—代码调试（已经感觉有点累了，VS Code 的开发环境确实有点难配置了），幸好，这一步只需要集成一下 cmake 的调用命令即可，创建 `.vscode/launch.json`，并填写如下内容

```json
{
  "configurations": [
    {
      "type": "lldb",
      "request": "launch",
      "name": "Launch CMake Target",
      "program": "${command:cmake.launchTargetPath}",
      "args": [],
      "cwd": "${workspaceFolder}"
    }
  ],
}
```

这里我们使用了一个 `${command:cmake.launchTargetPath}` 来获取当前配置的启动程序，就不用每次都修改配置文件了，而且会在启动之前自动完成编译

如果需要使用其他命令，也可以查询插件提供的所有命令（不过当我们需要指定额外的运行参数时，还是之间创建新的 launch target 会更好）

<img src="Conan使用/image-20250906160212000.png" alt="image-20250906160212000" style="zoom:50%;" />



# 添加依赖

到这里，我们就可以开始修改代码（终于进入正题了😓），添加一些想要的依赖了（<del>调包侠 yes！</del>），简单点，使用 Eigen 和 spdlog 做一个简单的矩阵运算吧。

首先在 [conan center](https://conan.io/center) 网站上查询需要使用包的版本

<img src="Conan使用/image-20250905223759007.png" alt="image-20250905223759007" style="zoom: 50%;" />

点击详情后，可以进一步查看如何在 `conanfile.py` 中引入这个包

<img src="Conan使用/image-20250906162906291.png" alt="image-20250906162906291" style="zoom:50%;" />

只需要修改 `conanfile.py`，创建 requirements 函数，并填写依赖即可，对于 spdlog 也是如此。

```python
def requirements(self):
    self.requires("eigen/3.4.0")
    self.requires("spdlog/1.15.3")
```

引入依赖后，需要重新调用一遍 conan install，就会自动下载对应的包了。

为了使用包，还需要更改 CMakeLists.txt，通过 cmake 的 find_package 找到对应的包，将其链接到可执行程序上即可，在指引中也同样有写

<img src="Conan使用/image-20250906163226350.png" alt="image-20250906163226350" style="zoom:50%;" />

```cmake
find_package(Eigen3 REQUIRED)
find_package(spdlog REQUIRED)

target_link_libraries(${PROJECT_NAME} PRIVATE  Eigen3::Eigen spdlog::spdlog)
```

此时重新 configure 后，compile_commands.json 中包含了我们新引入了第三方依赖，就可以通过 clangd 进行代码补全了

<img src="Conan使用/image-20250906163633295.png" alt="image-20250906163633295" style="zoom: 50%;" />

# 自定义 Conan 项目模板

从前面 VS Code 配置过程可以看出，VS Code 作为一个文本编辑器，将其转换成 C++ 的 IDE 需要各种各样的配置，为了简化这一个配置过程，我们可以借助 conan 的模板项目，创建 `cmake_exe-vscode` 和 `cmake_lib-vscode` 的模板，这样我们就可以减少很多的初始化时间，更加专注于代码本身了（想起了前端开发中各种代码模板生成工具）。

> 参考 Conan [创建项目模板文档](https://docs.conan.io/2/reference/commands/new.html#custom-templates)

