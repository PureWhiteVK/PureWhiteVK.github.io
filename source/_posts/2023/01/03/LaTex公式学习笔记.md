---
title: LaTex公式学习笔记
mathjax: true
abbrlink: caff
date: 2023-01-03 14:09:39
tags:
- mathjax
- LaTex
category: Hexo使用记录
---


之前我们已经配置好了 hexo 对 LaTex 公式的支持（在 markdown 的 Front Matter 中添加 `mathjax: true` 开启 LaTex 公式渲染支持），支持两种形式的公式输入

- 内联公式（inline），通过 `$...$` 进行包裹（必须在同一行）

  例：markdown 代码 `$\phi = 30$` 对应内联公式渲染结果 $\phi = 30$ 

  在 `$` 和公式之间不能存在空格，也就是说，对于`$ \phi = 30 $` 并不能得到正确的渲染结果

- 块公式（block），通过 `$$...$$` 进行包裹（两个`$$`必须在不同行）

  例：markdown 代码

  ```latex
  $$
  \int _0 ^\pi \sin(x) = 2
  $$
  ```

  对应块渲染结果
  $$
  \int _0 ^ \pi \sin x = 2
  $$

现在我们可以在 markdown 文档中添加并渲染公式了，那么下一步就是如何正确书写公式，以及一些常用公式符号。

<!-- more -->

# 常用符号

可以使用在线的[LaTex公式编辑器](https://www.latexlive.com/)来手动选取，下面列举了一些常用的符号

## 关系和运算符号

$$
\begin{align}
& < & & \mathtt{<} & 
& \leq & & \mathtt{\backslash leq} & 
& \ll & & \mathtt{\backslash ll} & 
\\
& > & & \mathtt{>} & 
& \geq & & \mathtt{\backslash geq} & 
& \gg & & \mathtt{\backslash gg} & 
\\
\\
& \in & & \mathtt{\backslash in} &
& \subset & & \mathtt{\backslash subset} & 
& \subseteq & & \mathtt{\backslash subseteq} &
\\
& \ni & & \mathtt{\backslash ni} &
& \supset & & \mathtt{\backslash supset} & 
& \supseteq & & \mathtt{\backslash supseteq} &
\\
& \notin & & \mathtt{\backslash notin} &
\\
\\
& = & & \mathtt{=} &
& \neq & & \mathtt{\backslash neq} &
& \equiv & & \mathtt{\backslash equiv} &
\\
& \approx & & \mathtt{\backslash approx} &
& \propto & & \mathtt{\backslash propto} &
\\
\\
& \parallel & & \mathtt{\backslash parallel} &
& \nparallel & & \mathtt{\backslash nparallel} &
& \sim & & \mathtt{\backslash sim} &
\\
& \perp & & \mathtt{\backslash perp} &
\\
\\
& + & & \text{+} &
& - & & \text{-} &
& \star & & \mathtt{\backslash star} &
\\
& \times & & \mathtt{\backslash times} &
& \div & & \mathtt{\backslash div} &
& \cdot & & \mathtt{\backslash cdot} &
\\
& \cup & & \mathtt{\backslash cup} &
& \cap & & \mathtt{\backslash cap} &
& \ast & & \mathtt{\backslash ast} &
\\
& \vee & & \mathtt{\backslash vee} &
& \wedge & & \mathtt{\backslash wedge} &
& \oplus & & \mathtt{\backslash oplus} &
\\
& \otimes & & \mathtt{\backslash otimes} &
& \ominus & & \mathtt{\backslash ominus} &
& \odot & & \mathtt{\backslash odot} &
\end{align}
$$



## 箭头符号

$$
\begin{align}
& \leftarrow & & \mathtt{\backslash leftarrow} &
& \rightarrow & & \mathtt{\backslash rightarrow} &
\\ 
& \uparrow & & \mathtt{\backslash uparrow} &
& \downarrow & & \mathtt{\backslash downarrow} &
\\ 
& \updownarrow & & \mathtt{\backslash updownarrow} &
& \leftrightarrow & & \mathtt{\backslash leftrightarrow} &
\\
\\ 
& \nwarrow & & \mathtt{\backslash nwarrow} &
& \nearrow & & \mathtt{\backslash nearrow} &
\\ 
& \swarrow & & \mathtt{\backslash swarrow} &
& \searrow & & \mathtt{\backslash searrow} &
\\ 
\\
& \mapsto & & \mathtt{\backslash mapsto} &
& \rightleftharpoons & & \mathtt{\backslash rightleftharpoons} &
\\
& \leftharpoonup & & \mathtt{\backslash leftharpoonup} &
& \rightharpoonup & & \mathtt{\backslash rightharpoonup} &
\\
& \leftharpoondown & & \mathtt{\backslash leftharpoondown} &
& \rightharpoondown & & \mathtt{\backslash rightharpoondown} &
\\
\\ 
& \longleftarrow & & \mathtt{\backslash longleftarrow} &
& \longrightarrow & & \mathtt{\backslash longrightarrow} &
\\ 
& \longleftrightarrow & & \mathtt{\backslash longleftrightarrow} &
& \longmapsto & & \mathtt{\backslash longmapsto} &
\\
\\
& \Leftarrow & & \mathtt{\backslash Leftarrow} &
& \Rightarrow & & \mathtt{\backslash Rightarrow} &
\\ 
& \Uparrow & & \mathtt{\backslash Uparrow} &
& \Downarrow & & \mathtt{\backslash Downarrow} &
\\ 
& \Updownarrow & & \mathtt{\backslash Updownarrow} &
& \Leftrightarrow & & \mathtt{\backslash Leftrightarrow} &
\\
& \Longleftarrow & & \mathtt{\backslash Longleftarrow} &
& \Longrightarrow & & \mathtt{\backslash Longrightarrow} &
\\ 
& \Longleftrightarrow & & \mathtt{\backslash Longleftrightarrow} &
\end{align}
$$



注：当我们需要表示当且仅当关系是常用 `\Longleftrightarrow` ，为了简写，也可以使用 `\iff` （if and only if, 当且仅当) 来简化 



