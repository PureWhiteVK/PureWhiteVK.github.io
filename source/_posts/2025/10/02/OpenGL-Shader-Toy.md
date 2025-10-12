---
title: OpenGL Shader Toy
mathjax: true
abbrlink: 7ced
date: 2025-10-02 22:44:50
tags:
  - 计算机图形学
  - OpenGL
  - C++
category:
  - 计算机图形学
---


# Hello, Shader Toy

Shader（着色器）简单来说就是**运行在 GPU 上的一小段程序**，用来控制图形渲染的方式。

> 在传统渲染管线中，GPU 会自动执行一套固定流程，但 shader 的出现让开发者能够自定义这些流程，从而实现更灵活和更复杂的图形效果。

[Shader Toy](https://www.shadertoy.com/) 是一个在线的 Shader 变成和展示网站，可以展示实时的 Shader 编程效果。

<img src="OpenGL-Shader-Toy/image-20251002231848342.png" alt="image-20251002231848342" style="zoom: 33%;" />

在图形 API （OpenGL）中，支持多种 Shader 类型：

- Vertex Shader（顶点着色器）
- Tessellation Shader（细分着色器）
- Geometry Shader（几何着色器）
- Fragment Shader（片段着色器）
- Compute Shader（计算着色器）

而在 Shader Toy 中的 Shader 特指 Fragment Shader，其输入的是一个覆盖整个显示区域的四边形，可以在 Fragment Shader 中决定显示区域中每一个像素的颜色（rgba）。

<!-- more -->

# Full Screen Triangle

由于 OpenGL 中会自动进行 clipping（丢弃不在显示区域内的 fragment），在绘制的是并不需要真的绘制一个四边形（两个三角形），而是通过一个大的三角形覆盖屏幕区域即可，在 NDC 坐标下，屏幕坐标的范围是 $[-1,1]^2$，可以通过一个巨大的直角三角形覆盖，如下 $\triangle{AEF}$ 所示：

其三个顶点坐标分别是：
$$
\begin{align}
A&=(-1,-1)\\
E&=(3,-1)\\
F&=(-1,3)
\end{align}
$$


<img src="OpenGL-Shader-Toy/image-20251002232417558.png" alt="image-20251002232417558" style="zoom: 33%;" />

使用这样一个三角形，还有一个好处就是无需准备额外的 VBO（但是还是需要 VAO），直接将三角形的顶点坐标写在 Shader 代码里即可，如下所示：

*shader_toy.vert*

```glsl
#version 330 core
// one giant triangle that covers the screen
const vec2 gridPlane[3] = vec2[3](
  vec2(-1.0,-1.0),
  vec2( 3.0,-1.0),
  vec2(-1.0, 3.0)
);

void main() {
  vec2 p = gridPlane[gl_VertexID];
  gl_Position = vec4(p,0.0, 1.0); // using directly the clipped coordinates
}
```

通过 `gl_VertexID` 可以拿到当前顶点在 VBO 的 index，如果仅绘制一个三角形，则 `gl_VertexID` 的取值就是 $[0,1,2]$，对应三角形三个顶点。

此处拿到三角形的顶点坐标后，直接通过 `gl_Position` 输出 NDC 坐标即可，对于 z 坐标，其取值并不重要，这里就直接设为 0 了。

> [!Tip]
>
> 通过 `glDrawArrays(GL_TRIANGLES, 0, 3);` 即可绘制单个三角形，但是还是需要提前分配一个空的 Vertex Array。



# Example Fragment Shader 

下面给出了一个最简单的 Fragment Shader 效果，根据 Vertex Shader 的输出，其是一个大三角形，覆盖整个屏幕，那么最简单的 Fragment Shader 就是坐标和颜色对应起来，例如 $(x,y,z) = (r,g,b)$，将 x 坐标值赋值为

> [!Tip]
>
> 在 Fragment Shader 中 `gl_FragCoord.xy` 已经是经过 透视除法，clipping 和 viewport transform 后得到的坐标，其取值范围是 $[0,w]\times[0,h]$，而 Fragment Shader 中要求输出的颜色值范围是 $[0,1]$，将其除以 frame buffer 大小就得到 $[0,1]$ 范围的坐标。

*shader_toy.frag*

```glsl
#version 330 core
out vec4 FragColor;
uniform vec2 framebuffer_size;
void main()
{
  vec2 coord = gl_FragCoord.xy / framebuffer_size;
  FragColor = vec4(coord,0.0,1.0);
}
```

其作用就是读取每一个 Fragment 的坐标值，将其归一化后可视化出来。

可视化效果如下（未经过 gamma 矫正）

<img src="OpenGL-Shader-Toy/image-20251002232755482.png" alt="image-20251002232755482" style="zoom:40%;" />





# Live Preview

在 Shader Toy 中，还有一个重要的功能就是实时预览，当我们修改 Fragment Shader 后，会自动编译 Shader 并将变化展示在网页上。

在 OpenGL 中也可以实现类似的功能，如下图所示，左边是 Shader 的代码编辑窗口，右边是实时预览的 OpenGL 程序。

（代码在 [这里](https://github.com/PureWhiteVK/OpenGL-Examples/blob/main/src/imgui-demo/shader_toy.cpp)）

<img src="OpenGL-Shader-Toy/image-20251012133552643.png" alt="image-20251012133552643" style="zoom: 33%;" />

## 整体流程

包含两个线程，主线程用来进行 OpenGL 渲染和展示，文件监控线程用来监控文件变更并及时同时主线程重新加载 Shader。

下面展示了整个监控过程的时序图：

<img src="OpenGL-Shader-Toy/live-preview.drawio-0249527.png" alt="live-preview.drawio" style="zoom: 40%;" />

1. 在主线程启动时同时启动监控线程，监控线程此时尚未设置监控文件，等待中；
2. 用户操作设置实时预览的 Shader 文件，主线程发送消息给监控线程，设置待监控的文件；
   - 监控线程接收到消息后，开始监控文件系统变化；
3. 用户更改 Shader 文件，监控线程捕获到文件变更事件，发送消息给主线程，通知文件变更情况；
   - 主线程接受到消息后，重新编译 Shader 并进行预览；

4. 停止监控时，主线程发送停止监控消息给监控线程；
   - 监控线程接收到消息后，移除文件监控事件，停止文件监控。





