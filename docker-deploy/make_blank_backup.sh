#!/usr/bin/env bash

# Make a labeled BLANK backup from current running stack
# Usage:
#   ./make_blank_backup.sh            # label defaults to BLANK
#   ./make_blank_backup.sh BLANK02    # custom label

set -Eeuo pipefail

LABEL_UPPER="${1:-BLANK}"
LABEL_UPPER="$(echo "$LABEL_UPPER" | tr '[:lower:]' '[:upper:]')"

ROOT_DIR="/workspaces/dolibarr"
DEPLOY_DIR="$ROOT_DIR/docker-deploy"
BACKUPS_DIR="$DEPLOY_DIR/backups"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
log(){ echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $*${NC}"; }
warn(){ echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] $*${NC}"; }
err(){ echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] $*${NC}"; exit 1; }

cd "$DEPLOY_DIR" || err "Cannot cd to $DEPLOY_DIR"

if ! docker compose version >/dev/null 2>&1; then
  err "Docker Compose V2 not found."
fi

log "Ensuring stack is running..."
docker compose up -d

log "Creating base backup..."
chmod +x ./backup_dolibarr.sh || true
./backup_dolibarr.sh

latest_dir=$(ls -dt "$BACKUPS_DIR"/dolibarr_backup_* | head -1 || true)
[ -n "$latest_dir" ] && [ -d "$latest_dir" ] || err "Could not locate newly created backup directory"

target_dir="${latest_dir}_${LABEL_UPPER}"

log "Tagging backup as ${LABEL_UPPER}..."
mv "$latest_dir" "$target_dir"

cat > "$target_dir/BLANK_BACKUP_INFO.txt" << EOF
DOLIBARR BLANK BACKUP (${LABEL_UPPER})
=====================================

Created: $(date)
Type: Blank/Initial backup (after uninstall or clean install, before any data)
Label: ${LABEL_UPPER}
Purpose: Base state for clean start/reset

This backup contains:
- Dolibarr Docker app snapshot (may be uninstalled or freshly installed)
- Docker configs for reproducible restore
- No business data by intent

Restore with:
  ./restore_dolibarr.sh "$target_dir"
EOF

# Protect from retention removal
: > "$target_dir/.protected"

log "BLANK backup ready: $target_dir"
du -sh "$target_dir" || true
ls -la "$target_dir" | head -n 50 || true
