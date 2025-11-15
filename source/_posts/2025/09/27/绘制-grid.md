---
title: 绘制 grid
mathjax: true
abbrlink: b93d
tags:
  - 线性代数
  - 计算机图形学
  - OpenGL
  - C++
category: 计算机图形学
date: 2025-10-12 16:29:06
---


# Grid 绘制方式

之前一直想知道各种三维软件中虚拟网格是怎么绘制的，就上网搜了一下相关实现，没想到里面小细节还挺多的，就用一篇博客记录一下吧 ( •̀ ω •́ )。

下图展示了 blender 中网格的效果：

![image-20250928224630319](绘制-grid/image-20250928224630319.png)

从图中可以看到几个基本特征：

1. 网格绘制在世界坐标系下的底面（在一般的右手系坐标系中，Z轴向上，X轴向前，Y轴向右），则对应 XY 平面；

   ![xyz_coordinate_frame](绘制-grid/xyz_coordinate_frame.png)

2. x 轴标记为红色 $(1,0,0)$，y轴标记为 $(0,1,0)$

3. 按照固定间隔绘制网格

<!-- more -->



# 绘制二维网格

1. 在世界坐标系下添加一个超级大的三维实体平面（例如 100x100 的平面），再通过网格图样生成平面的 texture，完成网格的绘制

2. 在屏幕空间中绘制虚拟平面，在虚拟平面上绘制网格图样。

其实第一种和第二种的思路都差不多，关键在于找到网格所在平面，并在平面上绘制网格样式。

两种方式最终都会回到网格图样的绘制，那么我们先考虑如何在二维平面上绘制网格。在二维平面上绘制东西，这不是又回到了 [之前介绍的 Shader Toy](https://purewhitevk.github.io/posts/7ced/) 吗，在那篇文章中也通过 Shader Toy 展示了二维网格的绘制效果，但并没有介绍其绘制的原理，这次就详细介绍一下具体是如何绘制的。

<img src="绘制-grid/image-20251012133552643.png" alt="image-20251012133552643" style="zoom:40%;" />



## 绘制直线

网格是由一条一条平行于坐标轴的直线构成的，每条直线的函数都类似于 $y=1$ 和 $x=2$ 这种。但要在二维空间中绘制 $x=1$ 这条直线，除了函数定义外，还需要指定直线的宽度，例如宽度为 1个像素、2个像素，又或者是相对于屏幕宽度的百分比（例如 $0.1\%$）等。

设直线的宽度为 $w$，我们要绘制的实际上是由 $x=1-{w}/{2}$ 和 $x=1+w/2$  两条直线所围成的区域，即满足如下分段函数形式：
$$
\text{draw\_line}(x) = 
\begin{cases}
1, & 1-\frac{w}{2} \le x \le 1 + \frac{w}{2} \\[4pt]
0, & \text{else}
\end{cases}
$$
而在绘制直线时，只需要根据 draw_line 的函数值进行绘制即可，值为 1 时绘制直线，值为0 时不绘制。

对于 $x=1,w=0.02$，直线的可视化效果如下：

<img src="绘制-grid/image-20251012231207527.png" alt="image-20251012231207527" style="zoom:67%;" />

其中 eq1 为目标直线 $x=1$，eq2 $x=0.99$ 和 eq3 $x=1.01$ 为实际用于判断的边界直线。

对应到 fragment shader 中，直接根据 draw_line 的函数结果进行绘制即可，代码如下：

*2d_line.frag*

```glsl
#version 330 core
out vec4 FragColor;
uniform vec2 framebuffer_size;

void main()
{
  vec2 coord = gl_FragCoord.xy / framebuffer_size;
  float target_coord = 0.5;
  float line_width = 0.01;
  float draw_line = float(coord.x >= target_coord - line_width * 0.5 && coord.x <= target_coord + line_width * 0.5);
  FragColor = vec4(draw_line,0.0,0.0,1.0);
}
```

其在 $x=0.5$ 处绘制了一条宽度为 $0.01$ 的直线，此处宽度是相对于屏幕宽度而言的（其实际像素宽度为  $\text{screen\_width} * 0.01$），在不同的 framebuffer 大小下，直线的宽度会随之发生变化。

<img src="绘制-grid/image-20251012232908442.png" alt="image-20251012232908442" style="zoom:50%;" />

如果需要将其宽度为像素宽度，只需要在计算前将 line_width 的单位从像素切换称百分比即可，如下所示：

*2d_line_fixed_width.frag*

```glsl
#version 330 core
out vec4 FragColor;
uniform vec2 framebuffer_size;

void main()
{
  vec2 coord = gl_FragCoord.xy / framebuffer_size;
  float target_coord = 0.5;
  float line_width = 1 / framebuffer_size.x;
  float draw_line = float(coord.x >= target_coord - line_width * 0.5 && coord.x <= target_coord + line_width * 0.5);
  FragColor = vec4(draw_line,0.0,0.0,1.0);
}
```

其中 `1 / framebuffer_size.x` 就是将像素宽度转换成百分比宽度，这样就可以确保直线的宽度不随 frame buffer 大小改变了。



## 绘制网格

前面展示了在 $[0,1]^2$ 区域内绘制





# 回到三维

## 反推世界坐标

## 深度消隐



# 抗锯齿



# 完整代码

## Shader 部分

*vertex shader*

*fragment shader*

## DrawCall 部分

需要准备好一系列的控制参数，再通过一条 DrawCall 进行绘制

