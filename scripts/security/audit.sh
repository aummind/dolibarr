#!/usr/bin/env bash
set -euo pipefail

# Simple security audit for Dolibarr workspace (non-destructive)
# Non-official helper. Use alongside official Dolibarr security guidance.

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
REPORT_DIR="$ROOT_DIR/docker-deploy/debug_info"
mkdir -p "$REPORT_DIR"

echo "[audit] Starting security audit in $ROOT_DIR"

# 1) World-writable files/dirs (excluding known writable targets)
echo "[audit] Checking world-writable files and directories..."
{ 
  echo "# World-writable paths (excluding documents, custom)";
  find "$ROOT_DIR" -xdev \
    -path "$ROOT_DIR/documents" -prune -o \
    -path "$ROOT_DIR/htdocs/custom" -prune -o \
    -perm -0002 -type f -print; 
} > "$REPORT_DIR/world_writable.txt" || true

# 2) Potential secrets in repo (basic patterns)
echo "[audit] Scanning for potential secrets (basic patterns)..."
grep -RIn --exclude-dir={.git,coos_backup,docker-deploy/debug_info,node_modules,vendor} \
  -E '(aws_secret_access_key|-----BEGIN (RSA|EC) PRIVATE KEY-----|xox[baprs]-|ghp_[A-Za-z0-9]{36}|AIza[0-9A-Za-z_-]{35}|AKIA[0-9A-Z]{16})' \
  "$ROOT_DIR" > "$REPORT_DIR/secret_hits.txt" || true

# 3) PHP files with dangerous functions (non-official heuristic)
echo "[audit] Checking for sensitive PHP functions usage..."
grep -RIn --include='*.php' -E '\b(shell_exec|exec|system|passthru|popen|proc_open)\b' "$ROOT_DIR/htdocs" \
  > "$REPORT_DIR/php_sensitive_calls.txt" || true

# 4) List of active web-exposed entrypoints (heuristic)
echo "[audit] Listing web entrypoints..."
find "$ROOT_DIR/htdocs" -maxdepth 1 -type f -name '*.php' > "$REPORT_DIR/web_entrypoints.txt" || true

echo "[audit] Report generated under $REPORT_DIR"
echo "- world_writable.txt\n- secret_hits.txt\n- php_sensitive_calls.txt\n- web_entrypoints.txt"

exit 0
