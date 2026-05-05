#!/usr/bin/env bash
# 建议在 WSL 下以 root 执行：  wsl -u root .../pack-sysroot.sh <src> <out.tar.gz>
set -euo pipefail

SRC="${1:-}"
OUT="${2:-}"

if [[ -z "$SRC" || -z "$OUT" ]]; then
  echo "Usage: $0 <src-sysroot> <output-tar.gz>"
  exit 1
fi

if [[ ! -d "$SRC" ]]; then
  echo "Source sysroot not found: $SRC"
  exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
  echo "请使用 root 执行（例：wsl -u root bash $0 ...）以避免 rsync 读不到 /etc、apt 等属主文件。" >&2
  exit 1
fi

TMP_DIR=$(mktemp -d)
DST="$TMP_DIR/sysroot"

echo "[1/6] Copy sysroot..."
rsync -a --exclude 'lost+found' "$SRC/" "$DST/"

echo "[2/6] Remove dev/proc/sys/run"
rm -rf "$DST/dev" "$DST/proc" "$DST/sys" "$DST/run"
if [[ -d "${DST}/tmp" ]]; then
  find "${DST}/tmp" -mindepth 1 -delete 2>/dev/null || true
fi

echo "[3/6] Remove apt cache..."
rm -rf "$DST/var/cache/apt/"*
rm -rf "$DST/var/lib/apt/lists/"*

echo "[4/6] Remove doc/man/info..."
rm -rf "$DST/usr/share/doc/"*
rm -rf "$DST/usr/share/man/"*
rm -rf "$DST/usr/share/info/"*

echo "[5/6] Create tarball..."
tar --numeric-owner -czf "$OUT" -C "$TMP_DIR" sysroot

echo "[6/6] Cleanup..."
rm -rf "$TMP_DIR"

echo "Done: $OUT"