## 希腊字母

$$
\begin{align}
&\alpha & & \mathtt{\backslash alpha}&  
&\beta & & \mathtt{\backslash beta}& 
&\gamma & & \mathtt{\backslash gamma}& 
\\
&\delta & & \mathtt{\backslash delta}& 
&\epsilon & & \mathtt{\backslash epsilon}& 
&\zeta & & \mathtt{\backslash zeta}& 
\\
&\eta & & \mathtt{\backslash eta}& 
&\theta & & \mathtt{\backslash theta}& 
&\iota & & \mathtt{\backslash iota}& 
\\
&\kappa & & \mathtt{\backslash kappa}& 
&\lambda & & \mathtt{\backslash lambda}& 
&\mu & & \mathtt{\backslash mu}& 
\\
&\nu & & \mathtt{\backslash nu}& 
&\xi & & \mathtt{\backslash xi}& 
&\omicron & & \mathtt{\backslash omicron}& 
\\
&\pi & & \mathtt{\backslash pi}& 
&\rho & & \mathtt{\backslash rho}& 
&\sigma & & \mathtt{\backslash sigma}& 
\\
&\tau & & \mathtt{\backslash tau}& 
&\upsilon & & \mathtt{\backslash upsilon}& 
&\phi & & \mathtt{\backslash phi}& 
\\
&\chi & & \mathtt{\backslash chi}& 
&\psi & & \mathtt{\backslash psi}& 
&\omega & & \mathtt{\backslash omega}& 
\\
\\
& \varepsilon & & \mathtt{\backslash varepsilon} &
& \vartheta & & \mathtt{\backslash vartheta} &
& \varpi & & \mathtt{\backslash varpi} &
\\
& \varrho & & \mathtt{\backslash varrho} &
& \varsigma & & \mathtt{\backslash varsigma} &
& \varphi & & \mathtt{\backslash varphi} &
\\
& \varkappa & & \mathtt{\backslash varkappa} &
\\
\\
&\Gamma & & \mathtt{\backslash Gamma}&  
& \Lambda & & \mathtt{\backslash Lambda} & 
&\Sigma & & \mathtt{\backslash Sigma}&  
\\
& \Psi & & \mathtt{\backslash Psi} & 
&\Delta & & \mathtt{\backslash Delta}&  
& \Xi & & \mathtt{\backslash Xi} & 
\\
&\Upsilon & & \mathtt{\backslash Upsilon}&  
& \Omega & & \mathtt{\backslash Omega} & 
&\Theta & & \mathtt{\backslash Theta}&  
\\
& \Pi & & \mathtt{\backslash Pi} & 
&\Phi & & \mathtt{\backslash Phi}&  
\end{align}
$$



