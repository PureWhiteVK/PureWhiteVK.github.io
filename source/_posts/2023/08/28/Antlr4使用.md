---
title: Antlr4使用
mathjax: false
abbrlink: b5fa
tags:
  - C++
  - CMake
  - ANTLR
  - 编译原理
category: C++学习笔记
date: 2023-08-28 17:02:48
---


# Hello，ANTLR4

ANTLR 是一个用 Java 写的语法分析工具，类似 Lex Yacc 以及 Flex Bison（这两个都有点太老了，而且Windows上也不好用），通过编写一个内嵌代码的文件（`.g4`）来定义文法，然后由 ANTLR 对文件进行分析，生成不同后端的分析程序，例如 C++、Python、Java 等，相比我们手写分析程序，只要我们定义好文法，就可以完成解析过程，提高开发效率。

使用 ANTLR4 的最简单方式就是 Python 了，我们直接通过 pip 安装即可

```bash
pip install antlr4-tools
```

由于 ANTLR 需要 Java ，如果没有安装 Java 环境会在第一次运行时自动安装。

之后我们可以定义一个简单的表达式文法来测试效果

***Expr.g4***

```g4
grammar Expr;		
prog:	expr EOF ;
expr:	expr ('*'|'/') expr
    |	expr ('+'|'-') expr
    |	INT
    |	'(' expr ')'
    ;
NEWLINE : [\r\n]+ -> skip;
INT     : [0-9]+ ;
```

（注意到文法中包含左递归，但是 ANTLR 会自动帮我们处理好）

<!-- more -->

通过下列命令测试文法

```bash
antlr4-parse Expr.g4 prog -tree
```

其命令格式如下

```
java org.antlr.v4.gui.Intrepreter [X.g4|XParser.g4 XLexer.g4] startRuleName
  [-tokens] [-tree] [-gui] [-encoding encodingname]
  [-trace] [-profile filename.csv] [input-filename(s)]
Omitting input-filename makes rig read from stdin.
```

prog 对应于 `startRuleName`

此时会等待我们输入，我们输入一个有效的表达式

```bash
10*(5*2)
```

然后输入 <kbd>Ctrl</kbd> + <kbd>D</kbd>（Unix系统）或者 <kbd>Ctrl</kbd> +<kbd>Z</kbd>（Windows系统）来终止输入，此时就可以看到输出结果

（由于是在 Python 中调用 Java 命令行，可以有点慢）

```bash
10*(4+2) 
^Z
(prog:1 (expr:1 (expr:3 10) * (expr:4 ( (expr:2 (expr:3 5) + (expr:3 2)) ))) <EOF>)
```

可以看到其成功对我们的文法进行分析，并通过嵌套关系表示出语法分析树，这样用只是展示 ANTLR 的分析效果，但是实际我们需要将其和应用集成起来，那么就需要使用 ANTLR 编译文法文件后生成不同语言的分析代码，从而实现高效的分析（最开始本来想用 ANTLR来进行 HTTP 报文的解析的，但是好像有点杀鸡用牛刀的意思，而且其无法支持流式输入，后面就自行写了一个简单的），不过对于 URL 解析或者 MySQL 语句的解析倒是挺好用的。

