# Local Environment Settings

## Node.js

download node from https://nodejs.org/en/download/package-manager

run the following command

```sh
npm install
npm install -g hexo
```

start a local server

```sh
hexo server
```

generate static pages

```sh
hexo generate
```

create new post page

```sh
hexo new post
```

## Pandoc

download pandoc form https://github.com/jgm/pandoc/releases or install through homebrew / chocolatey.

# Example

## hexo

```command-line
$> hexo -v
INFO  Validating config
hexo: 7.3.0
hexo-cli: 4.3.2
os: win32 10.0.26100 undefined
node: 18.12.1
v8: 10.2.154.15-node.12
uv: 1.43.0
zlib: 1.2.11
brotli: 1.0.9
ares: 1.18.1
modules: 108
nghttp2: 1.47.0
napi: 8
llhttp: 6.0.10
openssl: 3.0.7+quic
cldr: 41.0
icu: 71.1
tz: 2022b
unicode: 14.0
ngtcp2: 0.8.1
nghttp3: 0.7.0
```

## Pandoc

```command-line
$> pandoc -v
pandoc.exe 3.7.0.2
Features: +server +lua
Scripting engine: Lua 5.4
User data directory: C:\Users\xiao\AppData\Roaming\pandoc
Copyright (C) 2006-2024 John MacFarlane. Web: https://pandoc.org
This is free software; see the source for copying conditions. There is no
warranty, not even for merchantability or fitness for a particular purpose.
```

### Debug pandoc lua-filter

make sure you have `LUA_PATH` environment variable set to `<project_root>/lua/?.lua`, otherwise pandoc can not find `logging.lua` file.

```bash
export LUA_PATH="$(pwd)/lua/?.lua"

pandoc --from=gfm+alerts \
       --to=html5 \
       --lua-filter=lua/image-asset.lua \
       -o test.html \
       test.md
```
