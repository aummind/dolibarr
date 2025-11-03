#!/bin/bash

# Complete Codespace Cleanup Script
# This script performs a comprehensive cleanup of your Dolibarr Codespace

set -Eeuo pipefail
trap 'echo -e "${RED}[${BASH_SOURCE[0]}:${LINENO}] Cleanup failed. Review messages above and check docker status.${NC}"' ERR

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

info() {
    echo -e "${GREEN}ℹ️${NC} $1"
}

warn() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

error() {
    echo -e "${RED}❌${NC} $1"
}

success() {
    echo -e "${GREEN}✅${NC} $1"
}

# Globals
AUTO_YES=false
DRY_RUN=false

# Runner helper
run() {
    if $DRY_RUN; then
        echo "+ $*"; return 0
    fi
    eval "$@"
}

# Ensure required commands are available
require_compose() {
    if ! docker compose version >/dev/null 2>&1; then
        warn "Docker Compose V2 not found. Some docker cleanup steps will be skipped."
        return 1
    fi
}

# Function to ask for confirmation
confirm() {
    local prompt="$1"
    local response
    
    if $AUTO_YES; then
        echo "$prompt (auto-yes)"
        return 0
    fi
    while true; do
        read -p "$prompt (y/N): " response
        case $response in
            [Yy]* ) return 0;;
            [Nn]* | "" ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Parse arguments
while (( "$#" )); do
  case "$1" in
    -y|--yes)
      AUTO_YES=true; shift ;;
    -n|--dry-run)
      DRY_RUN=true; shift ;;
    -h|--help)
      echo "Usage: $0 [--yes|-y] [--dry-run|-n]"
      echo "  --yes      Automatically answer yes to all prompts"
      echo "  --dry-run  Show what would be done without executing"
      exit 0 ;;
    *)
      echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Main cleanup function
