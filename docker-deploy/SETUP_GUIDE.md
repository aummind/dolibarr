# Dolibarr Docker Deployment Setup Guide

## Overview
This guide documents the Docker-based deployment configuration for Dolibarr ERP/CRM, including all modifications made to ensure compatibility with PHP extensions and proper file permissions.

## System Information
- **Base OS**: Debian Bookworm (via php:8.2-fpm-bookworm)
- **PHP Version**: 8.2-fpm
- **Web Server**: Nginx (stable-alpine)
- **Database**: MariaDB 10.11
- **Container Runtime**: Docker with Docker Compose

## Architecture
The deployment consists of three services:
1. **web** - Nginx reverse proxy/web server
2. **app** - PHP-FPM application server
3. **db** - MariaDB database server

## Directory Structure
```
docker-deploy/
├── Dockerfile              # Custom PHP-FPM image with extensions
├── docker-compose.yml      # Service orchestration
├── nginx.conf             # Nginx configuration
└── SETUP_GUIDE.md         # This file

../htdocs/                 # Dolibarr application root (mounted as volume)
├── conf/                  # Configuration directory (writable)
│   └── conf.php          # Created by installer
└── documents/            # Document storage (writable, Docker volume)
```

## Docker Configuration Files

### 1. Dockerfile
**Location**: `docker-deploy/Dockerfile`

**Purpose**: Builds a custom PHP-FPM image with all required Dolibarr extensions

**Key Features**:
- Base image: `php:8.2-fpm-bookworm` (Debian Bookworm required for IMAP dependencies)
- PHP Extensions installed:
  - `pdo_mysql` - Database connectivity
  - `mysqli` - MySQL improved extension (required by Dolibarr)
  - `calendar` - Calendar functions (required by Dolibarr)
  - `imap` - IMAP email functions (required by Dolibarr)
  - `zip` - Archive handling
  - `gd` - Image manipulation
  - `intl` - Internationalization
  - `mbstring` - Multibyte string handling
  - `xml` - XML processing
  - `soap` - SOAP protocol support
  - `bcmath` - Arbitrary precision math
  - `pcntl` - Process control
  - `imagick` (via PECL) - Advanced image processing

**System Dependencies**:
- `libc-client-dev` - IMAP C-client library (only available in Bookworm)
- `libkrb5-dev` - Kerberos authentication for IMAP
- `libssl-dev` - SSL/TLS support for IMAP
- Standard libraries for image, zip, XML processing

**PHP Configuration**:
- Memory limit: 256M (increased from 128M default)
- Max execution time: 300 seconds (increased from 30s default)
- Timezone: UTC

**User Configuration**:
- User: `dolibarr` (UID: 1000, GID: 1000)
- Ensures file permissions match host user in dev containers

### 2. docker-compose.yml
**Location**: `docker-deploy/docker-compose.yml`

**Services Configuration**:

#### web (Nginx)
- Image: `nginx:stable-alpine`
- Port: `8080:80` (host:container)
- Volumes:
  - `./nginx.conf` → `/etc/nginx/conf.d/default.conf` (config)
  - `../htdocs` → `/var/www/html` (application code)
  - `dolibarr_documents` → `/var/www/html/documents` (persistent storage)
- **Note**: Removed `:ro` (read-only) flags to allow installer to write files

#### app (PHP-FPM)
- Build: Custom image from local Dockerfile
- Volumes:
  - `../htdocs` → `/var/www/html` (application code)
  - `dolibarr_documents` → `/var/www/html/documents` (persistent storage)
- Environment:
  - `PHP_INI_DIR=/usr/local/etc/php`
- **Note**: Removed problematic `conf.php` bind mount to allow Dolibarr to manage it

#### db (MariaDB)
- Image: `mariadb:10.11`
- Port: `3306:3306`
- Character set: `utf8mb4` with `utf8mb4_unicode_ci` collation
- Credentials:
  - Root password: `rootpassword`
  - Database: `dolibarr`
  - User: `dolibarr`
  - Password: `dolibarrpass`
- Volume: `mariadb_data` → `/var/lib/mysql` (persistent database)

**Docker Volumes**:
- `mariadb_data` - Persistent database storage
- `dolibarr_documents` - Persistent document/file storage

### 3. nginx.conf
**Location**: `docker-deploy/nginx.conf`

