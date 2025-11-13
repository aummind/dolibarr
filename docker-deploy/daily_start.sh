#!/bin/bash
# Daily Codespace Startup Script
# Safely start Dolibarr containers and verify system health

set -Eeuo pipefail
trap 'echo -e "${RED}[${BASH_SOURCE[0]}:${LINENO}] Startup failed. Check docker status and logs with: docker compose ps && docker compose logs --tail=200${NC}"' ERR

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

# Wait helpers
wait_for_db() {
    local tries=${1:-30}
    local sleep_s=${2:-2}
    for ((i=1;i<=tries;i++)); do
        if docker compose exec -T db mysqladmin ping -h localhost --silent >/dev/null 2>&1; then
            return 0
        fi
        sleep "$sleep_s"
    done
    return 1
}

wait_for_web() {
    local url=${1:-http://localhost:8080}
    local tries=${2:-30}
    local sleep_s=${3:-2}
    for ((i=1;i<=tries;i++)); do
        if curl -s -o /dev/null -I -w "%{http_code}" "$url" | grep -qE '^(200|302)$'; then
            return 0
        fi
        sleep "$sleep_s"
    done
    return 1
}

# Banner
echo -e "${BLUE}"
echo "=============================================="
echo "   🚀 Daily Codespace Startup Process"
echo "=============================================="
echo -e "${NC}"

log "🚀 Starting daily Dolibarr session..."

require_compose

# Navigate to correct directory
cd /workspaces/dolibarr/docker-deploy

# Start or ensure all containers are up
log "▶️ Ensuring Docker containers are up..."
if docker compose up -d --remove-orphans; then
    log "✅ Containers started successfully"
else
    error "❌ Failed to start containers"
fi

# Wait for services to be ready
log "⏳ Waiting for services to initialize..."
sleep 15

EXPECTED_CONTAINERS=$(docker compose ps --services | wc -l | tr -d ' ')
RUNNING_CONTAINERS=0

# Progressive health checks
for i in {1..6}; do
    log "🔍 Health check attempt $i/6..."

    # Check container status
    RUNNING_CONTAINERS=$(docker compose ps --format 'table {{.Name}}\t{{.Status}}' | grep -c "Up" || echo "0")
    info "📊 Containers running: $RUNNING_CONTAINERS/$EXPECTED_CONTAINERS"

    if [ "$RUNNING_CONTAINERS" -ge "$EXPECTED_CONTAINERS" ]; then
        break
    fi

    if [ $i -lt 6 ]; then
        info "⏳ Waiting 10 more seconds..."
        sleep 10
    fi
done

# Verify services
log "🔍 Verifying service health..."
docker compose ps

log "🗄️ Testing database connection..."
if wait_for_db 20 3; then
    log "✅ Database is responsive"
else
    warn "⚠️ Database not responsive after waiting"
fi

log "🌐 Testing web application..."
if wait_for_web http://localhost:8080 20 3; then
    log "✅ Dolibarr web interface is accessible"
else
    warn "⚠️ Dolibarr web interface may not be ready yet"
fi

# Check backup status
BACKUP_COUNT=$(ls /workspaces/dolibarr/docker-deploy/backups/ 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt 0 ]; then
    LATEST_BACKUP=$(ls -t /workspaces/dolibarr/docker-deploy/backups/ | head -1)
    info "📦 Latest backup available: $LATEST_BACKUP"
else
    warn "⚠️ No backups found - consider creating one after your session"
fi

# Show final status
echo ""
echo -e "${BLUE}📊 Startup Summary:${NC}"
echo "- Containers running: $RUNNING_CONTAINERS/$EXPECTED_CONTAINERS"
echo "- Web interface: http://localhost:8080 (HTTP)"
echo "- Database: $(docker compose exec -T db mysqladmin ping -h localhost --silent && echo "✅ Ready" || echo "⚠️ Check manually")"
echo "- Backup count: $BACKUP_COUNT"
if [ "$BACKUP_COUNT" -gt 0 ]; then
    echo "- Latest backup: $LATEST_BACKUP"
fi
echo ""

# Detect Codespace environment
if [ -n "${CODESPACE_NAME:-}" ]; then
    CODESPACE_URL="https://$CODESPACE_NAME-8080.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-githubpreview.dev}"
    echo -e "${BLUE}🚀 GitHub Codespace Detected!${NC}"
    echo "Your Dolibarr installation is accessible at:"
    echo -e "${YELLOW}$CODESPACE_URL${NC}"
    echo ""
    echo "If the URL doesn't work:"
    echo "1. Check the 'PORTS' tab in VS Code"
    echo "2. Ensure port 8080 is forwarded and set to 'Public'"
    echo ""
fi

echo -e "${GREEN}✅ Dolibarr ready for daily use!${NC}"
echo ""

# Show useful commands
echo -e "${YELLOW}💡 Useful Commands:${NC}"
echo "- Create backup: ./backup_dolibarr.sh"
echo "- View logs: docker compose logs -f"
echo "- Stop safely: ./daily_exit.sh"
echo "- Container status: docker compose ps"
echo "- Database access: docker compose exec db mysql -u dolibarr -p dolibarr"
echo ""

# Optional health warnings
if [ "$RUNNING_CONTAINERS" -lt "$EXPECTED_CONTAINERS" ]; then
    echo -e "${YELLOW}⚠️ WARNING: Not all containers are running${NC}"
    echo "Run 'docker compose ps' to check status"
    echo "Run 'docker compose logs' to check for errors"
    echo ""
fi