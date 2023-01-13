---
title: hexo自定义插件
mathjax: false
tags:
  - hexo
  - pandoc
  - node.js
  - lua
category: 学习笔记
abbrlink: 9a20
date: 2023-01-05 12:20:55
---
<!-- more -->

大概要介绍的内容

- hexo自定义插件方式（以及一个简单的示例，日志输出、颜色输出）
- 自行实现 hexo-renderer-pandoc
  - pandoc ，调用参数
  - node.js 通过 Spawn 命令调用 pandoc 通过stdin提供输出，stderr输出错误，stdout输出数据
  - Pandoc Lua Filter 基本格式，通过Lua filter 实现图片链接的替换

# 参考

1. [插件 | Hexo](https://hexo.io/zh-cn/docs/plugins)
2. [wzpan/hexo-renderer-pandoc: A pandoc-markdown-flavor renderer for hexo. (github.com)](https://github.com/wzpan/hexo-renderer-pandoc)
3. [Child process | Node.js v18.13.0 Documentation (nodejs.org)](https://nodejs.org/docs/latest-v18.x/api/child_process.html#child_processspawncommand-args-options)
4. [moxystudio/node-cross-spawn: A cross platform solution to node's spawn and spawnSync (github.com)](https://github.com/moxystudio/node-cross-spawn)
5. [Pandoc - Pandoc Lua Filters](https://pandoc.org/lua-filters.html)
6. [wlupton/pandoc-lua-logging: Pandoc lua filter logging support (github.com)](https://github.com/wlupton/pandoc-lua-logging)
7. [Lua 5.4 Reference Manual - contents](http://www.lua.org/manual/5.4/)

