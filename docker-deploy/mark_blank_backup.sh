#!/bin/bash

# Mark Blank Backup Script for Dolibarr
# This script helps you preserve your initial "blank" backup
# Run this after initial installation but before adding real business data

set -euo pipefail

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

# Main script
main() {
    echo "======================================="
    echo "🏷️  Dolibarr Blank Backup Marker"
    echo "======================================="
    echo ""
    
    log "Starting blank backup creation process..."
    
    # Check if we're in the right directory
    if [ ! -f "docker-compose.yml" ]; then
        error "docker-compose.yml not found. Please run this script from the docker-deploy directory."
        exit 1
    fi
    
    # Check if containers are running
    if ! docker-compose ps | grep -q "Up"; then
        warn "Containers don't appear to be running. Starting them first..."
        docker-compose up -d
        sleep 10
    fi
    
    # Create timestamp for blank backup
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_NAME="dolibarr_backup_${TIMESTAMP}_BLANK"
    BACKUP_DIR="/workspaces/dolibarr/docker-deploy/backups/$BACKUP_NAME"
    
    log "Creating blank backup: $BACKUP_NAME"
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    
    # Backup database
    log "📊 Backing up database (blank state)..."
    docker-compose exec -T db mysqldump -u root -p"rootpassword" --routines --triggers dolibarr > "$BACKUP_DIR/database.sql"
    
    # Backup documents directory
    log "📁 Backing up documents directory (should be mostly empty)..."
    if docker-compose exec app test -d /var/www/html/documents; then
        docker-compose exec -T app tar -czf - -C /var/www/html documents > "$BACKUP_DIR/documents.tar.gz"
    else
        warn "Documents directory not found, creating empty archive"
        touch "$BACKUP_DIR/documents.tar.gz"
    fi
    
    # Backup configuration
    log "⚙️ Backing up configuration files..."
    mkdir -p "$BACKUP_DIR/config"
    if docker-compose exec app test -f /var/www/html/conf/conf.php; then
        docker-compose exec -T app cat /var/www/html/conf/conf.php > "$BACKUP_DIR/config/conf.php"
    fi
    
    # Create marker file indicating this is a blank backup
    cat > "$BACKUP_DIR/BLANK_BACKUP_INFO.txt" << EOF
DOLIBARR BLANK BACKUP
====================

Created: $(date)
Type: Blank/Initial backup (after installation, before business data)
Purpose: Base state for system reset/clean start

This backup contains:
- Fresh Dolibarr installation database schema
- Initial configuration after setup
- Empty or minimal documents directory
- No business data (customers, invoices, products, etc.)

This backup should be preserved as your "clean slate" backup.
Use this to restore to a fresh state when needed.

Database size: $(stat --format="%s" "$BACKUP_DIR/database.sql" | numfmt --to=iec) bytes
Documents size: $(stat --format="%s" "$BACKUP_DIR/documents.tar.gz" | numfmt --to=iec) bytes
Total backup size: $(du -sh "$BACKUP_DIR" | cut -f1)
EOF
    # Also add a generic protected marker so rotation policies preserve it
    touch "$BACKUP_DIR/.protected"
    
    # Calculate and display backup size
    BACKUP_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
    
    success "✅ Blank backup created successfully!"
    echo ""
    info "📋 Backup Details:"
    info "   Name: $BACKUP_NAME"
    info "   Location: $BACKUP_DIR"
    info "   Size: $BACKUP_SIZE"
    info "   Type: BLANK/INITIAL"
    echo ""
    info "🔒 This backup will be preserved by the daily_exit.sh script"
    info "   (it keeps the oldest backup as the blank backup + 3 most recent)"
    echo ""
    
    # Update README with blank backup info
    if [ -f "README.md" ]; then
        if ! grep -q "BLANK BACKUP" README.md; then
            echo "" >> README.md
            echo "## Blank Backup Information" >> README.md
            echo "" >> README.md
            echo "**Blank Backup Created:** $(date)" >> README.md
            echo "**Backup Name:** $BACKUP_NAME" >> README.md
            echo "**Purpose:** Clean state backup for system reset" >> README.md
            echo "" >> README.md
            echo "This backup contains your Dolibarr installation immediately after setup," >> README.md
            echo "before any business data was added. It's automatically preserved by" >> README.md
            echo "the backup retention system." >> README.md
            echo "" >> README.md
        fi
    fi
    
    success "🎉 Blank backup process completed!"
    echo ""
    warn "📝 IMPORTANT: This backup is now marked as your 'blank' state."
    warn "   The daily backup retention will preserve this backup permanently."
    warn "   Use the restore script with this backup to return to a clean state."
}

# Run main function
main "$@"