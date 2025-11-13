#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
HTDOCS_DIR="$ROOT_DIR/htdocs"
TEMPLATE_ON="$ROOT_DIR/docker-deploy/php/user-ini/redis-on.user.ini"
TARGET_INI="$HTDOCS_DIR/.user.ini"

usage() {
  echo "Usage: $0 [enable|disable]"
}

if [[ ${1:-} == "enable" ]]; then
  cp -f "$TEMPLATE_ON" "$TARGET_INI"
  echo "[redis] Enabled PHP sessions via Redis (.user.ini written)."
elif [[ ${1:-} == "disable" ]]; then
  if [[ -f "$TARGET_INI" ]]; then
    rm -f "$TARGET_INI"
  fi
  echo "[redis] Disabled Redis sessions (removed .user.ini; PHP falls back to files)."
else
  usage
  exit 1
fi
