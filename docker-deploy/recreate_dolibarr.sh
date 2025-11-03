#!/bin/bash
# Complete Dolibarr Docker Recreation Script
# Usage: ./recreate_dolibarr.sh [target_directory]

set -Eeuo pipefail
trap 'echo -e "${RED}[${BASH_SOURCE[0]}:${LINENO}] Recreation failed. Check network connectivity and Docker status.${NC}"' ERR

# Configuration
TARGET_DIR="${1:-dolibarr-recreated}"
REPO_URL="https://github.com/aummind/dolibarr.git"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

# Banner
echo -e "${BLUE}"
echo "=============================================="
echo "   Dolibarr Docker Recreation Script"
echo "=============================================="
echo -e "${NC}"

log "Starting Dolibarr recreation process..."
info "Target directory: $TARGET_DIR"

# Check prerequisites
log "Checking prerequisites..."

# Check Docker
if ! command -v docker >/dev/null 2>&1; then
    error "Docker not found. Please install Docker first."
fi

DOCKER_VERSION=$(docker --version | grep -oP '\d+\.\d+\.\d+' | head -1)
log "Docker version: $DOCKER_VERSION"

# Check Docker Compose
if ! docker compose version >/dev/null 2>&1; then
    error "Docker Compose not found. Please install Docker Compose first."
fi

COMPOSE_VERSION=$(docker compose version | grep -oP '\d+\.\d+\.\d+' | head -1)
log "Docker Compose version: $COMPOSE_VERSION"

# Check Git
if ! command -v git >/dev/null 2>&1; then
    error "Git not found. Please install Git first."
fi

# Check ports
log "Checking port availability..."
if ss -ltn 2>/dev/null | grep -q ":8080\b"; then
    warn "Port 8080 is in use. You may need to stop the service or change the port."
fi

if ss -ltn 2>/dev/null | grep -q ":3306\b"; then
    warn "Port 3306 is in use. You may need to stop the service or change the port."
fi

# Clone or update repository
if [ -d "$TARGET_DIR" ]; then
    warn "Directory $TARGET_DIR already exists."
    read -p "Do you want to remove it and start fresh? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "Removing existing directory..."
        rm -rf "$TARGET_DIR"
    else
        log "Using existing directory..."
    fi
fi

if [ ! -d "$TARGET_DIR" ]; then
    log "Cloning Dolibarr repository..."
    git clone "$REPO_URL" "$TARGET_DIR"
else
    log "Updating existing repository..."
    cd "$TARGET_DIR"
    git pull origin develop
    cd ..
fi

# Navigate to docker directory
cd "$TARGET_DIR/docker-deploy"

# Verify required files exist
log "Verifying configuration files..."
required_files=("docker-compose.yml" "Dockerfile" "nginx.conf")
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        error "Required file $file not found!"
    else
        info "✓ $file found"
    fi
done

# Stop any existing containers
log "Stopping any existing containers..."
docker compose down 2>/dev/null || true

# Build containers
log "Building Docker containers..."
docker compose build

# Start services
log "Starting Docker services..."
docker compose up -d

# Wait for services to be ready
log "Waiting for services to be ready..."
for i in {1..20}; do
    if docker compose ps | grep -q "Up"; then break; fi; sleep 3;
done

# Verify services are running
log "Verifying services status..."
if ! docker compose ps | grep -q "Up"; then
    error "Some services failed to start!"
fi

# Check each service
services=("app" "db" "web")
for service in "${services[@]}"; do
    if docker compose ps | grep -q "$service.*Up"; then
        info "✓ $service is running"
    else
        warn "✗ $service is not running properly"
    fi
done

# Test connectivity
log "Testing connectivity..."

# Test web server
if curl -s -I http://localhost:8080 >/dev/null 2>&1; then
    info "✓ Web server is accessible"
else
    warn "✗ Web server may not be accessible yet"
fi

# Test database
if docker compose exec -T db mysqladmin ping -h localhost --silent >/dev/null 2>&1; then
    info "✓ Database is accessible"
else
    warn "✗ Database may not be ready yet"
fi

# Check PHP
PHP_VERSION=$(docker compose exec -T app php -v 2>/dev/null | head -1 || echo "Unknown")
info "PHP version: $PHP_VERSION"

# Check required PHP extensions
log "Checking PHP extensions..."
required_extensions=("mysqli" "pdo_mysql" "gd" "zip" "soap" "intl")
for ext in "${required_extensions[@]}"; do
    if docker compose exec -T app php -m 2>/dev/null | grep -q "^$ext$"; then
        info "✓ $ext extension loaded"
    else
        warn "✗ $ext extension not found"
    fi
done

# Set permissions
log "Setting correct permissions..."
chmod -R 777 ../htdocs/conf 2>/dev/null || warn "Could not set conf directory permissions"

# Remove any existing conf.php to ensure installer runs
if [ -f "../htdocs/conf/conf.php" ]; then
    log "Removing existing conf.php to ensure installer runs..."
    rm -f ../htdocs/conf/conf.php
fi

# Final status report
echo ""
echo -e "${GREEN}=============================================="
echo "   Recreation Complete!"
echo -e "==============================================${NC}"
echo ""

# Show container status
log "Final container status:"
docker compose ps

echo ""
log "🎉 Dolibarr Docker recreation completed successfully!"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "1. Open your browser and go to: ${YELLOW}http://localhost:8080${NC}"
echo "2. Complete the Dolibarr installation wizard"
echo "3. Use these database settings:"
echo "   - Host: ${YELLOW}db${NC}"
echo "   - Database: ${YELLOW}dolibarr${NC}"
echo "   - Username: ${YELLOW}dolibarr${NC}"
echo "   - Password: ${YELLOW}dolibarrpass${NC}"
echo ""
echo -e "${BLUE}Useful Commands:${NC}"
echo "   View logs: ${YELLOW}docker compose logs -f${NC}"
echo "   Stop services: ${YELLOW}docker compose down${NC}"
echo "   Restart services: ${YELLOW}docker compose restart${NC}"
echo "   Access database: ${YELLOW}docker compose exec db mysql -u dolibarr -p dolibarr${NC}"
echo ""

# Save recreation info
cat > recreation_info.txt << EOF
Dolibarr Docker Recreation Information
=====================================
Recreation Date: $(date)
Target Directory: $(pwd)
Repository: $REPO_URL
User: $(whoami)
Host: $(hostname)

Software Versions:
- Docker: $DOCKER_VERSION
- Docker Compose: $COMPOSE_VERSION
- PHP: $PHP_VERSION

Access Information:
- Web Interface: http://localhost:8080
- Database Host: localhost:3306
- Database Name: dolibarr
- Database User: dolibarr
- Database Password: dolibarrpass

Container Status:
$(docker compose ps)
EOF

log "Recreation information saved to: recreation_info.txt"

# Check if we're in a Codespace and show the forwarded URL
if [ -n "${CODESPACE_NAME:-}" ]; then
    echo ""
    echo -e "${BLUE}🚀 GitHub Codespace Detected!${NC}"
    echo "Your Dolibarr installation should be accessible at:"
    echo "${YELLOW}https://$CODESPACE_NAME-8080.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-githubpreview.dev}${NC}"
    echo ""
    echo "If the URL doesn't work:"
    echo "1. Check the 'PORTS' tab in VS Code"
    echo "2. Ensure port 8080 is forwarded and set to 'Public'"
fi