## 三角函数

$$
\begin{align}
&\sin& &\mathtt{\backslash sin}& 
&\cos& &\mathtt{\backslash cos}& 
\\
&\tan& &\mathtt{\backslash tan}& 
&\cot& &\mathtt{\backslash cot}& 
\\
&\sec& &\mathtt{\backslash sec}& 
&\csc& &\mathtt{\backslash csc}& 
\\
\\ 
&\arcsin& &\mathtt{\backslash arcsin}& 
&\arccos& &\mathtt{\backslash arccos}& 
\\
&\arctan& &\mathtt{\backslash arctan}& 
\\
\\
&\sinh& &\mathtt{\backslash sinh}& 
&\cosh& &\mathtt{\backslash cosh}& 
\\
&\tanh& &\mathtt{\backslash tanh}& 
&\coth& &\mathtt{\backslash coth}& 
\\
\end{align}
$$



## 其他符号

$$
\begin{align}
& \infty & & \mathtt{\backslash infty} &
& \Re & & \mathtt{\backslash Re} &
\\
& \forall & & \mathtt{\backslash forall} &
& \exists & & \mathtt{\backslash exists} &
\\
& \nexists & & \mathtt{\backslash nexists} &
& \emptyset & & \mathtt{\backslash emptyset} &
\\
& \varnothing & & \mathtt{\backslash varnothing} &
& \top & & \mathtt{\backslash top} &
\\
& \partial & & \mathtt{\backslash partial} &
& \nabla & & \mathtt{\backslash nabla} &
\end{align}
$$



## 标识符号

有时我们可能需要在字母上添加上标（例如平均数 $\bar{x}$，估计值 $\hat{x}$ 等），下标（下划线 $\underline{x}$ ）等

| Code                  | Result                | Code                 | Result               |
| --------------------- | --------------------- | -------------------- | -------------------- |
| `a'` or `a^{\prime}`  | $a'$                  | `a''`                | $a''$                |
| `\hat{a}`             | $\hat{a}$             | `\bar{a}`            | $\bar{a}$            |
| `\acute{a}`           | $\acute{a}$           | `\check{a}`          | $\check{a}$          |
| `\grave{a}`           | $\grave{a}$           | `\dot{a}`            | $\dot{a}$            |
| `\mathring{a}`        | $\mathring{a}$        | `\breve{a}`          | $\breve{a}$          |
| `\tilde{a}`           | $\tilde{a}$           | `\vec{a}`            | $\vec{a}$            |
| `\underline{a}`       | $\underline{a}$       | `\overline{a}`       | $\overline{a}$       |
| `\overrightarrow{AB}` | $\overrightarrow{AB}$ | `\overleftarrow{AB}` | $\overleftarrow{AB}$ |
| `\widehat{AB}`        | $\widehat{AB}$        | `\widetilde{AB}`     | $\widetilde{AB}$     |



## 括号

