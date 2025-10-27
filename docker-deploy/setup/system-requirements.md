# System Requirements

## Hardware Requirements

### Minimum
- **CPU**: 1 core
- **RAM**: 1 GB
- **Disk**: 5 GB free space

### Recommended
- **CPU**: 2+ cores
- **RAM**: 2-4 GB
- **Disk**: 20+ GB free space (for database growth and documents)

### Production
- **CPU**: 4+ cores
- **RAM**: 8+ GB
- **Disk**: 100+ GB SSD
- **Backup**: Separate storage for backups

## Software Requirements

### Required

#### Docker
- **Version**: Docker Engine 20.10+
- **Docker Compose**: V2 (plugin version)
- **Check version**:
  ```bash
  docker --version
  docker compose version
  ```

#### Operating System
Tested on:
- ✅ Debian Bookworm (12)
- ✅ Ubuntu 20.04+
- ✅ GitHub Codespaces (Ubuntu 24.04)

Also compatible with:
- macOS (Docker Desktop)
- Windows (Docker Desktop with WSL2)
- Other Linux distributions

### Optional

#### Development Tools
- Git (for version control)
- VS Code (for editing)
- Database client (MySQL Workbench, DBeaver, etc.)

## Docker Images Used

### PHP-FPM (app)
- **Base Image**: `php:8.2-fpm-bookworm`
- **OS**: Debian Bookworm 12
- **Size**: ~500 MB (after build)

**Why Bookworm?**
- IMAP extension requires `libc-client-dev` package
- Only available in Bookworm repositories
- Stable Debian release (not testing/unstable)

### Nginx (web)
- **Image**: `nginx:stable-alpine`
- **OS**: Alpine Linux
- **Size**: ~25 MB
- **Version**: Latest stable

### MariaDB (db)
- **Image**: `mariadb:10.11`
- **Size**: ~400 MB
- **Version**: 10.11 LTS

## PHP Requirements

### PHP Version
- **Required**: PHP 8.0+
- **Used**: PHP 8.2
- **Recommended**: PHP 8.2 or 8.3

### Required PHP Extensions
| Extension | Purpose | Status |
|-----------|---------|--------|
| `mysqli` | Database connectivity | ✅ Installed |
| `calendar` | Calendar functions | ✅ Installed |
| `imap` | Email functionality | ✅ Installed |
| `gd` | Image processing | ✅ Installed |
| `intl` | Internationalization | ✅ Installed |
| `mbstring` | Multibyte strings | ✅ Installed |
| `xml` | XML processing | ✅ Installed |
| `zip` | Archive handling | ✅ Installed |
| `soap` | Web services | ✅ Installed |
| `bcmath` | Precision math | ✅ Installed |

### Optional PHP Extensions
| Extension | Purpose | Status |
|-----------|---------|--------|
| `imagick` | Advanced image processing | ✅ Installed |
| `pcntl` | Process control | ✅ Installed |
| `opcache` | Performance cache | ⚠️ Not installed (recommended for production) |
| `ldap` | LDAP authentication | ❌ Not installed |

## System Dependencies

### For PHP Extensions

#### IMAP
```
libc-client-dev      # C-client library (Bookworm only)
libkrb5-dev          # Kerberos
libssl-dev           # SSL/TLS
```

#### Image Processing
```
libpng-dev           # PNG support
libjpeg-dev          # JPEG support
libfreetype6-dev     # Font rendering
libmagickwand-dev    # ImageMagick
```

#### Other
```
libzip-dev           # ZIP archives
libicu-dev           # Internationalization
libxml2-dev          # XML processing
libonig-dev          # Regex (mbstring)
```

## Database Requirements

### MariaDB/MySQL
- **MariaDB**: 10.3+ (using 10.11)
- **MySQL**: 5.6+ (8.0 recommended)

### Character Set
- **Encoding**: UTF-8 (utf8mb4)
- **Collation**: utf8mb4_unicode_ci

**Why utf8mb4?**
- Full Unicode support (4-byte characters)
- Supports emojis and international characters
- Required for modern applications

## Network Requirements

### Ports Used

| Service | Container Port | Host Port | Purpose |
|---------|---------------|-----------|---------|
| Nginx | 80 | 8080 | HTTP web access |
| PHP-FPM | 9000 | (internal) | FastCGI |
| MariaDB | 3306 | 3306 | Database (optional expose) |

### Port Availability
Ensure these ports are free on host:
```bash
# Check if ports are in use
sudo netstat -tuln | grep -E ':(8080|3306)'

# Or using lsof
sudo lsof -i :8080
sudo lsof -i :3306
```

### Firewall
If using firewall, allow:
- Port 8080 (HTTP)
- Port 3306 (if remote database access needed)

## Disk Space

### Initial Installation
- Docker images: ~1 GB
- Dolibarr files: ~200 MB
- Database (empty): ~50 MB
- **Total**: ~1.5 GB

### After 1 Year (Estimated)
- Database: 500 MB - 5 GB (depends on usage)
- Documents: 1-10 GB
- Logs: 100-500 MB
- **Total**: 3-20 GB

### Recommendations
- Monitor disk usage regularly
- Set up log rotation
- Archive old documents
- Regular database cleanup

## Memory Requirements

### Docker Container Memory

