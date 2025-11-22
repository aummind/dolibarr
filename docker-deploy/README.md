# Dolibarr Docker Deployment

## Overview
Complete Docker setup for Dolibarr ERP/CRM with PHP 8.2, MariaDB 10.11, and Nginx. This configuration has been tested and verified to work correctly.

## Software Versions (Tested Configuration)
- **Docker**: 28.3.1+
- **Docker Compose**: 2.38.2+
- **PHP**: 8.2.29 (FPM)
- **MariaDB**: 10.11.14
- **Nginx**: 1.28.0 (Alpine)
- **Redis**: 7.x (Alpine) [optional]
- **Dolibarr**: Latest (from source)

## Quick Start

### Prerequisites
- Docker and Docker Compose installed
- At least 2GB available RAM
- Port 8080 and 3306 available

### 1. Clone and Start
```bash
docker compose up -d
```

### 2. Access Application
- **Web Interface**: http://localhost:8080
- **Database**: localhost:3306 (user: dolibarr, password: dolibarrpass)
 
Tip (Codespaces): open the forwarded port 8080 from the Ports panel (https://<codespace>-8080.app.github.dev) to avoid URL-root mismatches.

### 3. Complete Installation

**Option A: Automatic (Recommended)**
```bash
# Copy smart configuration that auto-detects Docker environment
cp ../htdocs/conf/conf.php.example ../htdocs/conf/conf.php
# Configuration is ready! Open http://localhost:8080
```

**Option B: Manual via Installer**
1. Open http://localhost:8080
2. Follow the installation wizard
3. Use database settings:
   - Host: `db`
   - Database: `dolibarr`
   - User: `dolibarr`
   - Password: `dolibarrpass`

### Recreation from Scratch
If you need to recreate this setup on a new system:
```bash
# Automated recreation
./recreate_dolibarr.sh

# Or follow detailed instructions in setup/05-backup-system.md
```

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Nginx Web     │    │   PHP-FPM App   │    │   MariaDB DB    │    │     Redis       │
│   Port: 8080    │───▶│   PHP 8.2       │───▶│   Port: 3306    │◀──▶│   (optional)    │
│                 │    │   Dolibarr      │    │                 │    │   sessions/cache│
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │                       │
         ▼                       ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  nginx.conf     │    │  htdocs/        │    │  mariadb_data   │    │  (internal only)│
│  (config)       │    │  (source code)  │    │  (persistent)   │    │                  │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Services

### Web Server (nginx)
- **Image**: nginx:1.26.2-alpine
- **Port**: 8080 → 80
- **Purpose**: Serves static files and proxies PHP requests

### Application (app)
- **Image**: Custom PHP 8.2-FPM with extensions
- **Purpose**: Runs Dolibarr PHP application
- **Extensions**: mysqli, pdo_mysql, gd, zip, soap, intl, calendar, imap, etc.

### Database (db)
- **Image**: mariadb:10.11
- **Port**: 3306
- **Purpose**: MySQL-compatible database for Dolibarr

### Cache/Session (redis) — optional
- **Image**: redis:7-alpine
- **Port**: internal only (no published host port)
- **Purpose**: Optional sessions/cache/rate-limits. PHP Redis extension is preinstalled in the app image. Enable sessions via the script below.

## Volumes
- `mariadb_data`: Persistent database storage
- `dolibarr_documents`: Persistent document storage
- `../htdocs`: Dolibarr source code (bind mount)

## Configuration Files

### docker-compose.yml
Orchestrates all services and their connections.

### Dockerfile
Custom PHP image with all required Dolibarr extensions.

### nginx.conf
Nginx configuration for serving Dolibarr with PHP-FPM.

## Common Commands

### Start Services
```bash
docker compose up -d
```

Optional: start with health checks enabled (compose override):
```bash
docker compose -f docker-compose.yml -f docker-compose.healthchecks.yml up -d
```

### Stop Services
```bash
docker compose down
```

### View Logs
```bash
docker compose logs -f
```

### Restart Application
```bash
docker compose restart app
```

### Enable/Disable Redis-backed PHP sessions (optional)
```bash
# Enable Redis sessions (writes htdocs/.user.ini)
docker-deploy/project/redis_toggle.sh enable

# Disable (revert to file-based sessions)
docker-deploy/project/redis_toggle.sh disable
```

## Reports (deprecated directory)

The previous `docker-deploy/reports/` directory has been removed. Generated artifacts and audits, when needed, are emitted on-demand by helper scripts into `docker-deploy/debug_info/` (which is not committed and may be recreated by scripts such as `scripts/security/audit.sh` and `scripts/security/secret-scan.sh`).

For compliance/license traces, use the publishable `coos_backup/` assembled automatically by `daily_exit.sh` or manually via `docker-deploy/project/backup_coos.sh`.

## Quick diagnostics

Use these checks when something feels off:

```bash
# 1) Are containers up?
docker compose ps

# 2) Recent logs for a service (web/app/db)
docker compose logs --tail=100 -f app

# 3) Nginx config is valid?
docker compose exec web nginx -t

# 4) PHP extensions present? (mysqli/gd/intl)
docker compose exec app php -m | grep -E '^(mysqli|gd|intl)$'

# 5) Database reachable?
docker compose exec -T db mysqladmin ping -h localhost --silent
```

#### 500 on /admin/company.php or when saving settings
- Ensure DB host inside Docker is `db` (not `localhost`). The provided smart `conf.php.example` auto-detects Docker and sets DB to `db`.
- In Codespaces, use the forwarded URL from the Ports panel (…-8080.app.github.dev) to avoid URL-root mismatches.
- Check logs for details:
```bash
docker compose logs --tail=200 app
docker compose logs --tail=200 web
```

#### URL Root (Codespaces quick fix)
If you see redirects or URL mismatches after install, set Dolibarr's URL root to the forwarded HTTPS URL:
```bash
# Replace with your actual forwarded 8080 URL
FORWARDED="https://<your-codespace>-8080.app.github.dev"
sed -i "s#^\\$dolibarr_main_url_root=.*#\\$dolibarr_main_url_root='${FORWARDED}';#" ../htdocs/conf/conf.php
```

### Database Access
```bash
docker compose exec db mysql -u dolibarr -pdolibarrpass dolibarr
```

## Directory Structure
```
docker-deploy/
├── README.md              # This file
├── docker-compose.yml     # Service orchestration
├── Dockerfile            # PHP container definition
├── nginx.conf            # Web server configuration
├── backup/               # Configuration backups
│   ├── docker-compose.yml.backup
│   ├── Dockerfile.backup
│   └── nginx.conf.backup
└── setup/               # Detailed documentation
   ├── README.md
   ├── 01-installation.md
   ├── 02-configuration.md
   ├── 03-scripts.md
   ├── 04-daily-workflow.md
   └── 05-backup-system.md
```

## Documentation
Detailed documentation is available in the `setup/` directory:

- **[Setup Overview](setup/README.md)**: Complete setup documentation index
- **[Installation Guide](setup/01-installation.md)**: Step-by-step installation process
- **[Configuration Guide](setup/02-configuration.md)**: Smart configuration and customization
- **[Scripts Documentation](setup/03-scripts.md)**: All operational scripts reference
- **[Daily Workflow](setup/04-daily-workflow.md)**: Safe daily operations in Codespace
- **[Backup System](setup/05-backup-system.md)**: Complete backup and restore documentation
  

## Scripts Available

### Operational Scripts
- `backup_dolibarr.sh` - Create complete system backup
- `restore_dolibarr.sh` - Restore from backup
- `recreate_dolibarr.sh` - Recreate entire setup from scratch
- `daily_start.sh` - Daily startup routine with health checks
- `daily_exit.sh` - Safe daily exit with automatic backup
- `uninstall_app.sh` - Reset app to uninstalled state (removes DB/docs volumes)
- `mark_blank_backup.sh` - Mark current state as your preserved blank backup
- `make_blank_backup.sh` - Create and label a blank backup (e.g., `BLANK02`)
- `first_install.sh` - Bring stack up and check conf.php, documents dir, install.lock

### Usage Examples
```bash
# Create backup
./backup_dolibarr.sh

# Restore backup
./restore_dolibarr.sh /path/to/backup

# Recreate on new system
./recreate_dolibarr.sh new-installation

# Daily workflow
./daily_start.sh    # Start your daily session
./daily_exit.sh     # Safe exit with backup

# Mark your blank backup (after installation, before real data)
./mark_blank_backup.sh

# Create a labeled blank backup (e.g., BLANK02)
./make_blank_backup.sh BLANK02

# Uninstall/reset to a clean state (destroys DB + documents)
./uninstall_app.sh -y

# First-install helper (checks + guidance)
./first_install.sh --auto-conf --unlock --open
```

## Backup Management

### Backup Retention Policy

The backup system uses a smart retention policy:
- **Keeps maximum 3 recent backups** (from daily exits)
- **Always preserves the oldest "blank" backup** (your clean installation state)
- **Total of 4 backups maximum**: 3 recent + 1 blank

### Creating Your Blank Backup

After completing the Dolibarr installation but before adding real business data:

```bash
cd /workspaces/dolibarr/docker-deploy
./mark_blank_backup.sh
```

This creates a special "blank" backup that will be permanently preserved.

### Backup Types

1. **Blank Backup**: Clean installation state (marked with `_BLANK` suffix)
   - Created after installation, before business data
   - Permanently preserved by retention system (canonical `_BLANK`)
   - Use for system reset to clean state

2. **Daily Backups**: Regular operational backups
   ### Replace Blank With Current State

   To make the current latest backup the only preserved blank baseline and remove all others:

   ```bash
   cd /workspaces/dolibarr/docker-deploy/backups

   # Find latest backup and rename to canonical _BLANK
   latest="$(ls -1dt dolibarr_backup_* | head -1)" && \
   base="$(echo "$latest" | sed -E 's/_BLANK([0-9]+)?$//')" && \
   keep="${base}_BLANK" && \
   [ "$latest" != "$keep" ] && mv "$latest" "$keep" || true

   # Protect and document
   : > "$keep/.protected"
   cat > "$keep/BLANK_BACKUP_INFO.txt" <<EOF
   DOLIBARR BLANK BACKUP (canonical)
   =================================
   Created: $(date)
   Directory: $keep

   Purpose: Clean working baseline to restore to a known-good state.
   EOF

   # Remove all other backups (dangerous):
   for d in dolibarr_backup_*; do [ "$d" = "$keep" ] || rm -rf -- "$d"; done

   ls -ld "$keep"
   ```

   Note: This enforces a single canonical `_BLANK` backup policy.
   - Created automatically by `daily_exit.sh`
   - Contains all your business data
   - Only last 3 are kept (oldest deleted automatically)

## Security Notes
- Default passwords are for development only
- Change database credentials for production
- Configure SSL/TLS for production use
- Regularly update container images
- Optional hardening: see `security/nginx.hardening.conf` (non-official snippet). Include carefully in `nginx.conf` after enabling HTTPS.

## Support
- **Dolibarr Documentation**: https://wiki.dolibarr.org/
- **Dolibarr Forums**: https://www.dolibarr.org/forum
- **Docker Documentation**: https://docs.docker.com/

## License
This Docker configuration is provided under the same license as Dolibarr (GPL v3+).

---

**Last Updated**: November 13, 2025
**Configuration Status**: ✅ Tested and Working

