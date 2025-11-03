#!/usr/bin/env bash

# Cleanup local workspace to a fresh baseline:
# - Stop the stack
# - Prune Docker images/containers/networks/build cache
# - Remove local Docker volumes from this stack
# - Keep only the BLANK backup, delete other backups
# - Show before/after disk usage

set -eo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEPLOY_DIR="$ROOT_DIR/docker-deploy"
BACKUPS_DIR="$DEPLOY_DIR/backups"

header() {
  echo
  echo "== $1 =="
}

size_report() {
  header "Disk usage snapshot"
  du -sh --apparent-size \
    "$ROOT_DIR/.git" \
    "$ROOT_DIR/htdocs" \
    "$BACKUPS_DIR" 2>/dev/null || true
  docker system df || true
}

header "Starting workspace cleanup"
size_report

header "Stopping containers (if any)"
(
  cd "$DEPLOY_DIR" && docker compose down || true
) || true

header "Pruning Docker system (images/containers/networks/build cache)"
docker system prune -af >/dev/null 2>&1 || true

header "Removing local Docker volumes for this stack"
# Remove only volumes created by this stack (prefix docker-deploy_)
docker volume ls -q | grep '^docker-deploy_' | xargs -r docker volume rm -f || true

header "Pruning dangling volumes"
docker volume prune -f >/dev/null 2>&1 || true

header "Keeping only BLANK backup"
if [[ -d "$BACKUPS_DIR" ]]; then
  # Remove all subdirectories except those whose name contains BLANK
  find "$BACKUPS_DIR" -mindepth 1 -maxdepth 1 -type d ! -name '*BLANK*' -print -exec rm -rf {} + || true
else
  echo "Backups directory not found: $BACKUPS_DIR"
fi

header "Optional: compact Git repository"
echo "Running: git gc --prune=now"
(cd "$ROOT_DIR" && git gc --prune=now) || true

size_report

header "Cleanup completed"
echo "You can now start the stack again with:"
echo "  cd docker-deploy && docker compose up -d"