| Container | Minimum | Recommended | Notes |
|-----------|---------|-------------|-------|
| PHP-FPM | 256 MB | 512 MB | Per worker |
| Nginx | 50 MB | 100 MB | Minimal |
| MariaDB | 512 MB | 2 GB | InnoDB buffer |
| **Total** | **1 GB** | **3 GB** | |

### PHP Memory
- `memory_limit`: 256M (configured)
- Can increase for large operations
- Monitor with: `php -i | grep memory_limit`

## Browser Requirements

### Supported Browsers
- ✅ Chrome 90+
- ✅ Firefox 88+
- ✅ Safari 14+
- ✅ Edge 90+

### Not Supported
- ❌ Internet Explorer (any version)
- ⚠️ Older browser versions (pre-2020)

### Required Browser Features
- JavaScript enabled
- Cookies enabled
- LocalStorage support
- CSS3 support

## Development Environment

### GitHub Codespaces
- **OS**: Ubuntu 24.04 LTS
- **Resources**: 2 cores, 4 GB RAM (default)
- **Docker**: Pre-installed
- **Storage**: 32 GB

### Local Development
Minimum:
- Laptop/Desktop with Docker installed
- 4 GB RAM available for Docker
- 10 GB free disk space

Recommended:
- 8+ GB RAM
- SSD storage
- Stable internet connection (for image downloads)

## Production Environment

### Server Specifications
- **CPU**: 4+ cores
- **RAM**: 8+ GB
- **Disk**: 100+ GB SSD
- **Network**: Stable, low latency
- **Backup**: Separate backup storage

### Operating System
- Ubuntu Server 20.04 LTS or 22.04 LTS
- Debian 11 or 12
- RHEL/CentOS 8+
- Any Linux with Docker support

### Security Requirements
- SSL/TLS certificate (for HTTPS)
- Firewall configured
- Regular security updates
- Backup strategy
- Monitoring system

### High Availability (Optional)
- Load balancer
- Multiple app containers
- Database replication
- Shared storage for documents
- Reverse proxy (Nginx/HAProxy)

## Verification

### Check Docker Installation
```bash
# Docker version
docker --version
# Should show: Docker version 20.10+

# Docker Compose version
docker compose version
# Should show: Docker Compose version 2.x

# Test Docker
docker run hello-world
```

### Check System Resources
```bash
# Available memory
free -h

# Available disk space
df -h

# CPU cores
nproc

# Check ports
sudo netstat -tuln | grep -E ':(8080|3306)'
```

### Check Network
```bash
# Test connectivity
ping -c 3 google.com

# DNS resolution
nslookup docker.io
```

## Compatibility Matrix

### Tested Configurations

| OS | Docker | PHP | MariaDB | Status |
|-----|---------|-----|---------|--------|
| Ubuntu 24.04 | 24.0 | 8.2 | 10.11 | ✅ Working |
| Ubuntu 22.04 | 23.0 | 8.2 | 10.11 | ✅ Working |
| Debian 12 | 24.0 | 8.2 | 10.11 | ✅ Working |
| macOS (M1) | 24.0 | 8.2 | 10.11 | ✅ Working |
| Windows 11 + WSL2 | 24.0 | 8.2 | 10.11 | ✅ Working |

### Known Issues

**PHP 8.2-fpm (trixie/default)**:
- ❌ Missing `libc-client-dev` package
- ❌ Can't install IMAP extension
- ✅ **Solution**: Use `php:8.2-fpm-bookworm`

**Docker Compose V1**:
- ⚠️ Deprecated syntax
- ⚠️ Use `docker-compose` vs `docker compose`
- ✅ **Recommendation**: Upgrade to V2

## Upgrading

### Docker Engine
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

# Check version
docker --version
```

### Docker Compose
```bash
# Usually included with Docker Desktop
# Or install Docker Compose plugin
sudo apt-get install docker-compose-plugin
```

### System Updates
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get upgrade
```

## Performance Tuning

### Docker Settings

**Increase resources** (Docker Desktop):
- Settings → Resources
- CPU: 4+ cores
- Memory: 4+ GB
- Swap: 2 GB
- Disk: 60+ GB

### System Tuning

**Increase file watchers** (Linux):
```bash
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

**Increase limits**:
```bash
ulimit -n 65536  # Open files
ulimit -u 4096   # User processes
```

## Backup Requirements

### What to Backup
1. Database (`dolibarr`)
2. Configuration (`conf/conf.php`)
3. Documents volume (`dolibarr_documents`)
4. Custom files (if any)

### Backup Storage
- Minimum: Same size as data
- Recommended: 3x data size (for multiple backups)
- Best: Separate physical location

### Backup Tools
- `mysqldump` for database
- `tar` or `rsync` for files
- Docker volume backup tools
- Automated backup scripts

## Monitoring Requirements

### What to Monitor
- Container health
- Disk usage
- Memory usage
- Database performance
- Application logs
- Backup status

### Monitoring Tools (Optional)
- Docker stats
- Grafana + Prometheus
- Uptime monitors
- Log aggregation (ELK, Graylog)

---

**See Also**:
- [Architecture](architecture.md)
- [Docker Commands](01-docker-commands.md)
- [PHP Configuration](02-php-configuration.md)
