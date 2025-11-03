#!/bin/bash
# Daily Pause Script
# Quickly pause running containers without tearing down the stack

set -Eeuo pipefail
trap 'echo -e "${RED}[${BASH_SOURCE[0]}:${LINENO}] Pause failed. Check: docker compose ps${NC}"' ERR

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
echo "   ⏸️ Daily Pause (containers)"
echo "=============================================="
echo -e "${NC}"

require_compose
cd /workspaces/dolibarr/docker-deploy

# Determine state
SERVICES_TOTAL=$(docker compose ps --services 2>/dev/null | wc -l | tr -d ' ')
RUNNING_COUNT=$(docker compose ps --format 'table {{.Name}}\t{{.Status}}' 2>/dev/null | grep -c "Up" || true)
PAUSED_COUNT=$(docker compose ps --format 'table {{.Name}}\t{{.Status}}' 2>/dev/null | grep -c "(Paused)" || true)

if [[ "${SERVICES_TOTAL}" -eq 0 ]]; then
  warn "No services defined or compose not initialized here."
  info "Nothing to pause."
  exit 0
fi

if [[ "${RUNNING_COUNT}" -eq 0 ]] && [[ "${PAUSED_COUNT}" -eq 0 ]]; then
  warn "Containers are not running. Did you mean to start them first?"
  info "Hint: ./daily_start.sh"
  docker compose ps || true
  exit 0
fi

if [[ "${RUNNING_COUNT}" -eq 0 ]] && [[ "${PAUSED_COUNT}" -gt 0 ]]; then
  info "All running containers already paused (${PAUSED_COUNT}/${SERVICES_TOTAL})."
  docker compose ps || true
  exit 0
fi

log "Pausing running containers..."
docker compose pause

echo ""
echo -e "${BLUE}📊 Pause Summary:${NC}"
docker compose ps
echo ""
echo -e "${GREEN}✅ Containers paused. To resume: ./daily_unpause.sh or docker compose unpause${NC}"
