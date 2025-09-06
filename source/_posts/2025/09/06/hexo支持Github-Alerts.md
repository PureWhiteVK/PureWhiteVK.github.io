---
title: hexo支持Github Alerts
mathjax: false
abbrlink: dc23
date: 2025-09-06 21:50:33
tags:
category:
---


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

<!-- more -->

`test.mjs`

> https://www.npmjs.com/package/remark-github-blockquote-alert

```js
import { remark } from 'remark'
import remarkParse from 'remark-parse'
import remarkAlert from 'remark-github-blockquote-alert'
import remarkRehype from 'remark-rehype'
import rehypeStringify from 'rehype-stringify'

let markdown = `
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
`;

const htmlStr = remark()
    .use(remarkParse)
    .use(remarkAlert)
    .use(remarkRehype)
    .use(rehypeStringify)
    .processSync(markdown).toString()

console.log(htmlStr)
```

```bash
export LUA_PATH="$(pwd)/lua/?.lua"

pandoc --from=gfm+alerts \
    --to=html5 --mathjax \
    --metadata=pagetitle:ignored \
    --metadata=standalone:true \
    --lua-filter=lua/image-asset.lua \
    -o test.html \
    test.md
```