> [antlr4/doc/getting-started.md at dev · antlr/antlr4 (github.com)](https://github.com/antlr/antlr4/blob/dev/doc/getting-started.md)



# ANTLR4 for CPP

在 C++ 环境中使用 ANTLR4 相对而言较为繁琐，其包含两个步骤

1. 编译文法文件，生成对应的 C++ 解析代码（`Lexer.cpp` 以及 `Parser.cpp`）
2. 链接 ANTLR4 的 C++ 运行库

由于 C++ 本身的特殊性，第一个步骤可以通过命令行手动完成，但是第二个编译过程就很麻烦了，不过官方也给出了样例代码：

> [antlr4/runtime/Cpp/README.md at dev · antlr/antlr4 (github.com)](https://github.com/antlr/antlr4/blob/dev/runtime/Cpp/README.md)

一般而言，只需要将 `<ANTLR4_ROOT>/runtime/Cpp/cmake` 文件夹中的 `FindANTLR.cmake` 以及 `ExternalAntlr4Cpp.cmake` 拷贝到项目本地，然后在 `CMakeLists.txt` 中 `include` 进来即可

示例如下

```cmake
// 将两个 .cmake 文件放在 cmake 文件夹下
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

// 设置编译 ANTLR4 的一些选项，MSVC CRT链接方式（MT/MD）、静态/动态链接库等
// 设置所需要的 ANTLR4 版本（此处选择最新版）
set(ANTLR4_TAG 4.13.0)
// 添加外部依赖，通过 ExternalProject_Add 方式实现
// 其默认会创建 static 和 shared 两种库，可以自行选择需要的库进行链接
include(ExternalAntlr4Cpp)

// 对于第二个步骤，FindANTLR.cmake 提供 antlr_target 宏来自动化编译文法文件的过程，其使用示例如下
antlr_target(
	ExprParser Expr.g4 PARSER LEXER
  PACKAGE parser
)
// 其会自动生成对应语言的分析代码，同时输出三个 cmake 变量，我们可以将其添加到编译目标中
add_executable(demo main.cpp)
target_sources(demo PRIVATE ${ANTLR_ExprParser_CXX_OUTPUTS})
target_include_directories(demo PRIVATE ${ANTLR_ExprParser_OUTPUT_DIR})

// 最后连接到 antlr 的 cpp runtime 即可
target_link_libraries(demo PRIVATE antlr4_static)
```



个人在使用过程中感觉整个过程用起来有点别扭，主要有两个地方

1. 使用 `ExternalAntlr4Cpp` 时并没有为我们创建 ALIAS 目标（即 `glm::glm` 这种，可以防止拼写错误问题），并且在编译时才会触发下载，无法提前代码状态（因为其使用的是 `ExternalProject_Add`）
2. 通过 `antlr_target` 方式添加的目标也仅在编译过程中才会创建，没编译前也是什么都没有，这样我们就不知道什么时候编译出错了，我们可能想将其作为源代码的一部分进行管理（因为其使用的是 `add_custom_command` 实现，在编译时才会执行）。

针对官方提供集成方案的两个缺点，我们参考官方集成方案进行一些修改，将 `ExternalProject_Add` 替换为 `FetchContent` 实现，同时通过 `execute_process` 方式替换 `add_custom_command`，使得在每次重新配置时都会触发下载。



# 自行实现的 ANTLR4 集成方式

### FetchContent 下载依赖

思路很简单，就是下载 + `add_subdirectory` 的老套路，不过 ANTLR4 比较坑的是动态链接库和静态链接库的处理上， 需要添加很多处理来保证编译正确（主要是 Windows 恶心人的 `__declspec(dllexport)` 以及 `__declspec(dllimport)`），而在 ANTLR4 的原始 CMakeLists.txt 设置有点问题（主要是宏定义的可见范围设置有误）

*<ANTLR4_ROOT>/runtime/Cpp/runtime/CMakeLists.txt*（L120~132）

```cmake
if (WIN32)
  set(static_lib_suffix "-static")
  if (TARGET antlr4_shared)
    target_compile_definitions(antlr4_shared PUBLIC ANTLR4CPP_EXPORTS)
  endif()
  if (TARGET antlr4_static)
    target_compile_definitions(antlr4_static PUBLIC ANTLR4CPP_STATIC)
  endif()
  if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    set(extra_share_compile_flags "-MP /wd4251")
    set(extra_static_compile_flags "-MP")
  endif()
endif()
```

其中问题就出在 `target_compile_definitions(antlr4_shared PUBLIC ANTLR4CPP_EXPORTS)` 上。

这个宏的作用就是控制 Windows DLL导出/DLL导入的，代码位于 

*<ANTLR4_ROOT>/runtime/Cpp/runtime/src/antlr4-common.h*（L54~62）

```c
#ifdef ANTLR4CPP_EXPORTS
  #define ANTLR4CPP_PUBLIC __declspec(dllexport)
#else
  #ifdef ANTLR4CPP_STATIC
    #define ANTLR4CPP_PUBLIC
  #else
    #define ANTLR4CPP_PUBLIC __declspec(dllimport)
  #endif
#endif
```

可以看到，当启用 `ANTLR4CPP_EXPORTS` 时就会开启 dllexport，而没启用且不是静态链接就是 `dllimport`.

但设置为 PUBLIC 时会在所有的编译单元中都启用该宏，导致编译 `main.cpp` 的时候会提示LINK2019错误，也就是找不到符号（当然找不到，本来应该是 import 的变成了 export，怎么可能找得到符号呢）。

这个问题改起来也很简单，只需要将 `PUBLIC` 改成 `PRIVATE` 即可（可以向官方提 ISSUE），在 `ExternalAntlr4Cpp.cmake` 中给出了解决方案（不知道为什么不直接修改这个代码）

通过创建 `IMPORTED` 的 target 并将该 target 私有链接到原有的库，就可以避免 `ANTLR4CPP_EXPORTS` 传递到我们的业务代码中了。

```cmake
add_library(antlr4_shared SHARED IMPORTED)
add_dependencies(antlr4_shared antlr4_runtime-build_shared)
set_target_properties(
	antlr4_shared PROPERTIES
  IMPORTED_LOCATION ${ANTLR4_RUNTIME_LIBRARIES})
target_include_directories(antlr4_shared
    INTERFACE ${ANTLR4_INCLUDE_DIRS}
)

if(ANTLR4_SHARED_LIBRARIES)
  set_target_properties(
  	antlr4_shared PROPERTIES
    IMPORTED_IMPLIB ${ANTLR4_SHARED_LIBRARIES}
  )
endif()
```

不过 CMake 在使用 IMPORTED target 时比较恶心，需要手动指定链接库的位置，这个也在 `ExternalAntlr4Cpp.cmake` 中写死了（感觉不太优雅，不过能跑就行吧）

了解官方的解决方案后，我们自行编写起来就简单很多了

`add-antlr4.cmake`

```cmake
function(add_antlr4 TAG)
  set(ANTLR_OPTIONS SHARED WITH_STATIC_CRT WITH_LIBCXX DISABLE_WARNINGS)
  set(ANTLR_ONE_VALUE_ARGS "")
  set(ANTLR_MULTI_VALUE_ARGS "")
  cmake_parse_arguments(ANTLR4CPP
                        "${ANTLR_OPTIONS}"
                        "${ANTLR_ONE_VALUE_ARGS}"
                        "${ANTLR_MULTI_VALUE_ARGS}"
                        ${ARGN})
  include(CMakePrintHelpers)
  FetchContent_Declare(
    antlr4_cpp
    GIT_REPOSITORY https://github.com/antlr/antlr4
    GIT_TAG ${TAG}
    GIT_SHALLOW TRUE
  )
  FetchContent_Populate(antlr4_cpp)

  set(antlr4_cpp_SOURCE_DIR 
    ${antlr4_cpp_SOURCE_DIR}/runtime/Cpp
    CACHE INTERNAL ""
  )

  # 可以从 VERSION 中读取到版本信息
  file(STRINGS ${antlr4_cpp_SOURCE_DIR}/VERSION ANTLR_VERSION)
  cmake_print_variables(ANTLR_VERSION)
  cmake_print_variables(ANTLR4CPP_WITH_STATIC_CRT)
  cmake_print_variables(ANTLR4CPP_WITH_LIBCXX)
  cmake_print_variables(ANTLR4CPP_DISABLE_WARNINGS)
  cmake_print_variables(ANTLR4CPP_SHARED)

  set(WITH_DEMO FALSE CACHE INTERNAL "")
  set(WITH_STATIC_CRT ${ANTLR4CPP_WITH_STATIC_CRT} CACHE INTERNAL "")
  set(WITH_LIBCXX ${ANTLR4CPP_WITH_LIBCXX} CACHE INTERNAL "")
  set(DISABLE_WARNINGS ${ANTLR4CPP_DISABLE_WARNINGS} CACHE INTERNAL "")
  set(ANTLR4_INSTALL FALSE CACHE INTERNAL "")
  set(ANTLR_BUILD_CPP_TESTS FALSE CACHE INTERNAL "")
  set(ANTLR4_INCLUDE_DIRS 
    ${antlr4_cpp_SOURCE_DIR}/runtime/src 
    CACHE INTERNAL "")
  set(ANTLR4_OUTPUT_DIR 
    ${antlr4_cpp_BINARY_DIR}/runtime 
    CACHE INTERNAL ""
  )

  if(ANTLR4CPP_SHARED)
    set(ANTLR_BUILD_SHARED TRUE CACHE INTERNAL "")
    set(ANTLR_BUILD_STATIC FALSE CACHE INTERNAL "")
  else()
    set(ANTLR_BUILD_SHARED FALSE CACHE INTERNAL "")
    set(ANTLR_BUILD_STATIC TRUE CACHE INTERNAL "")
  endif()

  # from https://github.com/antlr/antlr4/blob/dev/runtime/Cpp/cmake/ExternalAntlr4Cpp.cmake
  if(MSVC)
    set(ANTLR4_STATIC_LIBRARIES
      ${ANTLR4_OUTPUT_DIR}/antlr4-runtime-static.lib CACHE INTERNAL "")
    set(ANTLR4_SHARED_LIBRARIES
      ${ANTLR4_OUTPUT_DIR}/antlr4-runtime.lib CACHE INTERNAL "")
    set(ANTLR4_RUNTIME_LIBRARIES
      ${ANTLR4_OUTPUT_DIR}/antlr4-runtime.dll CACHE INTERNAL "")
  else()
    set(ANTLR4_STATIC_LIBRARIES
      ${ANTLR4_OUTPUT_DIR}/libantlr4-runtime.a CACHE INTERNAL "")
    if(MINGW)
      set(ANTLR4_SHARED_LIBRARIES
        ${ANTLR4_OUTPUT_DIR}/libantlr4-runtime.dll.a CACHE INTERNAL "")
      set(ANTLR4_RUNTIME_LIBRARIES
        ${ANTLR4_OUTPUT_DIR}/libantlr4-runtime.dll CACHE INTERNAL "")
    elseif(CYGWIN)
      set(ANTLR4_SHARED_LIBRARIES
        ${ANTLR4_OUTPUT_DIR}/libantlr4-runtime.dll.a CACHE INTERNAL "")
      set(ANTLR4_RUNTIME_LIBRARIES
        # https://github.com/antlr/antlr4/pull/2235#discussion_r173871830
        # due to cmake: https://cmake.org/cmake/help/latest/prop_tgt/SOVERSION.html
        ${ANTLR4_OUTPUT_DIR}/cygantlr4-runtime-${ANTLR_VERSION}.dll CACHE INTERNAL "")
    elseif(APPLE)
      set(ANTLR4_RUNTIME_LIBRARIES
        ${ANTLR4_OUTPUT_DIR}/libantlr4-runtime.dylib CACHE INTERNAL "")
    else()
      set(ANTLR4_RUNTIME_LIBRARIES
        ${ANTLR4_OUTPUT_DIR}/libantlr4-runtime.so CACHE INTERNAL "")
    endif()
  endif()

  add_subdirectory(
    ${antlr4_cpp_SOURCE_DIR} 
    ${antlr4_cpp_BINARY_DIR}
  )

  if(ANTLR4CPP_SHARED)
    add_library(antlr4_runtime_shared SHARED IMPORTED)
    target_include_directories(antlr4_runtime_shared
      INTERFACE ${ANTLR4_INCLUDE_DIRS}
    )
    set_target_properties(antlr4_runtime_shared 
      PROPERTIES
      IMPORTED_LOCATION ${ANTLR4_RUNTIME_LIBRARIES}
    )
    set_target_properties(antlr4_runtime_shared 
      PROPERTIES
      IMPORTED_IMPLIB ${ANTLR4_SHARED_LIBRARIES}
    )
    add_library(antlr4::antlr4_shared ALIAS antlr4_runtime_shared)
  else()
    target_include_directories(antlr4_static INTERFACE ${ANTLR4_INCLUDE_DIRS})
    add_library(antlr4::antlr4_static ALIAS antlr4_static)
  endif()

endfunction(add_antlr4)
```

其中我们指定了一些参数

- `TAG`：Antlr 的版本（可以使用 git commit id 以及 tag）

- `SHARED` ：是否使用动态链接库

- `WITH_STATIC_CRT`：静态 CRT（MSVC编译flag为 `-MT` / `-MTd`），默认是动态 CRT （MSVC编译flag为 `-MD` / `-MDd`，这样我们就需要安装 vcredist）

- `WITH_LIBCXX`：在 unix 下是否连接到 libcxx，相当于一种另外的 c++ 运行库（对应的还有 libstdc++）

- `DISABLE_WARNINGS`：很简单，是否开启警告（我们在编译 Windows 动态链接库时就发现 W4275）

  [编译器警告（等级 2）C4275 | Microsoft Learn](https://learn.microsoft.com/zh-cn/cpp/error-messages/compiler-warnings/compiler-warning-level-2-c4275?view=msvc-170)

  不是什么大问题，但是很多，因为 ANTLR4 Runtime 的 所有异常都继承自 `std::exception`，但是 MSVC 会提示 `std::exception` 并不是 DLL导出的，可能存在问题。



对于第二个，我们的修改很少，就是调整 `add_custom_command` 为 `execute_process`，这样在每次进行 cmake 配置时就会生成，便于 debug。

完整代码

`add-antlr4-parser.cmake`

```cmake
function(add_antlr4_parser TARGET_NAME INPUT_FILE)
  set(ANTLR_OPTIONS LEXER PARSER LISTENER VISITOR)
  set(ANTLR_ONE_VALUE_ARGS NAMESPACE OUTPUT_DIRECTORY)
  set(ANTLR_MULTI_VALUE_ARGS GENERATE_FLAGS)
  cmake_parse_arguments(ANTLR_TARGET
                        "${ANTLR_OPTIONS}"
                        "${ANTLR_ONE_VALUE_ARGS}"
                        "${ANTLR_MULTI_VALUE_ARGS}"
                        ${ARGN})
  include(CMakePrintHelpers)
  set(ANTLR_${TARGET_NAME}_INPUT ${INPUT_FILE})

  cmake_path(GET INPUT_FILE STEM ANTLR_INPUT)

  if(ANTLR_TARGET_OUTPUT_DIRECTORY)
    set(ANTLR_${TARGET_NAME}_OUTPUT_DIR ${ANTLR_TARGET_OUTPUT_DIRECTORY})
  else()
    set(ANTLR_${TARGET_NAME}_OUTPUT_DIR
        ${CMAKE_CURRENT_BINARY_DIR}/antlr4cpp_generated_src/${ANTLR_INPUT})
  endif()

  unset(ANTLR_${TARGET_NAME}_CXX_OUTPUTS)

  if((ANTLR_TARGET_LEXER AND NOT ANTLR_TARGET_PARSER) OR
      (ANTLR_TARGET_PARSER AND NOT ANTLR_TARGET_LEXER))
    list(APPEND ANTLR_${TARGET_NAME}_CXX_OUTPUTS
          ${ANTLR_${TARGET_NAME}_OUTPUT_DIR}/${ANTLR_INPUT}.h
          ${ANTLR_${TARGET_NAME}_OUTPUT_DIR}/${ANTLR_INPUT}.cpp)
    set(ANTLR_${TARGET_NAME}_OUTPUTS
        ${ANTLR_${TARGET_NAME}_OUTPUT_DIR}/${ANTLR_INPUT}.interp
        ${ANTLR_${TARGET_NAME}_OUTPUT_DIR}/${ANTLR_INPUT}.tokens)
  else()
    list(APPEND ANTLR_${TARGET_NAME}_CXX_OUTPUTS
          ${ANTLR_${TARGET_NAME}_OUTPUT_DIR}/${ANTLR_INPUT}Lexer.h
          ${ANTLR_${TARGET_NAME}_OUTPUT_DIR}/${ANTLR_INPUT}Lexer.cpp
          ${ANTLR_${TARGET_NAME}_OUTPUT_DIR}/${ANTLR_INPUT}Parser.h
          ${ANTLR_${TARGET_NAME}_OUTPUT_DIR}/${ANTLR_INPUT}Parser.cpp)
    list(APPEND ANTLR_${TARGET_NAME}_OUTPUTS
          ${ANTLR_${TARGET_NAME}_OUTPUT_DIR}/${ANTLR_INPUT}Lexer.interp
          ${ANTLR_${TARGET_NAME}_OUTPUT_DIR}/${ANTLR_INPUT}Lexer.tokens)
  endif()

  if(ANTLR_TARGET_LISTENER)
    list(APPEND ANTLR_${TARGET_NAME}_CXX_OUTPUTS
          ${ANTLR_${TARGET_NAME}_OUTPUT_DIR}/${ANTLR_INPUT}BaseListener.h
          ${ANTLR_${TARGET_NAME}_OUTPUT_DIR}/${ANTLR_INPUT}BaseListener.cpp
          ${ANTLR_${TARGET_NAME}_OUTPUT_DIR}/${ANTLR_INPUT}Listener.h
          ${ANTLR_${TARGET_NAME}_OUTPUT_DIR}/${ANTLR_INPUT}Listener.cpp)
    list(APPEND ANTLR_TARGET_GENERATE_FLAGS -listener)
  endif()

  if(ANTLR_TARGET_VISITOR)
    list(APPEND ANTLR_${TARGET_NAME}_CXX_OUTPUTS
          ${ANTLR_${TARGET_NAME}_OUTPUT_DIR}/${ANTLR_INPUT}BaseVisitor.h
          ${ANTLR_${TARGET_NAME}_OUTPUT_DIR}/${ANTLR_INPUT}BaseVisitor.cpp
          ${ANTLR_${TARGET_NAME}_OUTPUT_DIR}/${ANTLR_INPUT}Visitor.h
          ${ANTLR_${TARGET_NAME}_OUTPUT_DIR}/${ANTLR_INPUT}Visitor.cpp)
    list(APPEND ANTLR_TARGET_GENERATE_FLAGS -visitor)
  endif()

  if(ANTLR_TARGET_NAMESPACE)
    list(APPEND ANTLR_TARGET_GENERATE_FLAGS -package ${ANTLR_TARGET_NAMESPACE})
  endif()

  list(APPEND ANTLR_${TARGET_NAME}_OUTPUTS ${ANTLR_${TARGET_NAME}_CXX_OUTPUTS})

  execute_process(
      COMMAND ${Java_JAVA_EXECUTABLE} -jar ${ANTLR_EXECUTABLE}
              ${INPUT_FILE}
              -o ${ANTLR_${TARGET_NAME}_OUTPUT_DIR}
              -no-listener
              -Dlanguage=Cpp
              ${ANTLR_TARGET_GENERATE_FLAGS}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  )
  cmake_policy(SET CMP0140 NEW)
  return(PROPAGATE 
    ANTLR_${TARGET_NAME}_OUTPUT_DIR 
    ANTLR_${TARGET_NAME}_CXX_OUTPUTS 
    ANTLR_${TARGET_NAME}_OUTPUTS
  )
endfunction(add_antlr4_parser)
```

由于我们在 configure 过程中进行生成，删除了几个不必要的配置，调用参数含义如下：

- `TARGET_NAME`: 指定文法名词，例如 `ExprParser`

- `INPUT_FILE`：对应的文法文件，例如 `Expr.g4`

- `LEXER`、`PARSER`、`LISTENER`、`VISITOR` 都是 BOOL 类型，表示是否开启对应的代码生成

  lexer 对应词法分析器，parser 对应语法分析其，listener 和 visitor 是用来遍历语法树的两种方式（当然也可以自行实现语法树的遍历）

- `NAMESPACE`：生成的分析器所属命名空间，例如 `parser`，对应的语法分析器就是 `parser::ExprParser` 

- `OUTPUT_DIRECTORY`：生成的代码输出路径，例如我们可以将其输出到源代码文件夹 `${CMAKE_CURRENT_SOURCE_DIR}`

- `GENERATE_FLAGS`：一些其他的 antlr 文法生成参数，前面的足够使用了， 这个一般用不到

调用实例如下

```cmake
add_antlr4_parser(
  CalculatorParser Calculator.g4 
  LEXER PARSER 
  NAMESPACE parser
  OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/parser
)
```



# 杂项

目前网上除了 ANTLR4 的 github 的文档外，官方文档上信息很少，要想真正深入学习 ANTLR 的使用还是得看 ANTLR 作者写的那本书 ANTLR 4权威指南，不过网上的 pdf 版本还很多，也有中文版，基本上取代了文档的位置（连基本的 g4 文件 grammar 都是书上讲的清楚一点，唉！）

