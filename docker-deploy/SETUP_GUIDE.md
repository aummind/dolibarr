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

## Quick Start Commands

### Starting the Containers
```bash
# Navigate to docker-deploy directory
cd /workspaces/dolibarr/docker-deploy

# Start all services
docker compose up -d

# Or using full path from anywhere
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml up -d
```

### Checking Container Status
```bash
docker compose ps
```

### Viewing Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f app
docker compose logs -f web
docker compose logs -f db
```

### Stopping Containers
```bash
docker compose down              # Keep data
docker compose down -v           # Remove all data (careful!)
```

### Restarting After Codespace Resume
When your Codespace restarts or resumes from pause, containers will be stopped. Simply run:
```bash
cd /workspaces/dolibarr/docker-deploy
docker compose up -d
```

## Understanding Docker Compose Commands

Docker Compose has different commands for managing containers. Here's when to use each:

### Starting/Restarting Commands

#### `docker compose up -d`
**When to use**: First start OR after containers have been stopped/removed
**What it does**: 
- Creates containers if they don't exist
- Starts stopped containers
- Recreates containers if configuration changed
**Example**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml up -d
```

#### `docker compose start`
**When to use**: When containers exist but are stopped
**What it does**: 
- Only starts existing stopped containers
- Faster than `up` but doesn't recreate or update containers
**Example**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml start
```

#### `docker compose restart`
**When to use**: Quick restart without stopping/removing containers
**What it does**: 
- Restarts running containers in place
- Useful for applying PHP configuration changes
**Example**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml restart
```

### Stopping Commands

#### `docker compose stop`
**When to use**: Temporarily stop services (keeps containers)
**What it does**: 
- Stops containers but doesn't remove them
- Data and state preserved
- Fast to start again with `docker compose start`
**Example**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml stop
```

#### `docker compose down`
**When to use**: Stop and clean up (for rebuild or Codespace shutdown)
**What it does**: 
- Stops AND removes containers
- Removes networks
- Keeps volumes (data persists)
- Use `up -d` to start again
**Example**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml down
```

#### `docker compose down -v`
**⚠️ CAUTION**: This deletes ALL data!
**When to use**: Complete reset (fresh install)
**What it does**: 
- Stops and removes containers
- Removes volumes (deletes database and documents!)
- Only use for clean slate
**Example**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml down -v
```

### Why Multiple Command Formats?

You'll see commands in two formats:

**Short format** (from docker-deploy directory):
```bash
cd /workspaces/dolibarr/docker-deploy
docker compose up -d
```

**Full path format** (from anywhere):
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml up -d
```

Both do the same thing. Use full path when:
- You're not in the docker-deploy directory
- Running from scripts
- Codespace terminal opened in different directory

### Recommended Workflow

**Normal start/resume** (after Codespace restart):
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml up -d
```

**Quick restart** (containers already exist):
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml restart
```

**Clean stop** (pause work, keep data):
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml down
```

**After Dockerfile changes**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml build --no-cache app
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml up -d
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

## Complete Setup Instructions

### Prerequisites
- Docker Engine 20.10+
- Docker Compose V2
- Git

### Initial Setup from Scratch

1. **Clone the repository**:
```bash
git clone <your-repo-url>
cd dolibarr/docker-deploy
```

2. **Build the containers** (first time only):
```bash
docker compose build --no-cache
```

3. **Start all services**:
```bash
docker compose up -d
```

4. **Verify services are running**:
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

5. **Verify PHP extensions**:
```bash
docker compose exec app php -m | grep -E '(mysqli|calendar|imap)'
```

Expected output:
```
calendar
imap
mysqli
```

6. **Access Dolibarr installer**:
- Local: `http://localhost:8080/`
- Codespace: Your unique Codespace URL on port 8080

### Dolibarr Installation Process

1. The Dolibarr installer will automatically launch when you access the URL
2. Follow the setup wizard with these database settings:
   - **Database Type**: MySQL/MariaDB
   - **Database Host**: `db`
   - **Database Port**: `3306`
   - **Database Name**: `dolibarr`
   - **Database User**: `dolibarr`
   - **Database Password**: `dolibarrpass`
3. Create your admin user credentials
4. Complete the installation

The installer will:
- Create `htdocs/conf/conf.php` with proper configuration
- Initialize the database schema
- Create `htdocs/documents/install.lock` to prevent reinstallation

## Common Issues & Solutions

### Issue: 502 Bad Gateway
**Cause**: Containers are stopped (common after Codespace restart/pause)

**Solution**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml up -d
```

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

## Maintenance Commands

### Container Management
```bash
# Start containers
docker compose up -d

# Stop containers
docker compose stop

# Restart containers
docker compose restart

# Remove containers (keeps volumes/data)
docker compose down

