# Dolibarr Docker Setup Documentation

## Overview
This directory contains detailed setup and configuration documentation for each component of the Dolibarr Docker deployment.

## Documentation Structure

### Component Guides
- **[01-docker-commands.md](01-docker-commands.md)** - Docker Compose commands and container management
- **[02-php-configuration.md](02-php-configuration.md)** - PHP-FPM setup, extensions, and configuration
- **[03-nginx-configuration.md](03-nginx-configuration.md)** - Nginx web server setup and configuration
- **[04-mariadb-configuration.md](04-mariadb-configuration.md)** - MariaDB database setup and management
- **[05-dolibarr-installation.md](05-dolibarr-installation.md)** - Dolibarr installation process and configuration
- **[06-troubleshooting.md](06-troubleshooting.md)** - Common issues and solutions

### System Information
- **[system-requirements.md](system-requirements.md)** - Base OS, dependencies, and prerequisites
- **[architecture.md](architecture.md)** - System architecture and service relationships

## Quick Navigation

### Getting Started
1. Review [system-requirements.md](system-requirements.md) for prerequisites
2. Understand the [architecture.md](architecture.md)
3. Learn [Docker commands](01-docker-commands.md)
4. Configure components: [PHP](02-php-configuration.md), [Nginx](03-nginx-configuration.md), [MariaDB](04-mariadb-configuration.md)
5. Install [Dolibarr](05-dolibarr-installation.md)

### Having Issues?
Check [06-troubleshooting.md](06-troubleshooting.md) for common problems and solutions.

## Component Overview

### Docker Services
```
┌─────────────┐
│   Nginx     │ :80 → :8080 (host)
│   (web)     │
└──────┬──────┘
       │ FastCGI :9000
       ↓
┌─────────────┐
│  PHP-FPM    │
│   (app)     │
└──────┬──────┘
       │ MySQL Protocol :3306
       ↓
┌─────────────┐
│  MariaDB    │ :3306 → :3306 (host)
│   (db)      │
└─────────────┘
```

### Volumes
- `mariadb_data` - Database persistent storage
- `dolibarr_documents` - Document/file storage
- `../htdocs` - Application code (bind mount)

## Environment

- **Base OS**: Debian Bookworm 12
- **PHP**: 8.2-fpm
- **Web Server**: Nginx stable-alpine
- **Database**: MariaDB 10.11
- **Container Runtime**: Docker with Docker Compose V2

## Quick Commands Reference

### Start Everything
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml up -d
```

### Stop Everything
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml down
```

### View Logs
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml logs -f
```

### Check Status
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml ps
```

## File Locations

### Configuration Files
- `/workspaces/dolibarr/docker-deploy/Dockerfile` - PHP-FPM image definition
- `/workspaces/dolibarr/docker-deploy/docker-compose.yml` - Service orchestration
- `/workspaces/dolibarr/docker-deploy/nginx.conf` - Nginx configuration
- `/workspaces/dolibarr/htdocs/conf/conf.php` - Dolibarr configuration (created by installer)

### Data Directories
- `/workspaces/dolibarr/htdocs/` - Dolibarr application files
- Docker volumes managed by Docker Compose

## Version Information

- **Dolibarr**: 23.0.0-alpha
- **Documentation Date**: October 27, 2025
- **Last Updated By**: aummind

---

For detailed information on any component, see the individual documentation files listed above.
