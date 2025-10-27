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

## Automated HTTPS with Let’s Encrypt (nginx-proxy)

This section explains how to enable secure HTTPS for your Dolibarr Docker stack using automated, production-grade certificates from Let’s Encrypt with `nginx-proxy` and `docker-letsencrypt-nginx-proxy-companion`.

### Prerequisites
- You must have a real domain name pointing to your server’s public IP.
- Ports 80 and 443 must be open and accessible from the internet.

### Steps

1. **Update `docker-compose.yml`**
   - Add the `nginx-proxy` and `letsencrypt` services as shown in the sample compose file.
   - In your `app` service, set these environment variables:
     - `VIRTUAL_HOST=your.domain.com`
     - `LETSENCRYPT_HOST=your.domain.com`
     - `LETSENCRYPT_EMAIL=your@email.com`
   - Replace with your actual domain and email.

2. **Start the stack**
   ```bash
   docker compose up -d
   ```
   This launches the proxy, companion, app, and db. The proxy will request and install a Let’s Encrypt certificate for your domain automatically.

3. **Check certificate issuance logs**
   ```bash
   docker logs nginx-letsencrypt
   ```
   You should see messages about certificate creation and renewal.

4. **Verify HTTPS**
   - Visit `https://your.domain.com` in your browser. You should see a valid SSL certificate (no warnings).

5. **Automatic Renewal**
   - The companion container will keep your certificates up to date automatically.

#### Notes
- If you need to support multiple domains, add them (comma-separated) to `VIRTUAL_HOST` and `LETSENCRYPT_HOST`.
- The proxy auto-generates Nginx config; you do not need a custom `nginx.conf`.
- For troubleshooting, see [06-troubleshooting.md](06-troubleshooting.md).

---