**Configuration Details**:
- Server listens on port 80
- Document root: `/var/www/html`
- Default index: `index.php`
- FastCGI PHP handling via `app:9000`
- Security:
  - Denies access to `.htaccess` files
  - Denies direct access to `/conf` directory (protects configuration)
- URL rewriting: Falls back to `index.php` for clean URLs

## Setup Instructions

### Prerequisites
- Docker Engine 20.10+
- Docker Compose V2
- Git

### Initial Setup

1. **Clone the repository**:
```bash
git clone <your-repo-url>
cd dolibarr/docker-deploy
```

2. **Build and start containers**:
```bash
docker compose build --no-cache
docker compose up -d
```

3. **Verify services are running**:
```bash
docker compose ps
```

Expected output:
```
NAME                  IMAGE                 COMMAND                  SERVICE   STATUS
docker-deploy-app-1   docker-deploy-app     "docker-php-entrypoi…"   app       Up
docker-deploy-db-1    mariadb:10.11         "docker-entrypoint.s…"   db        Up
docker-deploy-web-1   nginx:stable-alpine   "/docker-entrypoint.…"   web       Up
```

4. **Verify PHP extensions**:
```bash
docker compose exec app php -m | grep -E '(mysqli|calendar|imap)'
```

Expected output:
```
calendar
imap
mysqli
```

5. **Access Dolibarr installer**:
Open browser to: `http://localhost:8080/`

### Installation Process

1. The Dolibarr installer will automatically launch
2. Follow the setup wizard with these database settings:
   - **Database Type**: MySQL/MariaDB
   - **Database Host**: `db`
   - **Database Port**: `3306`
   - **Database Name**: `dolibarr`
   - **Database User**: `dolibarr`
   - **Database Password**: `dolibarrpass`
3. Create admin user credentials
4. Complete installation

The installer will:
- Create `htdocs/conf/conf.php` with proper configuration
- Initialize the database schema
- Create `htdocs/documents/install.lock` to prevent reinstallation

## Common Issues & Solutions

### Issue: "Driver mysqli for PHP not available"
**Solution**: Verify mysqli extension is installed:
```bash
docker compose exec app php -m | grep mysqli
```
If missing, rebuild the image:
```bash
docker compose build --no-cache app
docker compose up -d
```

### Issue: "functions.lib.php not found"
**Cause**: Invalid or empty `conf.php` file (usually the example template)

**Solution**: Remove conf.php and access the installer:
```bash
rm ../htdocs/conf/conf.php
```
Then navigate to `http://localhost:8080/`

### Issue: "Calendar/IMAP functions not supported"
**Cause**: PHP extensions not enabled or Debian version doesn't have libc-client-dev

**Solution**: Ensure using `php:8.2-fpm-bookworm` base image (not default or trixie):
- Bookworm (Debian 12) has `libc-client-dev` package
- Default/trixie images lack this dependency

### Issue: "Permission denied" writing conf.php
**Cause**: Read-only volume mounts or incorrect permissions

**Solution**: 
1. Ensure volumes don't have `:ro` flag in docker-compose.yml
2. Check permissions:
```bash
docker compose exec app ls -ld /var/www/html/conf
docker compose exec app id
```
Should be writable by uid 1000 (dolibarr user)

### Issue: Nginx 502 Bad Gateway
**Cause**: PHP-FPM service not running or incorrect FastCGI configuration

**Solution**:
```bash
docker compose logs app
docker compose restart app
```

## Maintenance Commands

### View logs
```bash
docker compose logs -f           # All services
docker compose logs -f app       # PHP-FPM only
docker compose logs -f web       # Nginx only
docker compose logs -f db        # MariaDB only
```

### Restart services
```bash
docker compose restart           # All services
docker compose restart app       # PHP-FPM only
```

### Stop and remove containers
```bash
docker compose down              # Keep volumes
docker compose down -v           # Remove volumes (deletes data!)
```

### Rebuild after changes
```bash
docker compose build --no-cache app
docker compose up -d
```

### Access container shell
```bash
docker compose exec app bash     # PHP-FPM container
docker compose exec web sh       # Nginx container (Alpine uses sh)
docker compose exec db bash      # MariaDB container
```