main() {
    echo "======================================="
    echo "🧹 Complete Codespace Cleanup"
    echo "======================================="
    echo ""
    
    info "🔒 DATA SAFETY: This cleanup preserves your work and data"
    info "   • Docker volumes (database + documents) are NEVER deleted"
    info "   • Git repository and code files are NEVER modified"
    info "   • You can always continue your work after Codespace restart"
    echo ""
    
    log "Starting comprehensive cleanup process..."
    
    # Check if we're in the right directory
    if [ ! -f "docker-compose.yml" ]; then
        error "Please run this script from the docker-deploy directory."
        exit 1
    fi
    require_compose || true
    
    # Show current storage usage
    echo "📊 Current Storage Usage:"
    df -h /workspaces/dolibarr | tail -1
    echo ""
    
    # 1. Docker Container Cleanup
    if confirm "🐳 Remove stopped Docker containers? (Working files safe in volumes)"; then
        log "Stopping and removing Docker containers..."
        if docker compose version >/dev/null 2>&1; then
            run docker compose down --remove-orphans || true
        else
            warn "Skipping docker compose down (compose v2 not available)"
        fi
        
        info "📦 Data volumes preserved - your Dolibarr data is safe"
        success "Docker containers cleanup completed"
    fi
    
    # 2. Docker Images Cleanup
    echo ""
    if confirm "🖼️ Remove unused Docker images? (Can be re-downloaded when needed)"; then
        log "Cleaning unused Docker images..."
        run docker image prune -a --force || true
        
        success "Docker images cleanup completed"
    fi
    
    # 3. Docker Networks Cleanup
    echo ""
    if confirm "🌐 Remove unused Docker networks? (Recreated automatically on restart)"; then
        log "Cleaning unused Docker networks..."
        run docker network prune --force || true
        
        success "Docker networks cleanup completed"
    fi
    
    # 4. Backup Cleanup
    if [ -d "backups" ] && [ "$(ls -A backups 2>/dev/null)" ]; then
        echo ""
        echo "📦 Current backups:"
        ls -lah backups/
        echo ""
        
        if confirm "🗑️ Remove all backups? (This will delete ALL backup data)"; then
            log "Removing all backups..."
            if $DRY_RUN; then echo "+ rm -rf backups/*"; else rm -rf backups/*; fi
            success "All backups removed"
        elif confirm "🏷️ Keep only BLANK/protected backups and remove others?"; then
            log "Cleaning up backups (keeping BLANK)..."
            # Preserve backups that are BLANK (name or marker) or contain .protected
            mapfile -t BKS < <(find backups -maxdepth 1 -type d -name 'dolibarr_backup_*' | sort)
            for b in "${BKS[@]}"; do
                base=$(basename "$b")
                if [[ "$base" == *"BLANK"* ]] || [ -f "$b/BLANK_BACKUP_INFO.txt" ] || [ -f "$b/.protected" ]; then
                    info "Preserving: $base"
                    continue
                fi
                if $DRY_RUN; then echo "+ rm -rf \"$b\""; else rm -rf "$b"; fi
            done
            success "Backup cleanup completed (BLANK and protected backups preserved)"
        fi
    fi
    
    # 5. Temporary Files Cleanup
    echo ""
    if confirm "🗂️ Clean up temporary files and caches?"; then
        log "Removing temporary files..."
        
        cd /workspaces/dolibarr
        
        # Remove common temporary files
        run "find . -name '*.tmp' -delete" || true
        run "find . -name '*.log' -delete" || true
        run "find . -name '.DS_Store' -delete" || true
        run "find . -name 'Thumbs.db' -delete" || true
        run "find . -name '*.swp' -delete" || true
        run "find . -name '*~' -delete" || true
        
        # Clean package caches
        if command -v apt-get >/dev/null 2>&1; then
            if $DRY_RUN; then echo "+ sudo apt-get clean"; else sudo apt-get clean || true; fi
            if $DRY_RUN; then echo "+ sudo apt-get autoremove -y"; else sudo apt-get autoremove -y || true; fi
        fi
        
        cd /workspaces/dolibarr/docker-deploy
        success "Temporary files cleanup completed"
    fi
    
    # 6. System Cache Cleanup
    echo ""
    if confirm "💾 Clean up system caches and optimize storage?"; then
        log "Cleaning system caches..."
        
        # Clear various caches
        if $DRY_RUN; then echo "+ sudo rm -rf /tmp/*"; else sudo rm -rf /tmp/* 2>/dev/null || true; fi
        if $DRY_RUN; then echo "+ sudo rm -rf /var/tmp/*"; else sudo rm -rf /var/tmp/* 2>/dev/null || true; fi
        
        # Clear user caches
        if $DRY_RUN; then echo "+ rm -rf ~/.cache/*"; else rm -rf ~/.cache/* 2>/dev/null || true; fi
        
        # Clear bash history (optional)
        if confirm "📜 Clear bash history?"; then
            if ! $DRY_RUN; then history -c; echo > ~/.bash_history; fi
            info "Bash history cleared"
        fi
        
        success "System cache cleanup completed"
    fi
    
    # 7. VS Code Cleanup
    echo ""
    if confirm "🔧 Reset VS Code workspace settings?"; then
        log "Cleaning VS Code settings..."
        
        if $DRY_RUN; then echo "+ rm -rf ~/.vscode-server/data/User/workspaceStorage/*"; else rm -rf ~/.vscode-server/data/User/workspaceStorage/* 2>/dev/null || true; fi
        if $DRY_RUN; then echo "+ rm -rf /workspaces/dolibarr/.vscode/settings.json"; else rm -rf /workspaces/dolibarr/.vscode/settings.json 2>/dev/null || true; fi
        
        success "VS Code cleanup completed"
    fi
    
    # Final storage report
    echo ""
    echo "📊 Storage Usage After Cleanup:"
    df -h /workspaces/dolibarr | tail -1
    
    if [ -d "backups" ]; then
        echo "📦 Remaining backups:"
        ls -lah backups/ 2>/dev/null || echo "No backups remaining"
    fi
    
    echo ""
    success "🎉 Cleanup completed successfully!"
    echo ""
    
    warn "📝 Next Steps:"
    info "1. To start fresh: ./recreate_dolibarr.sh"
    info "2. To restore from backup: ./restore_dolibarr.sh backups/[backup_name]"
    info "3. For new installation: ./daily_start.sh then setup at http://localhost:8080"
    echo ""
}

# Run main function with error handling
if ! main "$@"; then
    error "Cleanup script failed. Please check the errors above."
    exit 1
fi