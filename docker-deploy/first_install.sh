#!/usr/bin/env bash

# Dolibarr First-Install Helper
# - Brings the stack up
# - Checks/creates default documents dir inside the container
# - Checks conf.php presence (and can auto-provision from example)
# - Checks install.lock (and can unlock)
# - Prints next-steps to complete the web installer safely
#
# Usage:
#   ./first_install.sh                     # run checks and guidance
#   ./first_install.sh --auto-conf         # copy conf.php.example -> conf.php
#   ./first_install.sh --unlock            # remove htdocs/install/install.lock
#   ./first_install.sh --open              # open installer URL in browser
#   ./first_install.sh -h|--help           # help

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DEPLOY_DIR="${SCRIPT_DIR}"
COMPOSE_FILE="${DEPLOY_DIR}/docker-compose.yml"

CONF_PATH="${ROOT_DIR}/htdocs/conf/conf.php"
CONF_EXAMPLE_PATH="${ROOT_DIR}/htdocs/conf/conf.php.example"
INSTALL_LOCK_PATH="${ROOT_DIR}/htdocs/install/install.lock"

AUTO_CONF="false"
UNLOCK="false"
OPEN_BROWSER="false"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'
log(){ echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $*${NC}"; }
info(){ echo -e "${BLUE}ℹ️  $*${NC}"; }
warn(){ echo -e "${YELLOW}⚠️  $*${NC}"; }
err(){ echo -e "${RED}❌ $*${NC}"; exit 1; }

usage(){
  cat <<EOF
Dolibarr First-Install Helper

Options:
  --auto-conf    Copy conf.php.example -> conf.php if missing
  --unlock       Remove install/install.lock if present
  --open         Open installer URL in system browser
  -h, --help     Show this help

Notes:
  - This script assumes Docker Compose V2 and runs from docker-deploy.
  - Database host inside Docker is 'db' (user: dolibarr, pass: dolibarrpass).
  - In Codespaces, use the forwarded HTTPS URL (…-8080.app.github.dev).
EOF
}

for arg in "$@"; do
  case "$arg" in
    --auto-conf) AUTO_CONF="true" ;;
    --unlock) UNLOCK="true" ;;
    --open) OPEN_BROWSER="true" ;;
    -h|--help) usage; exit 0 ;;
    *) err "Unknown option: $arg" ;;
  esac
done

require_compose(){
  command -v docker >/dev/null 2>&1 || err "Docker not found."
  docker compose version >/dev/null 2>&1 || err "Docker Compose V2 not found."
}

ensure_context(){
  [[ -f "$COMPOSE_FILE" ]] || err "docker-compose.yml not found in $DEPLOY_DIR"
  cd "$DEPLOY_DIR"
}

stack_up(){
  log "Starting Docker stack (if not already running)..."
  docker compose up -d
}

check_documents_dir(){
  log "Checking default documents directory inside app container..."
  # Ensure /var/www/html/documents exists and is writable; ensure /var/www/documents symlink
  docker compose exec -T app sh -lc '
    set -e
    d="/var/www/html/documents"
    if [ ! -d "$d" ]; then
      mkdir -p "$d"
    fi
    chown -R www-data:www-data "$d" || true
    if [ ! -e "/var/www/documents" ]; then
      ln -s "$d" /var/www/documents || true
    fi
    [ -w "$d" ] || { echo "not_writable"; exit 1; }
  ' >/dev/null || err "Documents directory not writable; check volume and permissions."
  info "Documents directory OK (writable)."
}

check_conf(){
  if [[ -f "$CONF_PATH" ]]; then
    info "conf.php exists: $CONF_PATH"
  else
    warn "conf.php not found at $CONF_PATH"
    if [[ "$AUTO_CONF" == "true" ]]; then
      [[ -f "$CONF_EXAMPLE_PATH" ]] || err "conf.php.example not found at $CONF_EXAMPLE_PATH"
      cp "$CONF_EXAMPLE_PATH" "$CONF_PATH"
      chmod 0640 "$CONF_PATH" || true
      info "Provisioned conf.php from example."
    else
      info "Run with --auto-conf to copy conf.php.example, or use the web installer to create it."
    fi
  fi
}

check_install_lock(){
  if [[ -f "$INSTALL_LOCK_PATH" ]]; then
    warn "install.lock present: $INSTALL_LOCK_PATH"
    if [[ "$UNLOCK" == "true" ]]; then
      rm -f "$INSTALL_LOCK_PATH"
      info "Removed install.lock."
    else
      info "Run with --unlock to remove install.lock and re-enable the installer."
    fi
  else
    info "install.lock not present (installer is enabled)."
  fi
}

open_installer(){
  local url="http://localhost:8080/install/"
  if [[ -n "${CODESPACE_NAME:-}" ]]; then
    # Best-effort guidance for Codespaces users
    warn "In Codespaces, use the forwarded HTTPS URL from the Ports panel."
  fi
  if [[ "$OPEN_BROWSER" == "true" ]]; then
    if command -v "$BROWSER" >/dev/null 2>&1; then
      "$BROWSER" "$url" || true
    else
      warn "\$BROWSER not set; open $url manually."
    fi
  fi
  cat <<EOF

Next steps:
- Open: $url
- Installer DB settings:
    Host: db
    Database: dolibarr
    User: dolibarr
    Password: dolibarrpass
- If you see URL mismatches in Codespaces, set dolibarr_main_url_root in conf.php
  to your forwarded 8080 HTTPS URL (…-8080.app.github.dev).
EOF
}

main(){
  require_compose
  ensure_context
  stack_up
  check_documents_dir
  check_conf
  check_install_lock
  open_installer
  log "First-install checks complete."
}

main "$@"
