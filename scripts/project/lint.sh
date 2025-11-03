#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"

if ! command -v php >/dev/null 2>&1; then
  echo "[lint] php not found; skipping PHP syntax checks."
  exit 0
fi

echo "[lint] Running PHP syntax checks (fast)..."
# Check some critical entrypoints and core dirs
find "$ROOT_DIR/htdocs" -type f -name '*.php' -print0 | xargs -0 -n1 -P"$(nproc || echo 2)" php -l >/dev/null

echo "[lint] OK"
