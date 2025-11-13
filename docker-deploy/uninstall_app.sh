#!/usr/bin/env bash

# Dolibarr App Uninstall (reset to uninstalled state)
# - Removes conf.php and install.lock
# - Stops compose stack and removes project volumes (DB + documents)
# - Keeps repository files and backups intact
# Usage:
#   ./uninstall_app.sh           # prompt before destructive actions
#   ./uninstall_app.sh -y        # non-interactive yes

set -Eeuo pipefail

YES="false"
if [[ "${1:-}" == "-y" || "${1:-}" == "--yes" ]]; then
  YES="true"
fi

ROOT_DIR="/workspaces/dolibarr"
DEPLOY_DIR="$ROOT_DIR/docker-deploy"
COMPOSE_FILE="$DEPLOY_DIR/docker-compose.yml"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $*${NC}"; }
warn(){ echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $*${NC}"; }
err() { echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $*${NC}"; exit 1; }

require_compose() {
  if ! docker compose version >/dev/null 2>&1; then
    err "Docker Compose V2 not found. Please install Docker and compose plugin."
  fi
}

confirm() {
  if [[ "$YES" == "true" ]]; then return 0; fi
  read -p "This will DELETE Dolibarr app data (DB+documents) and conf.php. Continue? (y/N): " -n 1 -r || true
  echo
  [[ $REPLY =~ ^[Yy]$ ]] || { log "Cancelled."; exit 0; }
}

main() {
  require_compose
  confirm

  log "Stopping compose stack..."
  docker compose -f "$COMPOSE_FILE" down || true

  log "Removing conf.php and install.lock..."
  rm -f "$ROOT_DIR/htdocs/conf/conf.php" || true
  rm -f "$ROOT_DIR/htdocs/install/install.lock" || true

  log "Removing compose project volumes (DB + documents)..."
  docker compose -f "$COMPOSE_FILE" down -v || true

  log "Starting services fresh..."
  docker compose -f "$COMPOSE_FILE" up -d

  log "Uninstall complete. Visit http://localhost:8080 to run the installer."
}

main "$@"