### Database backup
```bash
docker compose exec db mysqldump -u dolibarr -pdobibarrpass dolibarr > backup.sql
```

### Database restore
```bash
docker compose exec -T db mysql -u dolibarr -pdobibarrpass dolibarr < backup.sql
```

## Key Changes Made

### 1. PHP Base Image Selection
- **Changed from**: `php:8.2-fpm` (Debian trixie/unstable)
- **Changed to**: `php:8.2-fpm-bookworm` (Debian 12 stable)
- **Reason**: IMAP extension requires `libc-client-dev` package, only available in Bookworm repos

### 2. Volume Mount Modifications
- **Removed**: `:ro` (read-only) flags from web service volumes
- **Removed**: Direct bind mount of `conf.php` file (was mounting host directory as file)
- **Reason**: Installer needs write access to create configuration files

### 3. PHP Extensions Added
- **mysqli**: Required for MySQL database connectivity
- **calendar**: Required by Dolibarr for calendar functions
- **imap**: Required by Dolibarr for email integration
- **Reason**: Dolibarr installer checks for these and shows warnings if missing

### 4. PHP Configuration Tuning
- **memory_limit**: 128M → 256M (handle larger operations)
- **max_execution_time**: 30 → 300 seconds (long-running tasks)
- **date.timezone**: Set to UTC (avoid warnings)

### 5. User/Permission Setup
- Created dedicated `dolibarr` user (UID 1000, GID 1000)
- Pre-created `/var/www/html/documents` directory
- Set proper ownership for application directories
- **Reason**: Match host user UID in dev containers, ensure write permissions

### 6. Security Hardening (nginx.conf)
- Added `deny all` for `/conf` directory
- Added `deny all` for `.htaccess` files
- **Reason**: Prevent direct access to sensitive configuration files

## Production Considerations

For production deployment, consider:

1. **Security**:
   - Change default database passwords
   - Use secrets management (Docker secrets, environment files)
   - Enable HTTPS (add SSL certificates to nginx)
   - Restrict database port exposure (remove `ports:` from db service)

2. **Performance**:
   - Add PHP OPcache configuration
   - Configure nginx caching
   - Tune MariaDB configuration (buffer sizes, connection limits)
   - Consider using Redis for session storage

3. **Backup**:
   - Implement automated database backups
   - Backup document storage volume
   - Version control configuration files

4. **Monitoring**:
   - Add health checks to services
   - Configure logging aggregation
   - Monitor container resources

## Testing PHP Extensions

To verify all required extensions are available:

```bash
docker compose exec app php -r "
\$required = ['mysqli', 'calendar', 'imap', 'gd', 'intl', 'mbstring', 'xml', 'zip'];
\$loaded = get_loaded_extensions();
foreach (\$required as \$ext) {
    echo \$ext . ': ' . (in_array(\$ext, \$loaded) ? 'OK' : 'MISSING') . PHP_EOL;
}
"
```

## Database Connection Test

To verify database connectivity from PHP:

```bash
docker compose exec app php -r "
\$conn = new mysqli('db', 'dolibarr', 'dolibarrpass', 'dolibarr');
if (\$conn->connect_error) {
    die('Connection failed: ' . \$conn->connect_error);
}
echo 'Database connection: OK' . PHP_EOL;
\$conn->close();
"
```

## Version Information

- **Dolibarr**: 23.0.0-alpha (as of setup)
- **PHP**: 8.2 FPM
- **Nginx**: stable-alpine
- **MariaDB**: 10.11
- **Base OS**: Debian Bookworm (12)

## Support & References

- Dolibarr Documentation: https://www.dolibarr.org/documentation
- Docker Documentation: https://docs.docker.com/
- PHP Docker Images: https://hub.docker.com/_/php
- Nginx Documentation: https://nginx.org/en/docs/

## Changelog

- **2025-10-26**: Initial Docker setup
  - Created Dockerfile with PHP 8.2-fpm-bookworm base
  - Configured docker-compose.yml with nginx, php-fpm, mariadb services
  - Added nginx.conf with FastCGI and security settings
  - Enabled mysqli, calendar, imap PHP extensions
  - Fixed volume mounts for installer write access
  - Committed to git (commit: 3e41004)

---

**Last Updated**: October 26, 2025
**Maintained By**: aummind
**Repository**: dolibarr (develop branch)
