# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Hexo static blog site using the NexT theme, deployed to GitHub Pages. Content is written in Markdown with GFM alert syntax and rendered through Pandoc (not the default Hexo renderer).

## Commands

```bash
npm install          # install dependencies
npm run server       # start dev server (hexo server --debug)
npm run build        # generate static site (hexo generate --debug)
npm run clean        # remove public/ (hexo clean)
hexo new post "Title" # create a new post
```

For debugging Pandoc Lua filters standalone (requires `LUA_PATH`):

```bash
export LUA_PATH="$(pwd)/lua/?.lua"
pandoc --from=gfm+alerts --to=html5 --lua-filter=lua/pandoc-filters.lua -o test.html test.md
```

## Architecture

### Custom rendering pipeline

The default Hexo markdown renderer is **completely replaced** by Pandoc. The custom renderer in `scripts/hexo-renderer-pandoc.js` registers itself for all `.md`/`.markdown`/`.mkd` extensions. For every markdown file, it:

1. Spawns a `pandoc` child process (binary must be on PATH)
2. Converts from `gfm+alerts` (GitHub-Flavored Markdown with alert blocks) to `html5`
3. Injects post path and filename as Pandoc metadata (so Lua filters can resolve relative image paths)
4. Passes the markdown content via stdin, reads HTML5 output from stdout

### Lua Pandoc filters (`lua/pandoc-filters.lua`)

Three transformations during Pandoc rendering:

- **Div filter**: Converts GFM alert divs (`.note`, `.tip`, `.warning`, `.caution`, `.important`) to styled `markdown-alert` blocks with SVG icons
- **Image filter**: Rewrites relative image `src` paths to absolute site paths using metadata injected by the renderer. The image filename prefix in the post is matched against the post title metadata
- **RawBlock filter**: Parses raw HTML blocks back through Pandoc to convert them to proper AST elements

The filters require `lua/logging.lua` (a standalone Pandoc logging utility by William Lupton, MIT licensed) as a dependency, resolved via `LUA_PATH`.

### Post structure

- Posts live under `source/_posts/{year}/{month}/{day}/{title}.md` (configured via `new_post_name`)
- Post scaffold in `scaffolds/post.md` — new posts default to `mathjax: true` with `$\require{physics}$`
- Permalinks use `hexo-abbrlink` with CRC16 hex hash: `posts/:abbrlink/`
- Each post gets an asset folder (`post_asset_folder: true`) for images

### GitHub alert CSS (`scripts/hexo-copy-alert-css.js`)

On `after_init`, copies `node_modules/remark-github-blockquote-alert/alert.css` to `source/_data/styles.styl` so the NexT theme includes the GitHub-style alert styling (light/dark mode CSS variables).

### CI/CD (`.github/workflows/deploy.yml`)

Push to `main` triggers a deploy: installs Pandoc 3.8 and Node 22.19.0, runs `npm run clean && npm run build`, then publishes `public/` to the `gh-pages` branch via `peaceiris/actions-gh-pages`.

### Blog review specification (`copilot_check.spec`)

A Chinese-language self-review checklist for technical blog posts — used as reference, not as an automated check.

## Key config files

| File | Purpose |
|------|---------|
| `_config.yml` | Hexo core config (site, URL, directory, writing, deploy, Pandoc, markdown) |
| `_config.next.yml` | NexT theme config (sidebar, footer, search, comments, plugins) |
| `scaffolds/post.md` | Template for `hexo new post` |
