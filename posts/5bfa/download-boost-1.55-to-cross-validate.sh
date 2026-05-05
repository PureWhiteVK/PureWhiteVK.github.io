#!/usr/bin/env bash
# 将 Boost 1.55 源码包下载到 ct-ng 验证区 archives（只下一遍）；建议在 Cygwin 执行。
# 与本机代理一致：export http_proxy / https_proxy（如 http://127.0.0.1:7890）
set -euo pipefail

DEST="${DEST:-/cygdrive/d/ctng-build/workspace/cross-validate/archives}"
URL="${URL:-https://archives.boost.io/release/1.55.0/source/boost_1_55_0.tar.bz2}"
OUT="${OUT:-boost_1_55_0.tar.bz2}"

mkdir -p "$DEST"
cd "$DEST"

if [[ -f "$OUT" ]]; then
  echo "已存在，跳过: $DEST/$OUT"
  ls -la "$OUT"
  exit 0
fi

echo "下载 -> $DEST/$OUT"
curl -fSL --retry 3 --connect-timeout 30 -o "$OUT" "$URL"
ls -la "$OUT"
sha256sum "$OUT" || true
