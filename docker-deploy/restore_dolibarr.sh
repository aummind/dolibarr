#!/bin/bash

# Dolibarr Docker Restore Script
# Usage: ./restore_dolibarr.sh /path/to/backup/directory

set -Eeuo pipefail
trap 'echo -e "${RED}[${BASH_SOURCE[0]}:${LINENO}] Restore failed. Check docker status and that the backup directory is valid.${NC}"' ERR

# Configuration
BACKUP_DIR="$1"
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

# Helpers
require_compose() {
    if ! docker compose version >/dev/null 2>&1; then
        error "Docker Compose V2 not found. Please install Docker and the compose plugin."
    fi
}

wait_for_db() {
    local tries=${1:-30}
    local sleep_s=${2:-2}
    for ((i=1;i<=tries;i++)); do
        if docker compose -f "$DOCKER_COMPOSE_FILE" exec -T db mysqladmin ping -h localhost --silent >/dev/null 2>&1; then
            return 0
        fi
        sleep "$sleep_s"
    done
    return 1
}

# Validate arguments
if [ -z "$BACKUP_DIR" ] || [ ! -d "$BACKUP_DIR" ]; then
    error "Usage: $0 /path/to/backup/directory"
fi

# Accept standard or BLANK backup metadata files
META_FILE=""
if [ -f "$BACKUP_DIR/backup_info.txt" ]; then
    META_FILE="$BACKUP_DIR/backup_info.txt"
elif [ -f "$BACKUP_DIR/BLANK_BACKUP_INFO.txt" ]; then
    META_FILE="$BACKUP_DIR/BLANK_BACKUP_INFO.txt"
else
    error "Invalid backup directory. Neither backup_info.txt nor BLANK_BACKUP_INFO.txt found."
fi

log "Starting Dolibarr restore process..."
log "Backup directory: $BACKUP_DIR"

require_compose

# Show backup information
echo ""
cat "$META_FILE"
echo ""

# Confirmation prompt
read -p "Are you sure you want to restore from this backup? This will overwrite current data! (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log "Restore cancelled by user."
    exit 0
fi

# Stop containers (ignore errors if none running)
log "Stopping Dolibarr containers..."
docker compose -f "$DOCKER_COMPOSE_FILE" down || true

# Restore configuration files
log "Restoring configuration files..."

if [ -f "$BACKUP_DIR/config/conf.php" ]; then
    # Ensure destination exists and is writable
    mkdir -p "/workspaces/dolibarr/htdocs/conf"
    if [ -f "/workspaces/dolibarr/htdocs/conf/conf.php" ]; then
        chmod u+w "/workspaces/dolibarr/htdocs/conf/conf.php" || true
    fi
    cp "$BACKUP_DIR/config/conf.php" "/workspaces/dolibarr/htdocs/conf/"
    # Harden conf.php permissions (read-only) after restore
    chmod 444 "/workspaces/dolibarr/htdocs/conf/conf.php" || true
    log "Restored conf.php"
fi

if [ -f "$BACKUP_DIR/config/docker-compose.yml" ]; then
    cp "$BACKUP_DIR/config/docker-compose.yml" "$DOCKER_COMPOSE_FILE"
    log "Restored docker-compose.yml"
fi

if [ -f "$BACKUP_DIR/config/Dockerfile" ]; then
    cp "$BACKUP_DIR/config/Dockerfile" "/workspaces/dolibarr/docker-deploy/"
    log "Restored Dockerfile"
fi

if [ -f "$BACKUP_DIR/config/nginx.conf" ]; then
    cp "$BACKUP_DIR/config/nginx.conf" "/workspaces/dolibarr/docker-deploy/"
    log "Restored nginx.conf"
fi

# Start containers (db first to speed up restore)
log "Starting Dolibarr containers..."
docker compose -f "$DOCKER_COMPOSE_FILE" up -d db

# Wait for database to be ready
log "Waiting for database to be ready..."
if wait_for_db 40 3; then
    log "Database is ready"
else
    warn "Database did not become ready in time; proceeding may fail"
fi

# Restore database
log "Restoring database..."
# Support both structured backups (database/*.sql) and flat backups (*.sql at root)
DATABASE_FILE=""
if [ -d "$BACKUP_DIR/database" ]; then
    DATABASE_FILE=$(find "$BACKUP_DIR/database" -maxdepth 1 -name "*.sql" | head -1)
fi
if [ -z "${DATABASE_FILE:-}" ]; then
    DATABASE_FILE=$(find "$BACKUP_DIR" -maxdepth 1 -name "*.sql" | head -1 || true)
fi

if [ -n "${DATABASE_FILE:-}" ] && [ -f "$DATABASE_FILE" ]; then
    # Drop existing database and recreate
    docker compose -f "$DOCKER_COMPOSE_FILE" exec -T db mysql -u root --password=rootpassword -e "
        DROP DATABASE IF EXISTS dolibarr;
        CREATE DATABASE dolibarr CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
        GRANT ALL PRIVILEGES ON dolibarr.* TO 'dolibarr'@'%';
        FLUSH PRIVILEGES;
    "
    
    # Restore database from backup
    docker compose -f "$DOCKER_COMPOSE_FILE" exec -T db mysql -u dolibarr --password=dolibarrpass dolibarr < "$DATABASE_FILE"
    
    log "Database restored from: $(basename "$DATABASE_FILE")"
else
    warn "No database backup file found"
fi

# Restore documents
log "Restoring documents..."
# Support both structured backups (documents/*.tar.gz) and flat backups (*.tar.gz at root)
DOCUMENTS_FILE=""
if [ -d "$BACKUP_DIR/documents" ]; then
    DOCUMENTS_FILE=$(find "$BACKUP_DIR/documents" -maxdepth 1 -name "*.tar.gz" | head -1)
fi
if [ -z "${DOCUMENTS_FILE:-}" ]; then
    DOCUMENTS_FILE=$(find "$BACKUP_DIR" -maxdepth 1 -name "*.tar.gz" | head -1 || true)
fi

if [ -n "${DOCUMENTS_FILE:-}" ] && [ -f "$DOCUMENTS_FILE" ]; then
    # Prepare destination and ensure ownership/permissions are sane
    mkdir -p /workspaces/dolibarr/htdocs/documents
    rm -rf /workspaces/dolibarr/htdocs/documents/*
    # Extract without preserving owner/permissions to avoid utime/chmod issues
    tar --no-same-owner --no-same-permissions --warning=no-timestamp -xzf "$DOCUMENTS_FILE" -C /workspaces/dolibarr/htdocs/
    
    # Fix permissions (developer-friendly in Codespaces)
    chown -R "$(id -u)":"$(id -g)" /workspaces/dolibarr/htdocs/documents || true
    chmod -R 775 /workspaces/dolibarr/htdocs/documents/ || true
    
    log "Documents restored from: $(basename "$DOCUMENTS_FILE")"
else
    warn "No documents backup file found"
fi

# Start remaining services
docker compose -f "$DOCKER_COMPOSE_FILE" up -d

# Final verification
log "Verifying restore..."
sleep 10

# Check container status
docker compose -f "$DOCKER_COMPOSE_FILE" ps

# Check database
DB_TABLES=$(docker compose -f "$DOCKER_COMPOSE_FILE" exec -T db mysql -u dolibarr --password=dolibarrpass dolibarr -e "SHOW TABLES;" | wc -l)
log "Database tables restored: $((DB_TABLES - 1))"

log "Restore completed successfully!"
log "Access your restored Dolibarr at: http://localhost:8080"