常见的括号 `()`、中括号 `[]`、以及大括号 `{}` 都可以直接在键盘中输入，由于大括号在 LaTex 中的特殊含义（用来包裹一段公式），我们使用时需要添加 `\` 进行转义，即 `\{` 和 `\}`

对于竖线 `|` ，我们可以直接从键盘中输入，也可以使用 `\mid` 来表示，双竖线（范数的表示）可以使用 `\|` 来表示（不能使用两个竖线，因为双竖线应该表示为一个字符），示例如下

```latex
\|x\|_2
```

$$
\|x\|_2
$$



其他分隔符表示如下
$$
\begin{align}
& / & & \mathtt{/} & 
& \backslash & & \mathtt{\backslash backslash} & 
\\
& \langle & & \mathtt{\backslash langle} & 
& \rangle & & \mathtt{\backslash rangle} & 
\\
& \lceil & & \mathtt{\backslash lceil} & 
& \rceil & & \mathtt{\backslash rceil} & 
\\
& \lfloor & & \mathtt{\backslash lfloor} & 
& \rfloor & & \mathtt{\backslash rfloor} & 
\end{align}
$$

当我们使用这些括号包裹一个大的公式时，如下所示

```latex
(\frac{x^2}{y^3})
```

$$
(\frac{x^2}{y^3})
$$

我们可以发现这个括号（parentheses）不能完全的包裹住公式，此时我们需要使用 `\left(...\right)` 来自动调整括号的大小

```latex
\left(\frac{x^2}{y^3}\right)
```

$$
\left(\frac{x^2}{y^3}\right)
$$

除此之外，在中间表示时还可以使用 `\middle` 来进行控制（条件概率时）

```latex
P\left(A=2\middle|\frac{A^2}{B}>4\right)
```

$$
P\left(A=2\middle| \frac{A^2}{B}>4\right)
$$

而对于花括号（curly braces）和方括号（brackets）时，需要使用转义符进行转义 `\{`

```latex
\left\{\frac{x^2}{y^3}\right\}
```

$$
\left\{\frac{x^2}{y^3}\right\}
$$

我们还可以使用 `.` 来忽略左侧或右侧符号

```latex
\left. \frac{x^3}{3} \right| _0 ^1
```

$$
\left.\frac{x^3}{3}\right|_0^1
$$

最终，如果我们还是不满意，可以手动调整符号的大小

```latex
( \big( \Big( \bigg( \Bigg(
```

$$
( \big( \Big( \bigg( \Bigg(
$$





## 空格

如果我们直接在公式中输入空格，如果直接在字母中间插入空格，会被直接忽略掉，如果我们明确需要插入空格，需要通过指令形式显式给出，在 LaTex 中空格相关的指令总结如下

| 指令           | 描述                 | 示例                                        |
| -------------- | -------------------- | ------------------------------------------- |
| （space）      | 默认空格             | $abc \rightarrow \leftarrow abc$            |
| `\,`           | 短空格(3/18 em)      | $abc \rightarrow\,\leftarrow abc$           |
| `\!`           | 短负空格(-3/18 em)   | $abc \rightarrow \! \leftarrow abc$         |
| `!:`           | 中空格(4/18 em)      | $abc \rightarrow\:\leftarrow abc$           |
| `!;`           | 大空格(5/18 em)      | $abc \rightarrow\;\leftarrow abc$           |
| `\enspace`     | 0.5字宽空格 (0.5 em) | $abc \rightarrow\enspace\leftarrow abc$     |
| `\quad`        | 1字宽空格(1 em)      | $abc \rightarrow\quad\leftarrow abc$        |
| `\qquad`       | 2字宽空格(2 em)      | $abc \rightarrow\qquad\leftarrow abc$       |
| `\hspace{3em}` | 自定义宽度空格       | $abc \rightarrow\hspace{3em}\leftarrow abc$ |

注：em 是一种长度单位，和 px 意义，但是其是相对字宽来度量的，1 em 就表示一个字宽

空格在积分公式的书写上十分有用，如果我们直接写的话，如下所示

```latex
\int y \mathrm{d} x
```

$$
\int y \mathrm{d} x
$$

我们可以看到被积函数 $y$ 和微元 $\mathrm{d}x$ 之间距离太短，看起来不是很自然，此时我们就可以在二者之间插入一个小的空白，如下所示

```latex
\int y \,\mathrm{d} x
```

$$
\int y \,\mathrm{d} x
$$

这样看起来就十分自然了。

另外一个示例就是分段函数的表示

```latex
$$
f(n) = 
\begin{cases}
n / 2 & \quad \text{if } n \text{ is even} \\
-(n+1)/2 & \quad \text{if } n \text{ is odd}
\end{cases}
$$
```

$$
f(n) = 
\begin{cases}
n / 2 & \quad \text{if } n \text{ is even} \\
-(n+1)/2 & \quad \text{if } n \text{ is odd}
\end{cases}
$$



# 字体

| Name                    | Command         | Example          |
| ----------------------- | --------------- | ---------------- |
| Upright Roman Font      | `\mathrm{}`     | $\mathrm{x}$     |
| Normal Italic Font      | `\mathnormal{}` | $\mathnormal{x}$ |
| Calligraphic Font       | `\mathcal{}`    | $\mathcal{X}$    |
| Upright Roman Boldface  | `\mathbf{}`     | $\mathbf{x}$     |
| Upright Sans Serif      | `\mathsf{}`     | $\mathsf{x}$     |
| Italic Font             | `\mathit{}`     | $\mathit{x}$     |
| Typewritter Font        | `\mathtt{}`     | $\mathtt{x}$     |
| Blackboard Bold Font    | `\mathbb{}`     | $\mathbb{X}$     |
| Eular Calligraphic Font | `\mathscr{}`    | $\mathscr{X}$    |
| Fraktur(Gothic) Font    | `\mathfrak{}`   | $\mathfrak{X}$   |

注：

1. Calligraphic 表示书法体（花体），Euler Calligraphic 为欧拉手稿字体
2. Sans Serif 表示非衬线字体（不包含其他多余的笔画）
3. Boldface 表示粗体
4. Typewriter Font 是等宽字体
5. 如果不加任何标注，默认的字体就是 Normal Italic Font，也就是 Roman 字体的斜体形式，如 $hello$



# 常用公式写法

## 三角函数

```latex
\cos (2\theta) = \cos^2 \theta - \sin^2 \theta
```

$$
\cos (2\theta) = \cos^2 \theta - \sin^2 \theta
$$

## 极限

```latex
\lim\limits_{x \to \infty} \exp(-x) = 0
```

$$
\lim\limits_{x \to \infty} \exp(-x) = 0
$$

`\limits` 指令将后续紧跟的上标 `^` 和下标 `_` 放置在当前符号的上方（不写的其实也可以正常渲染，但是加上比较符合我们的观察）

## 取模

```latex
\begin{align}
& a \bmod b \\
& x \equiv a \pmod{b} 
\end{align}
```

$$
\begin{align}
& a \bmod b \\
& x \equiv a \pmod{b} 
\end{align}
$$

## 上下标

通过 `_` 表示下标，`^` 表示上标，如果需要将一块一整体进行上标，需要使用 `{}`  进行包裹

```latex
\begin{align}
n^{22} & \\
k_{n+1} & = n^2 + k_n^2 - k_{n-1} \\
f(n) & = \left. n^5 + 4n^2 + 2 \right|_{n=17}
\end{align}
```

$$
\begin{align}
n^{22} & \\
k_{n+1} & = n^2 + k_n^2 - k_{n-1} \\
f(n) & = \left. n^5 + 4n^2 + 2 \right|_{n=17}
\end{align}
$$

## 分数和二项式系数

使用 `\frac{numerator}{denominator}` 来表示分数（numerator表示分子，denominator表示分母）

```latex
\frac{n!}{k!(n-k)!} = \binom{n}{k}
```

$$
\frac{n!}{k!(n-k)!} = \binom{n}{k}
$$

分数也可以进行嵌套

```latex
\frac{\frac{1}{x}+\frac{1}{y}}{y-z}
```

$$
\frac{\frac{1}{x}+\frac{1}{y}}{y-z}
$$

为了在一行表示分数，我们也可以将分数表示为斜线形式

```latex
^3/_7 \quad 3 / 7
```


$$
^3/_7 \quad 3 / 7
$$
使用 `\frac{...}{...}` 我们也可以表示其他内容，例如乘法和加法公式

```latex
\frac{
	\begin{array}[b]{r}
		\left( x_1 x_2 \right) \\
		\times \left( x'_1 x'_2 \right)
	\end{array}
}{
	\left( y_1 y_2 y_3 y_4 \right)
}
```

$$
\frac{
	\begin{array}[b]{r}
		\left( x_1 x_2 \right)\\
		\times \left(x'_1 x'_2\right)
	\end{array}
}{
	\left( y_1y_2y_3y_4 \right)
}
$$

其中对齐公式使用的 `\align` 以及 `\begin{}...\end{}`  会单独进行详细地介绍。

## 根式

使用 `\sqrt{...}` 来表示根号，默认为2，也可以指定为其他幂次，通过`\sqrt[n]{}` 来指定

```latex
\sqrt[n]{1 + x + x^2 + x^3 +\cdots + x^n}
```


$$
\sqrt[n]{1+x+x^2+x^3+\cdots+x^n}
$$

## 求和、乘积与积分

通过 `\sum _{} ^{} {}` 来表示大型加法表达式，如下

```latex
$$
\sum _{i=1} ^{\infty} x^i
$$
```

$$
\sum _{i=1} ^{\infty} x^i
$$

对于连乘也是类似 `\prod _{} ^{} {}` 来表示大型乘法表达式，如下

```latex
$$
\prod _{i=1} ^{n} x^i
$$
```

$$
\prod _{i=1} ^{n} x^i
$$

积分（integral），通过 `\int _{} ^{} {}` 来表示积分符号

```latex
$$
\int _{0} ^{\pi} \sin x \,\mathrm{d}x
$$
```

$$
\int _{0} ^{\pi} \sin x \,\mathrm{d}x
$$

除了一重积分外，我们还有各种各样的积分符号，如二重积分、三重积分、曲面积分等等，其使用的积分符号也有相应的变化

```latex
$$
\begin{align}
& \iint \limits _V \mu(u,v) \,\mathrm{d}u\,\mathrm{d}v
\\
& \iiint \limits _V \mu(u,v,w) \,\mathrm{d}u\,\mathrm{d}v\,\mathrm{d}w
\\
& \iiiint \limits _V \mu(t,u,v,w) \,\mathrm{d}t\,\mathrm{d}u\,\mathrm{d}v\,\mathrm{d}w
\\
& \idotsint \limits _V \mu(u_1,\dots,u_k) \,\mathrm{d}u_1 \dots \mathrm{d}u_k
\end{align}
$$
```

$$
\begin{align}
& \iint \limits _V \mu(u,v) \,\mathrm{d}u\,\mathrm{d}v
\\
& \iiint \limits _V \mu(u,v,w) \,\mathrm{d}u\,\mathrm{d}v\,\mathrm{d}w
\\
& \iiiint \limits _V \mu(t,u,v,w) \,\mathrm{d}t\,\mathrm{d}u\,\mathrm{d}v\,\mathrm{d}w
\\
& \idotsint \limits _V \mu(u_1,\dots,u_k) \,\mathrm{d}u_1 \dots \mathrm{d}u_k
\end{align}
$$



## 矩阵

对于矩阵而言，需要使用 `\begin{}...\end{}` 来包裹（对齐）

普通矩阵

```latex
$$
\begin{matrix}
1 & 2 & 3\\
a & b & c
\end{matrix}
$$
```

$$
\begin{matrix}
1 & 2 & 3\\
a & b & c
\end{matrix}
$$

括号矩阵（`pmatrix`）

```latex
$$
\begin{pmatrix}
1 & 2 & 3\\
a & b & c
\end{pmatrix}
$$
```

$$
\begin{pmatrix}
1 & 2 & 3\\
a & b & c
\end{pmatrix}
$$

方括号矩阵（`bmatrix`）

```latex
$$
\begin{bmatrix}
1 & 2 & 3\\
a & b & c
\end{bmatrix}
$$
```

$$
\begin{bmatrix}
1 & 2 & 3\\
a & b & c
\end{bmatrix}
$$

花括号矩阵（`Bmatrix`）

```latex
$$
\begin{Bmatrix}
1 & 2 & 3\\
a & b & c
\end{Bmatrix}
$$
```

$$
\begin{Bmatrix}
1 & 2 & 3\\
a & b & c
\end{Bmatrix}
$$

竖线矩阵（`vmatrix`）

```latex
$$
\begin{vmatrix}
1 & 2 & 3\\
4 & 5 & 6\\
7 & 8 & 9
\end{vmatrix}
$$
```

$$
\begin{vmatrix}
1 & 2 & 3\\
4 & 5 & 6\\
7 & 8 & 9
\end{vmatrix}
$$

双数竖线矩阵（`Vmatrix`）

```latex
$$
\begin{Vmatrix}
1 & 2 & 3\\
4 & 5 & 6\\
7 & 8 & 9
\end{Vmatrix}
$$
```

$$
\begin{Vmatrix}
1 & 2 & 3\\
4 & 5 & 6\\
7 & 8 & 9
\end{Vmatrix}
$$

我们也可以使用其他分界符搭配 `\left ... \right` 来构造其他形式，例如

```latex
$$
\left\langle
\begin{matrix}
1 & 2 & 3\\
a & b & c
\end{matrix}
\right\rangle
$$
```

$$
\left\langle
\begin{matrix}
1 & 2 & 3\\
a & b & c
\end{matrix}
\right\rangle
$$

如果想在一行显示矩阵，我们可以使用 `smallmatrix` 布局

```latex
$ \big(\begin{smallmatrix}
  a & b\\
  c & d
\end{smallmatrix}\big)$
```

这一行包含矩阵公式：$\big(\begin{smallmatrix}a&b\\c&d\end{smallmatrix}\big)$

注：在 markdown 中，内联公式必须在同一行

(但是这一行不是很好写捏:(



# 公式的对齐

## 对齐显示

使用 `align` 来表示多行对齐公式（还有一个 `align` ，其效果和 `align` 类似，只不过二者使用场景不一样，在 markdown 需要对齐的话使用 `align` 基本就可以了），使用 `\\` 来换行，`&` 来指示需要对齐的位置

```latex
$$
\begin{align}
A & = \frac{\pi r^2}{2} \\
  & = \frac{1}{2} \pi r^2
\end{align}
$$
```

$$
\begin{align}
A & = \frac{\pi r^2}{2} \\
  & = \frac{1}{2} \pi r^2
\end{align}
$$

这样就可以在等号处对齐了。

我们也可以使用 `align` 实现表格式的对齐，示例如下：

```latex
$$
\begin{align}
f(x) = a x^2 + b x + c \quad  g(x) = d x^3 \\
f'(x) = 2 a x + b  \quad g'(x) = 3 d x ^2 
\end{align}
$$
```

$$
\begin{align}
f(x) = a x^2 + b x + c \quad  g(x) = d x^3 \\
f'(x) = 2 a x + b  \quad g'(x) = 3 d x ^2 
\end{align}
$$

我们的目标是将两个公式分别在等号处对齐。

首先观察一下其对齐情况，可以看到两行公式目前在末尾处是对齐的，这就相当于我们在末尾加上了一个 `&`

```latex
$$
\begin{align}
f(x) = a x^2 + b x + c \quad  g(x) = d x^3 & \\
f'(x) = 2 a x + b  \quad g'(x) = 3 d x ^2 &
\end{align}
$$
```

$$
\begin{align}
f(x) = a x^2 + b x + c \quad  g(x) = d x^3 & \\
f'(x) = 2 a x + b  \quad g'(x) = 3 d x ^2 &
\end{align}
$$

如果用表格来描述这个公式，如下所示

|                                $\Rightarrow$ | `&`  |
| -------------------------------------------: | :--: |
| $f(x) = a x^2 + b x + c \quad  g(x) = d x^3$ |      |
|  $f'(x) = 2 a x + b  \quad g'(x) = 3 d x ^2$ |      |

如果我们想要公式在第一个等于号时对齐，那么在等号前加上 `&`，如下

```latex
$$
\begin{align}
f(x) &= a x^2 + b x + c \quad  g(x) = d x^3 & \\
f'(x) &= 2 a x + b  \quad g'(x) = 3 d x ^2 &
\end{align}
$$
```

$$
\begin{align}
f(x) &= a x^2 + b x + c \quad  g(x) = d x^3 & \\
f'(x) &= 2 a x + b  \quad g'(x) = 3 d x ^2 &
\end{align}
$$

可以观察到，此时在 $f(x)$ 和 $f'(x)$ 后的等号对齐了，但是其末尾处并不对齐了

此时我们将其表格化，如下所示

| $\Rightarrow$ | `&`  | $\Leftarrow$                           | `&`  |
| ------------: | :--: | :------------------------------------- | :--: |
|       $f(x) $ |      | $=a x^2 + b x + c \quad  g(x) = d x^3$ |      |
|       $f'(x)$ |      | $= 2 a x + b  \quad g'(x) = 3 d x ^2$  |      |

可以看到，我们插入的 `&` 将公式划分成了两列，而在 `&` 左侧的列为右对齐，右侧的列为左对齐，这样就形成了在 `&` 处对齐的效果，由于后半部所在的列已经左对齐了，自然也就不能在末尾处对齐了。

我们继续对公式进行修改，将 `\quad` 替换为 `&`

```latex
$$
\begin{align}
f(x) &= a x^2 + b x + c &  g(x) = d x^3 \\
f'(x) &= 2 a x + b  & g'(x) = 3 d x ^2
\end{align}
$$
```

$$
\begin{align}
f(x) &= a x^2 + b x + c &  g(x) = d x^3 \\
f'(x) &= 2 a x + b  & g'(x) = 3 d x ^2
\end{align}
$$

此时可以发现公式又在末尾处对齐了，将其转化成表格

| $\Rightarrow$ | `&`  | $\Leftarrow$       | `&`  |      $\Rightarrow$ | `&`  |
| ------------: | :--: | ------------------ | :--: | -----------------: | :--: |
|       $f(x) $ |      | $=a x^2 + b x + c$ |      |     $g(x) = d x^3$ |      |
|       $f'(x)$ |      | $= 2 a x + b$      |      | $g'(x) = 3 d x ^2$ |      |

最后我们在 $g(x)$ 和 $g'(x)$ 后添加 `&`

```latex
$$
\begin{align}
f(x) &= a x^2 + b x + c &  g(x) & = d x^3 \\
f'(x) &= 2 a x + b  & g'(x)  & = 3 d x ^2
\end{align}
$$
```

$$
\begin{align}
f(x) &= a x^2 + b x + c &  g(x) & = d x^3 \\
f'(x) &= 2 a x + b  & g'(x)  & = 3 d x ^2
\end{align}
$$

最终的表格如下所示

| $\Rightarrow$ | `&`  | $\Leftarrow$  | `&`  | $\Rightarrow$ | `&`  | $\Leftarrow$ | `&`  |
| ------------: | :--: | ------------- | :--: | ------------: | :--: | ------------ | :--: |
|        $f(x)$ |      | $=ax^2+bx+c$  |      |        $g(x)$ |      | $=dx^3$      |      |
|       $f'(x)$ |      | $= 2 a x + b$ |      |       $g'(x)$ |      | $=3dx^3$     |      |

从上面的解析中可以看出，`&` 有两个作用

1. 分块，以 `&` 为中心划分成左右两部分
2. 如果左侧列没有对齐的话，优先右对齐，对于右侧列同理，优先左对齐

这样我们参照上面的表格，第一个和第三个 `&` 左右两侧都是如此，但是第二个 `&` 由于其左侧块已经有对齐方式了（左对齐），无法再进行布局安排，因此这个 `&` 只起到了第一个作用，第二个已经自动忽略了。

Tips：如果想实现列表形式的公式展示，可以将 `&` 作为列的分割符，对于一列，我们直接使用 `& a &` 包裹即可（左对齐）

```latex
$$
\begin{align}
& a & & b & & c & d & \\
& e & & f & & g & h &
\end{align}
$$
```

$$
\begin{align}
& a & & b & & c & d & \\
& e & & f & & g & h &
\end{align}
$$

这样虽然有些冗余，但是使用起来比较简单，无需思考 `&` 放置的位置

## 居中显示

相比于自定义对齐，居中显示就显得简单很多，使用 `gather` 即可

```latex
$$
\begin{gather}
2x - 5y =  8 \\ 
3x^2 + 9y =  3a + c
\end{gather}
$$
```

$$
\begin{gather}
2x - 5y =  8 \\ 
3x^2 + 9y =  3a + c
\end{gather}
$$

# 导入其他包

有时候我们想要在 MathJax 中使用其他宏包，例如 Physics 宏，我们可以直接在 LaTex 代码中使用 `require{...}` 来添加扩展。

```latex
$$
\require{physics}
\abs{a} \quad \grad{x} \quad \order{1} \quad \cross
$$
```

开启 Physics 宏之后渲染结果
$$
\require{physics}
\abs{a} \quad \grad{x} \quad \order{1} \quad \cross
$$
如果加载失败，将会显示如下结果

![](LaTex公式学习笔记/no-physics-error.svg)

不过感觉 `require{}` 功能在 mathjax 中还有点问题，最好还是在设置中手动开启。



# 参考

1. [LaTeX/Mathematics - Wikibooks, open books for an open world](https://en.wikibooks.org/wiki/LaTeX/Mathematics)
2. [LaTeX/Advanced Mathematics - Wikibooks, open books for an open world](https://en.wikibooks.org/wiki/LaTeX/Advanced_Mathematics)
3. [LaTeX Math Symbols Cheat Sheet - Kapeli](https://kapeli.com/cheat_sheets/LaTeX_Math_Symbols.docset/Contents/Resources/Documents/index)
4. [Mathematical expressions - Overleaf, Online LaTeX Editor](https://www.overleaf.com/learn/latex/Mathematical_expressions)

