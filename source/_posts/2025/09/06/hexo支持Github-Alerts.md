---
title: hexo支持Github Alerts
mathjax: false
abbrlink: dc23
date: 2025-09-06 21:50:33
tags:
- hexo
- pandoc
- node.js
- lua
category: Hexo使用记录
---

最近写博客时，发现 github markdown 中提供的 [Alerts](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#alerts) 很有用，能够作为提示信息进行展示。

其实际上是在 **引用文本（Quoting text）** 的基础上添加了一个特殊的 tag，使其渲染时有特殊的显示效果，markdown 代码如下：

```markdown
> [!NOTE]
> Useful information that users should know, even when skimming content.

> [!TIP]
> Helpful advice for doing things better or more easily.

> [!IMPORTANT]
> Key information users need to know to achieve their goal.

> [!WARNING]
> Urgent info that needs immediate user attention to avoid problems.

> [!CAUTION]
> Advises about risks or negative outcomes of certain actions.
```

渲染结果如下：

<img src="hexo支持Github-Alerts/alerts-rendered.png" style="zoom: 50%;" />

本来以为这是[ gfm（GitHub Flavored Markdown Spec）规范](https://github.github.com/gfm/)的一部分，但是发现这个功能是 Github 单独实现的一个功能，hexo 上默认是不支持的，不过搜了一下似乎实现起来并不复杂，就用一篇博客记录下如何实现的。

<!-- more -->

# Alerts & Quoting

在 hexo 上，如果直接添加 alerts 的 markdown 代码（使用 pandoc 版本为 3.0.1），其渲染效果如下：

<img src="hexo支持Github-Alerts/image-20250913134852416.png" alt="image-20250913134852416" style="zoom: 67%;" />

在 VS Code 上渲染时，也是类似的情况

<img src="hexo支持Github-Alerts/image-20250913135022559.png" alt="image-20250913135022559" style="zoom: 80%;" />

但是在 Typora 编辑器上是默认有支持的（`[!NOTE]` 说明这个 Alert 是可编辑的），渲染效果如下：

<img src="hexo支持Github-Alerts/image-20250913135352763.png" alt="image-20250913135352763" style="zoom: 67%;" />

（就是因为 Typora 支持展示才会让我在编写文档是不自觉地加上了这个 Alert，结果发现 hexo 和 vscode 都不支持 😓，出于强迫症就把这个功能给他加上了，要不然太难看了）



# HTML 差异

既然想要支持类似的展示效果，首先分析 pandoc 转换的 html 代码和 github 上展示的 html 代码有什么差异：

**原始 markdown 代码**

```markdown
> [!NOTE]
> The Markdown formatting will not be ignored in the title of an issue or a pull request.
```

渲染效果（[原始文章](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#ignoring-markdown-formatting)）：

<img src="hexo支持Github-Alerts/image-20250913140150809.png" alt="image-20250913140150809" style="zoom: 80%;" />

**github alerts**

```html
<div class="ghd-alert ghd-alert-accent" data-container="alert">
    <p class="ghd-alert-title"><svg version="1.1" width="16" height="16" viewBox="0 0 16 16" class="octicon mr-2"
            aria-hidden="">
            <path
                d="M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8Zm8-6.5a6.5 6.5 0 1 0 0 13 6.5 6.5 0 0 0 0-13ZM6.5 7.75A.75.75 0 0 1 7.25 7h1a.75.75 0 0 1 .75.75v2.75h.25a.75.75 0 0 1 0 1.5h-2a.75.75 0 0 1 0-1.5h.25v-2h-.25a.75.75 0 0 1-.75-.75ZM8 6a1 1 0 1 1 0-2 1 1 0 0 1 0 2Z">
            </path>
        </svg>Note</p>
    <p>
        The Markdown formatting will not be ignored in the title of an issue or a pull request.</p>
</div>
```

**pandoc generated（pandoc version 3.0.1）**

```html
<blockquote>
<p>[!NOTE] The Markdown formatting will not be ignored in the title of
an issue or a pull request.</p>
</blockquote>
```

此时 pandoc 还并不支持 Alerts 的解析，还是将其默认解析为块引用的格式。

而根据 [pandoc 的最新版 markdown 文档](https://pandoc.org/MANUAL.html#extension-alerts)，只需要在转换时启用 `alerts` 扩展，就可以解析成上面 github alerts 的结构了，转换命令如下（pandoc version 3.8.0）

```bash
pandoc -f gfm+alerts -t html5 -o test.html test.md
```

生成的 html 如下所示：

**pandoc generated (pandoc version 3.8.0)**

```html
<div class="note">
    <div class="title">
        <p>Note</p>
    </div>
    <p>The Markdown formatting will not be ignored in the title of an issue
        or a pull request.
    </p>
</div>
```

其将所有 alert 的内容放在 `div` 容器内，并将 `[!NOTE]` 类型标记转换为外层 `div` 容器的 class，且单独为标题创建了一个 `div` 容器，设置其 class 为 title。

对比 github 版的 html，有两个主要的差异，都体现在 title 部分：

1. **外层容器不同**，github 版 title 的外层容器是 `<p>`，而 pandoc 版外层容器是 `<div>`。

   这是因为在 [pandoc 的元素](https://pandoc.org/lua-filters.html#type-div)设计中，仅有部分标签可以设置 class 属性，默认的 `Para` 元素并不支持设置 class 信息，好在 `<div>` 标签和 `<p>` 在使用上差异不大，更何况 pandoc 版内部还使用了 `<p>` 进行包裹

2. pandoc 版 **缺少了 alert 的 svg 图标**

第一个差异是由于 pandoc 本身的设计有关，无法避免，但是第二点，可以结合 pandoc 的 lua-filter 在转换过程中只要检测到 `<div class="title"><p></p></div>` 这种类似结构，就可以在内部的 `<p>` 标签内插入 svg 图标。

代码实现如下（[完整代码在这里](https://github.com/PureWhiteVK/PureWhiteVK.github.io/blob/c94115e285449cb8e644e0e466c000dde51cfe47/lua/image-asset.lua)）：

```lua
local function Div(div)
    -- check class list of <div> element
    local curr_alert_type, curr_icon = get_alert_type(div)
    -- check title element
    local title_element = get_title_element(div)
    if (curr_alert_type == nil or curr_icon == nil or title_element == nil) then
        return
    end
    -- override markdown-alert and markdown-alert-* class
    div.attr['classes'] = { 'markdown-alert', 'markdown-alert-' .. curr_alert_type }
    -- construct new title element
    div.content[1] = pandoc.Div(
        { 
            pandoc.RawInline('html', curr_icon), 
            pandoc.Str(capitalize_first(curr_alert_type)) 
        }, 
        {
            class = 'markdown-alert-title'
    	}
    )
    -- logging.temp('Div',div)
    return div
end
```

其中：

- `get_alert_type` 函数检查当前 `<div>` 标签的 class，判断是否有类似 `<div class="note">` 的类型声明，并根据 alert 的类型返回对应类别的图标（原始的 svg 代码）
- `get_title_element` 函数遍历 `<div>` 标签下的子元素，返回包含 `<div class="title">` 的元素
- `capitalize_first` 函数将单词的首字母大写，例如 `note` 转换为 `Note` 

找到 alert 块的根容器和对应的alert 类别，就可以直接进行修改，插入 svg 图标（这里必须使用 `pandoc.RawInline` 进行插入，否则 pandoc 会解析 svg 文件，转换成 base64 图片）并设置 class 信息（具体如何使用见下一节）。

应用 lua filter 后转换得到的 html 如下：

**pandoc generated (pandoc version 3.8.0 with lua-filter)**

```html
<div class="markdown-alert markdown-alert-note">
    <div class="markdown-alert-title">
        <svg class="octicon" viewBox="0 0 16 16" width="16" height="16" aria-hidden="true">
            <path
                d="M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8Zm8-6.5a6.5 6.5 0 1 0 0 13 6.5 6.5 0 0 0 0-13ZM6.5 7.75A.75.75 0 0 1 7.25 7h1a.75.75 0 0 1 .75.75v2.75h.25a.75.75 0 0 1 0 1.5h-2a.75.75 0 0 1 0-1.5h.25v-2h-.25a.75.75 0 0 1-.75-.75ZM8 6a1 1 0 1 1 0-2 1 1 0 0 1 0 2Z">
            </path>
        </svg>
        Note
    </div>
    <p>The Markdown formatting will not be ignored in the title of an issue
        or a pull request.</p>
</div>
```

此时，pandoc 生成的 html 和 github 版的差异就只剩下样式和 title 的外层容器类型差异了，而 `<div>` 和 `<p>` 的差异可以暂时忽略，那么就只剩下样式了。

 

# 添加样式

原本想直接 copy github 版对 alert 的样式，但是似乎杂揉了很多其他的样式，且个人对 CSS 也不太熟悉，还是搜下是否有什么库可以提供这个样式吧。

幸好，[remark-github-blockquote-alert](https://www.npmjs.com/package/remark-github-blockquote-alert) 可以满足我们的需求（好耶！💃）。

<img src="hexo支持Github-Alerts/image-20250913145436237.png" alt="image-20250913145436237" style="zoom: 67%;" />

只需要在加载样式时，将 `remark-github-blockquote-alert/alert.css` 也加载上，并添加上指定的 class 即可。

有两处需要添加：

1. alert 最外层容器需要设置 `markdown-alert markdown-alert-<alert-type>` 两个类
2. title 的最外层容器需要设置 `markdown-alert-title` 类

手动插入 css 文件到 pandoc 生成的 html 文件，检查一下渲染效果。

**pandoc generated with css (pandoc version 3.8.0 with lua-filter)**

（代码太长直接贴图了，style 块中就是库提供的 css 内容）

<img src="hexo支持Github-Alerts/image-20250913150129513.png" alt="image-20250913150129513" style="zoom:67%;" />

渲染效果如下：

**pandoc generated with css**

![image-20250913150250308](hexo支持Github-Alerts/image-20250913150250308.png)

**github alerts**

![image-20250913140150809](hexo支持Github-Alerts/image-20250913140150809.png)

可以看到在字体上稍微有一些差异，但是整体已经满足需求了。（`<div>` 和 `<p>` 的差异，确实不用管了ね😀）

# Hexo 集成

最后一步，只需要在 hexo 渲染时自动加载 css 文件，就可以在网页上展示 Alert 了，这一步需要修改 next 的配置文件 `_config.next.yml`，修改 `custom_file_path` ，调整样式那一栏：

```diff
diff --git a/_config.next.yml b/_config.next.yml
index 796984f..dfde0a4 100644
--- a/_config.next.yml
+++ b/_config.next.yml
@@ -28,7 +28,7 @@ custom_file_path:
   #bodyEnd: source/_data/body-end.njk
   #variable: source/_data/variables.styl
   #mixin: source/_data/mixins.styl
-  # style: source/_data/styles.styl
+  style: source/_data/styles.styl
```

同时确保 `source/_data/styles.styl` 文件存在即可，为了避免手动拷贝，编写一个简单的 hexo 插件，自动完成拷贝，代码如下：

***hexo-copy-alert-css.js***

```js
'use strict';

const fs = require('node:fs');
const path = require('node:path')

hexo.extend.filter.register("after_init", function () {
  const { log } = hexo;
  const alert_css_path = 'node_modules/remark-github-blockquote-alert/alert.css';
  const target_path = 'source/_data/styles.styl';
  const target_dir = path.dirname(target_path);
  log.debug(`Copy ${alert_css_path} to ${target_path}`);
  if (!fs.existsSync(target_dir)) {
    log.debug(`Create dir ${target_dir}`)
    fs.mkdirSync(target_dir);
  }
  fs.copyFileSync(alert_css_path, target_path);
});
```

这样，只要在 `package.json` 中安装了 `remark-github-blockquote-alert` 依赖，就可以直接拷贝包中提供的 alert.css 了，确保样式是最新的（虽然感觉一般不会变，但是有溯源保证还是更安心一点）。

最后，直接在 markdown 中添加 alert 的展示，检查是否配置成功。



> [!NOTE]
> Useful information that users should know, even when skimming content.

> [!TIP]
> Helpful advice for doing things better or more easily.

> [!IMPORTANT]
> Key information users need to know to achieve their goal.

> [!WARNING]
> Urgent info that needs immediate user attention to avoid problems.

> [!CAUTION]
> Advises about risks or negative outcomes of certain actions.



如果可以看到文章开头展示的渲染效果，则说明配置成功（😎）。