# Remove everything including data (CAUTION!)
docker compose down -v
```

### Logs and Debugging
```bash
# View logs (all services)
docker compose logs -f

# View logs (specific service)
docker compose logs -f app
docker compose logs -f web
docker compose logs -f db

# Show last 50 lines
docker compose logs --tail=50 app
```

### Access Container Shell
```bash
# PHP-FPM container
docker compose exec app bash

# Nginx container (Alpine uses sh)
docker compose exec web sh

# MariaDB container
docker compose exec db bash
```

### Database Operations
```bash
# Backup database
docker compose exec db mysqldump -u dolibarr -pdoblibarrpass dolibarr > backup.sql

# Restore database
docker compose exec -T db mysql -u dolibarr -pdoblibarrpass dolibarr < backup.sql

# Access MySQL CLI
docker compose exec db mysql -u dolibarr -pdoblibarrpass dolibarr
```

### Rebuild After Configuration Changes
```bash
# Rebuild app image (after Dockerfile changes)
docker compose build --no-cache app

# Recreate containers
docker compose up -d --force-recreate
```

## Testing and Verification

### Test PHP Extensions
```bash
docker compose exec app php -r "
\$required = ['mysqli', 'calendar', 'imap', 'gd', 'intl', 'mbstring', 'xml', 'zip'];
\$loaded = get_loaded_extensions();
foreach (\$required as \$ext) {
    echo \$ext . ': ' . (in_array(\$ext, \$loaded) ? 'OK' : 'MISSING') . PHP_EOL;
}
"
```

### Test Database Connection
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

### Test Web Server
```bash
# From inside Codespace
curl -I http://localhost:8080/

# Should return HTTP 200 or 302 (redirect to installer)
```

## Key Changes Made During Setup

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
   - Use Docker secrets or environment files
   - Enable HTTPS (add SSL certificates to nginx)
   - Restrict database port exposure (remove `ports:` from db service)
   - Use specific image tags instead of `stable` or `latest`

2. **Performance**:
   - Add PHP OPcache configuration
   - Configure nginx caching
   - Tune MariaDB configuration (buffer sizes, connection limits)
   - Consider using Redis for session storage

3. **Backup Strategy**:
   - Implement automated database backups
   - Backup document storage volume regularly
   - Version control configuration files
   - Test restore procedures

4. **Monitoring**:
   - Add health checks to services
   - Configure logging aggregation
   - Monitor container resources
   - Set up alerts for service failures

## Troubleshooting Tips

### Containers Won't Start
```bash
# Check for port conflicts
sudo netstat -tuln | grep -E ':(8080|3306)'

# Check Docker daemon
docker info

# View detailed errors
docker compose logs
```

### Database Connection Issues
```bash
# Check if MariaDB is ready
docker compose exec db mysqladmin ping -h localhost

# Check database exists
docker compose exec db mysql -u root -prootpassword -e "SHOW DATABASES;"
```

### Permission Issues
```bash
# Check ownership inside container
docker compose exec app ls -la /var/www/html/conf

# Fix permissions if needed (from host)
chmod -R 777 /workspaces/dolibarr/htdocs/conf
chmod -R 777 /workspaces/dolibarr/htdocs/documents
```

### Reset Everything
If you need to start completely fresh:
```bash
# Stop and remove everything
docker compose down -v

# Remove built images
docker rmi docker-deploy-app

# Start from scratch
docker compose build --no-cache
docker compose up -d
```

## Version Information

- **Dolibarr**: 23.0.0-alpha (as of setup)
- **PHP**: 8.2 FPM
- **Nginx**: stable-alpine
- **MariaDB**: 10.11
- **Base OS**: Debian Bookworm (12)

## Useful Links

- Dolibarr Documentation: https://www.dolibarr.org/documentation
- Docker Documentation: https://docs.docker.com/
- Docker Compose Reference: https://docs.docker.com/compose/compose-file/
- PHP Docker Images: https://hub.docker.com/_/php
- Nginx Documentation: https://nginx.org/en/docs/
- MariaDB Documentation: https://mariadb.org/documentation/

## Changelog

- **2025-10-26**: Initial Docker setup
  - Created Dockerfile with PHP 8.2-fpm-bookworm base
  - Configured docker-compose.yml with nginx, php-fpm, mariadb services
  - Added nginx.conf with FastCGI and security settings
  - Enabled mysqli, calendar, imap PHP extensions
  - Fixed volume mounts for installer write access
  - Committed to git (commit: 3e41004)

- **2025-10-27**: Documentation update
  - Added comprehensive startup commands
  - Included Codespace restart procedures
  - Enhanced troubleshooting section
  - Added quick start commands section

---

**Last Updated**: October 27, 2025
**Maintained By**: aummind
**Repository**: dolibarr (develop branch)
