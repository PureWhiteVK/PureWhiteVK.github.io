---
title: 内存分析工具（4）：malloc性能测试
mathjax: false
abbrlink: '5645'
date: 2024-09-20 21:03:16
tags:
category:
---


这篇博客主要是对自定义实现内存泄漏检查工具进行的一个性能测试，对比启用内存泄漏检查后的性能损失情况，同时检查是否有误报情况

参考的是 [daanx/mimalloc-bench: Suite for benchmarking malloc implementations. (github.com)](https://github.com/daanx/mimalloc-bench) 仓库



选择的场景

- barnes
- cfrac
- espresso
- larsonN
- glibc-simple and glibc-thread （benchmark for glibc）
- sh6bench
- sh8benchN
- xmalloc-testN

<!-- more -->

首先主要介绍编译过程

对比 valgrind，asan 和 自行实现的 memtracer 效果



