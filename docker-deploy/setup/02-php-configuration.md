# PHP Configuration

## Overview
This guide covers the PHP-FPM setup, extensions, configuration, and customization for the Dolibarr application.

## PHP Version
- **Version**: 8.2-fpm
- **Base Image**: `php:8.2-fpm-bookworm`
- **OS**: Debian Bookworm (12)

## Why Debian Bookworm?

The specific `php:8.2-fpm-bookworm` image was chosen because:

1. **IMAP Support**: The `libc-client-dev` package required for PHP IMAP extension is only available in Debian Bookworm repositories
2. **Stability**: Bookworm is Debian 12 (stable), more reliable than trixie (testing/unstable)
3. **Package Availability**: All required system dependencies are available

### Versions Tried
- ❌ `php:8.2-fpm` (default - trixie) - Missing libc-client-dev
- ✅ `php:8.2-fpm-bookworm` - All dependencies available

## Installed PHP Extensions

### Database Extensions
| Extension | Purpose | Required By |
|-----------|---------|-------------|
| `pdo_mysql` | PDO MySQL driver | Dolibarr database access |
| `mysqli` | MySQL improved extension | Dolibarr (strict requirement) |

### Dolibarr Required Extensions
| Extension | Purpose | Status |
|-----------|---------|--------|
| `calendar` | Calendar functions | ✅ Required by Dolibarr |
| `imap` | Email/IMAP functions | ✅ Required by Dolibarr |

### General Extensions
| Extension | Purpose |
|-----------|---------|
| `zip` | Archive handling (ZIP files) |
| `gd` | Image manipulation (GD library) |
| `intl` | Internationalization support |
| `mbstring` | Multibyte string handling |
| `xml` | XML processing |
| `soap` | SOAP web services |
| `bcmath` | Arbitrary precision mathematics |
| `pcntl` | Process control functions |

### PECL Extensions
| Extension | Purpose |
|-----------|---------|
| `imagick` | Advanced image processing (ImageMagick) |

## System Dependencies

### For IMAP Extension
```dockerfile
libc-client-dev      # UW-IMAP C-client library
libkrb5-dev          # Kerberos authentication
libssl-dev           # SSL/TLS support
```

### For Image Processing
```dockerfile
libpng-dev           # PNG image support
libjpeg-dev          # JPEG image support
libfreetype6-dev     # FreeType font rendering
libmagickwand-dev    # ImageMagick library
```

### For Other Extensions
```dockerfile
libzip-dev           # ZIP archive library
zlib1g-dev           # Compression library
libonig-dev          # Oniguruma regex library (mbstring)
libicu-dev           # ICU internationalization library
libxml2-dev          # XML processing library
libxslt-dev          # XSLT transformation library
```

## PHP Configuration Settings

### Modified Settings (php.ini)

| Setting | Default | Modified | Reason |
|---------|---------|----------|--------|
| `memory_limit` | 128M | **256M** | Handle larger operations, reports |
| `max_execution_time` | 30 | **300** | Long-running batch processes |
| `date.timezone` | (not set) | **UTC** | Avoid timezone warnings |

### Configuration File Location
- **Container**: `/usr/local/etc/php/php.ini`
- **Base**: Copied from `php.ini-production`

### Applied in Dockerfile
```dockerfile
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && sed -i 's/memory_limit = 128M/memory_limit = 256M/' "$PHP_INI_DIR/php.ini" \
    && sed -i 's/max_execution_time = 30/max_execution_time = 300/' "$PHP_INI_DIR/php.ini" \
    && sed -i 's/;date.timezone =/date.timezone = UTC/' "$PHP_INI_DIR/php.ini"
```

## Extension Installation Process

### Configure Extensions
Some extensions need configuration before compilation:

```dockerfile
docker-php-ext-configure zip
docker-php-ext-configure gd --with-freetype --with-jpeg
docker-php-ext-configure imap --with-kerberos --with-imap-ssl
```

### Install Core Extensions
```dockerfile
docker-php-ext-install -j$(nproc) \
    pdo_mysql \
    mysqli \
    calendar \
    imap \
    zip \
    gd \
    intl \
    mbstring \
    xml \
    soap \
    bcmath \
    pcntl
```

**Note**: `-j$(nproc)` enables parallel compilation using all CPU cores

### Install PECL Extensions
```dockerfile
pecl install imagick
docker-php-ext-enable imagick
```

## User Configuration

### Dolibarr User
- **Username**: `dolibarr`
- **UID**: 1000
- **GID**: 1000

**Why UID 1000?**
- Matches typical host user in dev containers (Codespaces)
- Ensures proper file permissions on bind mounts
- Allows writing to htdocs/conf and documents directories

### User Creation
```dockerfile
RUN groupadd -g 1000 dolibarr \
    && useradd -u 1000 -g dolibarr -m dolibarr
```

### Directory Setup
```dockerfile
RUN mkdir -p /var/www/html/documents \
    && chown -R dolibarr:dolibarr /var/www/html
```

### Running as Non-Root
```dockerfile
USER dolibarr
```

**Security benefit**: Container processes run as non-root user

## Verifying PHP Configuration

### Check PHP Version
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app php -v
```

Expected output:
```
PHP 8.2.x (cli) (built: ...)
```

### List All Extensions
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app php -m
```

