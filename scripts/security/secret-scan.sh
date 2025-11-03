#!/usr/bin/env bash
set -euo pipefail

# Lightweight secret scan (non-official). For comprehensive scanning, use tools like gitleaks/trufflehog.

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
OUT_FILE="$ROOT_DIR/docker-deploy/debug_info/secret_scan_full.txt"
mkdir -p "$(dirname "$OUT_FILE")"

echo "[secret-scan] Running pattern-based scan..."
grep -RIn --exclude-dir={.git,coos_backup,docker-deploy/debug_info,node_modules,vendor} \
  -E '(password\s*=|secret\s*=|token\s*=|api[_-]?key\s*=|Authorization: Bearer |-----BEGIN (RSA|EC) PRIVATE KEY-----)' \
  "$ROOT_DIR" > "$OUT_FILE" || true

echo "[secret-scan] Results saved to $OUT_FILE"

exit 0
