#!/bin/bash
# Daily Unpause Script
# Resume containers previously paused

set -Eeuo pipefail
trap 'echo -e "${RED}[${BASH_SOURCE[0]}:${LINENO}] Unpause failed. Check: docker compose ps${NC}"' ERR

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"; }
warn() { echo -e "${YELLOW}[$(date +'%H:%M:%S')] WARNING: $1${NC}"; }
error(){ echo -e "${RED}[$(date +'%H:%M:%S')] ERROR: $1${NC}"; exit 1; }
info() { echo -e "${BLUE}[$(date +'%H:%M:%S')] $1${NC}"; }

require_compose() {
  if ! docker compose version >/dev/null 2>&1; then
    error "Docker Compose V2 required (docker compose)."
  fi
}

echo -e "${BLUE}"
echo "=============================================="
echo "   ▶️ Daily Unpause (containers)"
echo "=============================================="
echo -e "${NC}"

require_compose
cd /workspaces/dolibarr/docker-deploy

SERVICES_TOTAL=$(docker compose ps --services 2>/dev/null | wc -l | tr -d ' ')
if [[ "${SERVICES_TOTAL}" -eq 0 ]]; then
  warn "No services defined or compose not initialized here."
  exit 0
fi

STATUS_TABLE=$(docker compose ps --format 'table {{.Name}}\t{{.Status}}' 2>/dev/null || true)
PAUSED_COUNT=$(echo "$STATUS_TABLE" | grep -c "(Paused)" || true)
RUNNING_COUNT=$(echo "$STATUS_TABLE" | grep -c "Up" || true)

if [[ "${PAUSED_COUNT}" -eq 0 ]]; then
  if [[ "${RUNNING_COUNT}" -gt 0 ]]; then
    info "No paused containers detected. Containers appear to be running already."
  else
    warn "No paused containers detected and none running."
    info "Start the stack with: ./daily_start.sh"
  fi
  docker compose ps || true
  exit 0
fi

log "Unpausing containers..."
docker compose unpause

echo ""
echo -e "${BLUE}📊 Unpause Summary:${NC}"
docker compose ps
echo ""
echo -e "${GREEN}✅ Containers unpaused. Continue work or stop later with: ./daily_exit.sh${NC}"