### Check Specific Extensions
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app php -m | grep -E '(mysqli|calendar|imap)'
```

Expected output:
```
calendar
imap
mysqli
```

### Check PHP Configuration
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app php -i
```

### Test Specific Settings
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app php -r "echo ini_get('memory_limit');"
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app php -r "echo ini_get('max_execution_time');"
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app php -r "echo ini_get('date.timezone');"
```

## Testing Extensions

### Test All Required Extensions
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app php -r "
\$required = ['mysqli', 'calendar', 'imap', 'gd', 'intl', 'mbstring', 'xml', 'zip'];
\$loaded = get_loaded_extensions();
foreach (\$required as \$ext) {
    echo \$ext . ': ' . (in_array(\$ext, \$loaded) ? 'OK' : 'MISSING') . PHP_EOL;
}
"
```

Expected output:
```
mysqli: OK
calendar: OK
imap: OK
gd: OK
intl: OK
mbstring: OK
xml: OK
zip: OK
```

### Test Database Connection
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app php -r "
\$conn = new mysqli('db', 'dolibarr', 'dolibarrpass', 'dolibarr');
if (\$conn->connect_error) {
    die('Connection failed: ' . \$conn->connect_error);
}
echo 'Database connection: OK' . PHP_EOL;
\$conn->close();
"
```

## Customizing PHP Configuration

### Method 1: Modify Dockerfile
Edit `/workspaces/dolibarr/docker-deploy/Dockerfile` and add settings:

```dockerfile
RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 20M/' "$PHP_INI_DIR/php.ini"
RUN sed -i 's/post_max_size = 8M/post_max_size = 20M/' "$PHP_INI_DIR/php.ini"
```

Then rebuild:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml build --no-cache app
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml up -d
```

### Method 2: Custom php.ini File
Create custom ini file and mount it:

1. Create `/workspaces/dolibarr/docker-deploy/custom-php.ini`:
```ini
upload_max_filesize = 20M
post_max_size = 20M
memory_limit = 512M
```

2. Add to docker-compose.yml volumes:
```yaml
services:
  app:
    volumes:
      - ./custom-php.ini:/usr/local/etc/php/conf.d/custom.ini
```

### Method 3: Runtime Configuration
For temporary changes (lost on restart):
```bash
docker compose exec app bash
echo "upload_max_filesize = 20M" >> /usr/local/etc/php/conf.d/custom.ini
```

## PHP-FPM Configuration

### Pool Configuration
Location: `/usr/local/etc/php-fpm.d/www.conf`

Key settings:
- **User/Group**: Automatically adjusted for non-root user
- **Listen**: `9000` (FastCGI port for Nginx)
- **Process Manager**: `dynamic`

### Viewing PHP-FPM Logs
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml logs -f app
```

Look for:
```
[27-Oct-2025 09:26:03] NOTICE: fpm is running, pid 1
[27-Oct-2025 09:26:03] NOTICE: ready to handle connections
```

## Common PHP Issues

### Issue: Extension Not Found
**Check if installed**:
```bash
docker compose exec app php -m | grep extension_name
```

**Solution**: Add to Dockerfile and rebuild

### Issue: Memory Limit Errors
**Check current limit**:
```bash
docker compose exec app php -r "echo ini_get('memory_limit');"
```

**Solution**: Increase in Dockerfile, rebuild

### Issue: Timeout on Long Operations
**Check execution time**:
```bash
docker compose exec app php -r "echo ini_get('max_execution_time');"
```

**Solution**: Increase `max_execution_time` in Dockerfile

### Issue: File Upload Too Large
**Check limits**:
```bash
docker compose exec app php -r "echo 'upload_max_filesize: ' . ini_get('upload_max_filesize') . PHP_EOL;"
docker compose exec app php -r "echo 'post_max_size: ' . ini_get('post_max_size') . PHP_EOL;"
```

**Solution**: Modify both settings in Dockerfile

## Performance Tuning

### Enable OPcache (Production)
Add to Dockerfile:
```dockerfile
RUN docker-php-ext-install opcache
```

Add configuration file:
```ini
opcache.enable=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=10000
opcache.revalidate_freq=2
opcache.fast_shutdown=1
```

### Adjust PHP-FPM Workers
Edit `www.conf`:
```ini
pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35
```

## Security Considerations

1. **Running as Non-Root**: Container uses `dolibarr` user (UID 1000)
2. **Expose Only Necessary Ports**: PHP-FPM on 9000 (internal to Docker network)
3. **Disable Dangerous Functions**: Consider adding to php.ini:
   ```ini
   disable_functions = exec,passthru,shell_exec,system,proc_open,popen
   ```
4. **Hide PHP Version**: Add to php.ini:
   ```ini
   expose_php = Off
   ```

## Reference

- **Dockerfile**: `/workspaces/dolibarr/docker-deploy/Dockerfile`
- **PHP Docker Hub**: https://hub.docker.com/_/php
- **PHP Documentation**: https://www.php.net/docs.php
- **Dolibarr Requirements**: https://wiki.dolibarr.org/index.php/Prerequisites

---

**See Also**:
- [Docker Commands](01-docker-commands.md)
- [Nginx Configuration](03-nginx-configuration.md)
- [Troubleshooting](06-troubleshooting.md)
