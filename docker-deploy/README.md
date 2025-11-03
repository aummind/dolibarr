# Dolibarr Docker Deployment

## Overview
Complete Docker setup for Dolibarr ERP/CRM with PHP 8.2, MariaDB 10.11, and Nginx. This configuration has been tested and verified to work correctly.

## Software Versions (Tested Configuration)
- **Docker**: 27.3.1+
- **Docker Compose**: 2.29.7+
- **PHP**: 8.2.24 (FPM)
- **MariaDB**: 10.11.8
- **Nginx**: 1.26.2 (Alpine)
- **Dolibarr**: Latest (from source)

## Quick Start

### Prerequisites
- Docker and Docker Compose installed
- At least 2GB available RAM
- Port 8080 and 3306 available

### 1. Clone and Start
```bash
cd /workspaces/dolibarr/docker-deploy
docker compose up -d
```

### 2. Access Application
- **Web Interface**: http://localhost:8080
- **Database**: localhost:3306 (user: dolibarr, password: dolibarrpass)

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
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Nginx Web    │    │   PHP-FPM App   │    │  MariaDB DB     │
│   Port: 8080    │───▶│   PHP 8.2       │───▶│   Port: 3306    │
│                 │    │   Dolibarr      │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  nginx.conf     │    │  htdocs/        │    │  mariadb_data   │
│  (config)       │    │  (source code)  │    │  (persistent)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
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
   - Permanently preserved by retention system
   - Use for system reset to clean state

2. **Daily Backups**: Regular operational backups
   - Created automatically by `daily_exit.sh`
   - Contains all your business data
   - Only last 3 are kept (oldest deleted automatically)

## Security Notes
- Default passwords are for development only
- Change database credentials for production
- Configure SSL/TLS for production use
- Regularly update container images

## Support
- **Dolibarr Documentation**: https://wiki.dolibarr.org/
- **Dolibarr Forums**: https://www.dolibarr.org/forum
- **Docker Documentation**: https://docs.docker.com/

## License
This Docker configuration is provided under the same license as Dolibarr (GPL v3+).

---

**Last Updated**: October 27, 2025
**Configuration Status**: ✅ Tested and Working
## Blank Backup Information

**Blank Backup Created:** Fri Oct 31 12:07:22 UTC 2025
**Backup Name:** dolibarr_backup_20251031_120719_BLANK
**Purpose:** Clean state backup for system reset

This backup contains your Dolibarr installation immediately after setup,
before any business data was added. It's automatically preserved by
the backup retention system.

