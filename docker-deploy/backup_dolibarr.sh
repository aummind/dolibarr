#!/bin/bash

# Dolibarr Docker Backup Script
# Usage: ./backup_dolibarr.sh [backup_directory]

set -Eeuo pipefail  # Exit on error; fail on unset; catch pipe failures
umask 027           # Reasonable default permissions for created files/dirs
trap 'echo -e "${RED}[${BASH_SOURCE[0]}:${LINENO}] Backup failed. Check docker status and space usage.${NC}"' ERR

# Configuration
BACKUP_BASE_DIR="${1:-/workspaces/dolibarr/docker-deploy/backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_BASE_DIR/dolibarr_backup_$TIMESTAMP"
DOCKER_COMPOSE_FILE="/workspaces/dolibarr/docker-deploy/docker-compose.yml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Verify prerequisites
log "Starting Dolibarr backup process..."

# Check if Docker Compose is available
if ! docker compose version >/dev/null 2>&1; then
    error "Docker Compose V2 not found. Please install Docker and the compose plugin."
fi

# Check if containers are running
if ! docker compose -f "$DOCKER_COMPOSE_FILE" ps | grep -q "Up"; then
    error "Dolibarr containers are not running. Please start them first."
fi

# Create backup directory
log "Creating backup directory: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"/{database,documents,config}

# Backup database
log "Backing up database..."
docker compose -f "$DOCKER_COMPOSE_FILE" exec -T db mysqldump \
        -u dolibarr \
        --password=dolibarrpass \
        --single-transaction \
        --routines \
        --triggers \
        dolibarr > "$BACKUP_DIR/database/dolibarr_$TIMESTAMP.sql"

if [ $? -eq 0 ]; then
    log "Database backup completed: $(du -h "$BACKUP_DIR/database/dolibarr_$TIMESTAMP.sql" | cut -f1)"
else
    error "Database backup failed"
fi

# Backup documents
log "Backing up documents..."
if [ -d "/workspaces/dolibarr/htdocs/documents" ]; then
    # Create archive without extended attributes; deterministic gzip for reproducibility
    tar -czf "$BACKUP_DIR/documents/documents_$TIMESTAMP.tar.gz" \
        --xattrs --acls \
        -C /workspaces/dolibarr/htdocs documents/
    
    if [ $? -eq 0 ]; then
        log "Documents backup completed: $(du -h "$BACKUP_DIR/documents/documents_$TIMESTAMP.tar.gz" | cut -f1)"
    else
        warn "Documents backup failed or no documents found"
    fi
else
    warn "Documents directory not found"
fi

# Backup configuration files
log "Backing up configuration files..."

# Dolibarr configuration
if [ -f "/workspaces/dolibarr/htdocs/conf/conf.php" ]; then
    cp "/workspaces/dolibarr/htdocs/conf/conf.php" "$BACKUP_DIR/config/"
    log "Dolibarr conf.php backed up"
else
    warn "conf.php not found (may not be installed yet)"
fi

# Docker configuration files
cp "$DOCKER_COMPOSE_FILE" "$BACKUP_DIR/config/"
cp "/workspaces/dolibarr/docker-deploy/Dockerfile" "$BACKUP_DIR/config/"
cp "/workspaces/dolibarr/docker-deploy/nginx.conf" "$BACKUP_DIR/config/"

log "Docker configuration files backed up"

# Create backup information file
log "Creating backup information file..."
cat > "$BACKUP_DIR/backup_info.txt" << EOF
Dolibarr Docker Backup Information
=====================================
Backup Date: $(date)
Backup Directory: $BACKUP_DIR
Hostname: $(hostname)
User: $(whoami)

Software Versions:
- Docker: $(docker --version)
- Docker Compose: $(docker compose version)
- PHP: $(docker compose -f "$DOCKER_COMPOSE_FILE" exec app php -v | head -1)
- MariaDB: $(docker compose -f "$DOCKER_COMPOSE_FILE" exec db mysql --version)

Container Status at Backup Time:
$(docker compose -f "$DOCKER_COMPOSE_FILE" ps)

Database Size: $(du -h "$BACKUP_DIR/database/dolibarr_$TIMESTAMP.sql" 2>/dev/null | cut -f1 || echo "N/A")
Documents Size: $(du -h "$BACKUP_DIR/documents/documents_$TIMESTAMP.tar.gz" 2>/dev/null | cut -f1 || echo "N/A")
Total Backup Size: $(du -sh "$BACKUP_DIR" | cut -f1)

Restore Command:
./restore_dolibarr.sh "$BACKUP_DIR"
EOF

# Generate checksums for integrity verification
if command -v sha256sum >/dev/null 2>&1; then
    (
        cd "$BACKUP_DIR" || exit 0
        find database -maxdepth 1 -type f -name "*.sql" -print0 2>/dev/null | xargs -0 -I{} sha256sum "{}" >> checksums.sha256  || true
        find documents -maxdepth 1 -type f -name "*.tar.gz" -print0 2>/dev/null | xargs -0 -I{} sha256sum "{}" >> checksums.sha256 || true
        if [ -s checksums.sha256 ]; then
            log "Checksum file created: $BACKUP_DIR/checksums.sha256"
        fi
    )
fi

# Calculate total backup size
TOTAL_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)

log "Backup completed successfully!"
log "Backup location: $BACKUP_DIR"
log "Total size: $TOTAL_SIZE"
log ""
log "To restore this backup, run:"
log "  ./restore_dolibarr.sh \"$BACKUP_DIR\""

# Retention policy: keep only the latest 3 non-protected backups
RETENTION_COUNT=3
log "Applying retention policy (keep last ${RETENTION_COUNT} non-protected backups; preserve protected and BLANK backups)..."

# Build list of all backups (newest first)
mapfile -t ALL_BACKUPS < <(ls -dt ${BACKUP_BASE_DIR}/dolibarr_backup_* 2>/dev/null || true)

PROTECTED_BACKUPS=()
REGULAR_BACKUPS=()
for b in "${ALL_BACKUPS[@]}"; do
    [ -d "$b" ] || continue
    if [ -f "$b/.protected" ] || [[ "$(basename "$b")" == *"BLANK"* ]] || [ -f "$b/BLANK_BACKUP_INFO.txt" ]; then
        PROTECTED_BACKUPS+=("$b")
        continue
    fi
    REGULAR_BACKUPS+=("$b")
done

# Remove older regular backups beyond RETENTION_COUNT
if [ ${#REGULAR_BACKUPS[@]} -gt $RETENTION_COUNT ]; then
    for (( i=RETENTION_COUNT; i<${#REGULAR_BACKUPS[@]}; i++ )); do
        OLD_BACKUP="${REGULAR_BACKUPS[$i]}"
        if [ -n "$OLD_BACKUP" ] && [ -d "$OLD_BACKUP" ]; then
            log "Removing old backup: $(basename "$OLD_BACKUP")"
            rm -rf "$OLD_BACKUP"
        fi
    done
else
    log "No old regular backups to remove (${#REGULAR_BACKUPS[@]} present, limit ${RETENTION_COUNT})."
fi

REMAINING=$(ls -dt ${BACKUP_BASE_DIR}/dolibarr_backup_* 2>/dev/null | wc -l | tr -d ' ')
log "Backup rotation complete. Remaining backups: ${REMAINING} (protected/BLANK kept: ${#PROTECTED_BACKUPS[@]})"