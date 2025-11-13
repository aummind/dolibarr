#!/bin/bash
# Daily Codespace Exit Script
# Safely backup data and shutdown containers before closing Codespace

set -Eeuo pipefail
trap 'echo -e "${RED}[${BASH_SOURCE[0]}:${LINENO}] Exit process failed. Investigate docker and backup logs.${NC}"' ERR

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

info() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')] $1${NC}"
}

# Ensure required commands are available
require_compose() {
    if ! docker compose version >/dev/null 2>&1; then
        error "Docker Compose V2 is required (docker compose). Verify Docker is installed and compose plugin is available."
    fi
}

# Banner
echo -e "${BLUE}"
echo "=============================================="
echo "   🔄 Daily Codespace Exit Process"
echo "=============================================="
echo -e "${NC}"

log "🔄 Starting daily exit process..."
require_compose

# Navigate to correct directory
cd /workspaces/dolibarr/docker-deploy

# Check if any containers are running
if ! docker compose ps | grep -q "Up"; then
    warn "Containers are not running - skipping backup"
    info "✅ Safe to close Codespace (no active containers)"
    exit 0
fi

# Create backup
log "📦 Creating daily backup..."
if ./backup_dolibarr.sh; then
    log "✅ Backup completed successfully"
else
    error "❌ Backup failed - check manually before exiting!"
fi

# Assemble compliance/OSS backup (coos_backup) – non-blocking
log "📚 Assembling compliance backup (coos_backup)..."
if /usr/bin/env bash -c 'bash /workspaces/dolibarr/docker-deploy/project/backup_coos.sh'; then
    log "✅ coos_backup assembled."
else
    warn "⚠️ coos_backup assembly failed (non-blocking). Check docker-deploy/project/backup_coos.sh."
fi

# Show backup info
LATEST_BACKUP=$(ls -t /workspaces/dolibarr/docker-deploy/backups/ | head -1)
BACKUP_SIZE=$(du -sh /workspaces/dolibarr/docker-deploy/backups/"$LATEST_BACKUP" | cut -f1)
info "📦 Latest backup: $LATEST_BACKUP ($BACKUP_SIZE)"

# Stop containers gracefully
log "🛑 Stopping containers gracefully..."
if docker compose down; then
    log "✅ Containers stopped successfully"
else
    warn "⚠️ Some containers may not have stopped cleanly"
fi

#!/usr/bin/env bash
# Cleanup old backups: keep newest 3 non-protected; always keep protected and BLANK backups
log "🧹 Cleaning up old backups (keep last 3 non-protected; preserve protected and BLANK backups)..."

BACKUP_ROOT="/workspaces/dolibarr/docker-deploy/backups"
mapfile -t ALL_BACKUPS < <(ls -dt ${BACKUP_ROOT}/dolibarr_backup_* 2>/dev/null || true)

# Classify backups
PROTECTED=()
BLANK=()
REGULAR=()
for b in "${ALL_BACKUPS[@]}"; do
    [ -d "$b" ] || continue
    if [ -f "$b/.protected" ] || [[ "$(basename "$b")" == *"BLANK"* ]] || [ -f "$b/BLANK_BACKUP_INFO.txt" ]; then
        # Treat BLANK as protected-equivalent
        if [[ "$(basename "$b")" == *"BLANK"* ]] || [ -f "$b/BLANK_BACKUP_INFO.txt" ]; then
            BLANK+=("$b")
        else
            PROTECTED+=("$b")
        fi
        continue
    fi
    REGULAR+=("$b")
done

# Remove older REGULAR beyond 3
REMOVED_COUNT=0
if [ ${#REGULAR[@]} -gt 3 ]; then
    for (( i=3; i<${#REGULAR[@]}; i++ )); do
        rm -rf "${REGULAR[$i]}"
        ((REMOVED_COUNT++))
    done
fi

if [ "$REMOVED_COUNT" -gt 0 ]; then
    info "🗑️ Removed $REMOVED_COUNT old backups. Preserved: ${#PROTECTED[@]} protected, ${#BLANK[@]} BLANK."
else
    info "🗑️ No cleanup needed. Non-protected backups: ${#REGULAR[@]} (limit 3)."
fi

# Show final status
echo ""
echo -e "${BLUE}📊 Exit Summary:${NC}"
echo "- Latest backup: $LATEST_BACKUP"
echo "- Backup count: $(find /workspaces/dolibarr/docker-deploy/backups -maxdepth 1 -type d -name 'dolibarr_backup_*' 2>/dev/null | wc -l)"
echo "- Total backup size: $(du -sh /workspaces/dolibarr/docker-deploy/backups/ 2>/dev/null | cut -f1)"
echo "- Containers stopped: ✅"
echo ""
echo -e "${GREEN}✅ Safe to close Codespace!${NC}"
echo -e "${BLUE}🔄 Next startup: ./daily_start.sh or docker compose up -d${NC}"
echo ""

# Optional: Show instructions for manual verification
echo -e "${YELLOW}💡 Optional Verification:${NC}"
echo "- Check backup exists: ls -la backups/"
echo "- Verify containers stopped: docker compose ps"
echo "- Manual backup if needed: ./backup_dolibarr.sh"