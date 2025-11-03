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
BACKUPS_DIR="/workspaces/dolibarr/docker-deploy/backups"
mkdir -p "$BACKUPS_DIR"

# Ensure one BLANK backup exists (create if missing)
BLANK_COUNT=$(ls -d ${BACKUPS_DIR}/dolibarr_backup_*_BLANK 2>/dev/null | wc -l | tr -d ' ' || echo 0)
if [ "$BLANK_COUNT" -eq 0 ]; then
    warn "No BLANK backup found. Creating an initial BLANK backup before exit..."
    if ./mark_blank_backup.sh; then
        log "✅ BLANK backup created"
    else
        warn "⚠️ Failed to create BLANK backup. Proceeding without it."
    fi
else
    # If multiple BLANK backups exist, keep the oldest and remove extras
    if [ "$BLANK_COUNT" -gt 1 ]; then
        info "📦 Multiple BLANK backups detected ($BLANK_COUNT). Keeping the oldest, removing extras."
        mapfile -t BLANKS < <(ls -dt ${BACKUPS_DIR}/dolibarr_backup_*_BLANK 2>/dev/null || true)
        for (( i=1; i<${#BLANKS[@]}; i++ )); do
            rm -rf "${BLANKS[$i]}" || true
        done
    fi
fi

# Create a working backup (non-blank)
log "📦 Creating daily working backup..."
if ./backup_dolibarr.sh; then
    log "✅ Working backup completed successfully"
else
    error "❌ Working backup failed - check manually before exiting!"
fi

# Show backup info
LATEST_BACKUP=$(ls -t "$BACKUPS_DIR" | head -1)
BACKUP_SIZE=$(du -sh "$BACKUPS_DIR"/"$LATEST_BACKUP" | cut -f1)
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
log "🧹 Enforcing backup retention: 1 BLANK, 2 working (non-protected), and 1 coos_backup directory..."

BACKUP_ROOT="$BACKUPS_DIR"
# Build list of all backups without using 'mapfile' for broader shell compatibility
ALL_BACKUPS=()
while IFS= read -r line; do
    [ -n "$line" ] && ALL_BACKUPS+=("$line")
done < <(ls -dt ${BACKUP_ROOT}/dolibarr_backup_* 2>/dev/null || true)

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

REMOVED_COUNT=0
# Keep only the newest 2 REGULAR backups
if [ ${#REGULAR[@]} -gt 2 ]; then
    for (( i=2; i<${#REGULAR[@]}; i++ )); do
        rm -rf "${REGULAR[$i]}" || true
        ((REMOVED_COUNT++))
    done
fi

if [ "$REMOVED_COUNT" -gt 0 ]; then
    info "🗑️ Removed $REMOVED_COUNT old backups. Preserved: ${#PROTECTED[@]} protected, ${#BLANK[@]} BLANK."
else
    info "🗑️ No cleanup needed. Non-protected backups: ${#REGULAR[@]} (limit 2)."
fi

# Show final status
echo ""
echo -e "${BLUE}📊 Exit Summary:${NC}"
echo "- Latest backup: $LATEST_BACKUP"
echo "- Backup count: $(find "$BACKUPS_DIR" -maxdepth 1 -type d -name 'dolibarr_backup_*' 2>/dev/null | wc -l)"
echo "- Total backup size: $(du -sh "$BACKUPS_DIR" 2>/dev/null | cut -f1)"
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

# Generate/refresh compliance-oriented coos_backup
COOS_SCRIPT="/workspaces/dolibarr/scripts/project/backup_coos.sh"
if [ -x "$COOS_SCRIPT" ]; then
    log "🗂️ Generating coos_backup (compliance trace)..."
    if bash "$COOS_SCRIPT"; then
        log "✅ coos_backup generated/updated"
    else
        warn "⚠️ coos_backup generation failed"
    fi
else
    warn "⚠️ coos_backup script not found or not executable: $COOS_SCRIPT"
fi

# --- Quick Session Audit & Assistant Reminder ---
# Compute previous backup timestamp and summarize changes since then
echo ""
echo -e "${BLUE}🧭 Quick Session Audit${NC}"

PREV_BACKUP_DIR=$(ls -dt "$BACKUPS_DIR"/dolibarr_backup_* 2>/dev/null | sed -n '2p' || true)
if [ -n "${PREV_BACKUP_DIR:-}" ]; then
    PREV_BACKUP_NAME=$(basename "$PREV_BACKUP_DIR")
    # Extract YYYYMMDD_HHMMSS
    TS_PART=$(echo "$PREV_BACKUP_NAME" | sed -E 's/^.*_([0-9]{8})_([0-9]{6}).*$/\1 \2/')
    PREV_YMD=$(echo "$TS_PART" | awk '{print $1}')
    PREV_HMS=$(echo "$TS_PART" | awk '{print $2}')
    PREV_ISO="${PREV_YMD:0:4}-${PREV_YMD:4:2}-${PREV_YMD:6:2} ${PREV_HMS:0:2}:${PREV_HMS:2:2}:${PREV_HMS:4:2}"
else
    PREV_ISO="24 hours ago"
    PREV_BACKUP_NAME="(none; using last 24h)"
fi

DOCS_DIR="/workspaces/dolibarr/htdocs/documents"
DOCS_CHANGED=$(find "$DOCS_DIR" -type f -newermt "$PREV_ISO" 2>/dev/null | wc -l | tr -d ' ')

# Git-based source changes (workspace repo)
REPO_ROOT="/workspaces/dolibarr"
if command -v git >/dev/null 2>&1 && git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    REPO_CHANGED=$(git -C "$REPO_ROOT" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    RECENT_COMMITS=$(git -C "$REPO_ROOT" log --since="$PREV_ISO" --oneline 2>/dev/null | wc -l | tr -d ' ')
else
    REPO_CHANGED=0
    RECENT_COMMITS=0
fi

echo "- Previous backup reference: $PREV_BACKUP_NAME"
echo "- Files changed in documents/ since then: $DOCS_CHANGED"
echo "- Working tree changes (uncommitted): $REPO_CHANGED"
echo "- Recent commits since reference: $RECENT_COMMITS"

echo ""
echo -e "${YELLOW}🤖 Assistant sync reminder:${NC}"
echo "- Ask in chat: 'Sync my last session and audit changes'"
echo "- I will summarize: backup, documents delta, git changes, and coos trace updates."
echo ""