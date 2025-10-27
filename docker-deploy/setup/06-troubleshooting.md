# Troubleshooting Guide

## Overview
This guide covers common issues, their causes, and solutions for the Dolibarr Docker deployment.

---

## Container Issues

### Issue: 502 Bad Gateway

**Symptoms**: 
- Browser shows "502 Bad Gateway"
- Nginx error in logs

**Causes**:
1. PHP-FPM container not running
2. PHP-FPM not responding on port 9000
3. Containers stopped after Codespace pause

**Diagnosis**:
```bash
# Check container status
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml ps

# Check PHP-FPM logs
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml logs app | tail -50

# Check Nginx logs
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml logs web | tail -50
```

**Solutions**:

**Solution 1**: Start containers
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml up -d
```

**Solution 2**: Restart PHP-FPM
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml restart app
```

**Solution 3**: Full restart
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml down
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml up -d
```

---

### Issue: Containers Won't Start

**Symptoms**:
- `docker compose up` fails
- Container exits immediately
- "Port already in use" error

**Diagnosis**:
```bash
# Check for port conflicts
sudo netstat -tuln | grep -E ':(8080|3306)'

# Check Docker logs
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml logs

# Check Docker daemon
docker info
```

**Solutions**:

**Port conflict**:
```bash
# Find what's using the port
sudo lsof -i :8080
sudo lsof -i :3306

# Kill the process or change port in docker-compose.yml
```

**Corrupted containers**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml down
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml up -d --force-recreate
```

---

### Issue: Container Exits Immediately

**Symptoms**:
- Container status shows "Exited"
- No logs or very brief logs

**Diagnosis**:
```bash
# Check exit code and logs
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml ps -a
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml logs app
```

**Solutions**:

**Check Dockerfile syntax**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml build app
```

**View detailed container info**:
```bash
docker inspect docker-deploy-app-1
```

---

## Database Issues

### Issue: Can't Connect to Database

**Symptoms**:
- "Can't connect to MySQL server"
- "Access denied for user"
- Connection timeout

**Diagnosis**:
```bash
# Check MariaDB is running
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml ps db

# Check MariaDB logs
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml logs db | tail -50

# Test connection from PHP container
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app php -r "
\$conn = new mysqli('db', 'dolibarr', 'dolibarrpass', 'dolibarr');
echo \$conn->connect_error ? 'Failed: ' . \$conn->connect_error : 'OK';
"
```

**Solutions**:

**Wrong hostname**:
- ❌ Use `localhost` or `127.0.0.1`
- ✅ Use `db` (Docker service name)

**Verify credentials**:
```bash
# Check environment variables in docker-compose.yml
grep -A5 "db:" /workspaces/dolibarr/docker-deploy/docker-compose.yml

# Test connection
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysql -u dolibarr -pdoblibarrpass dolibarr -e "SELECT 1;"
```

**Database not ready**:
```bash
# Wait for MariaDB to be ready
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysqladmin ping -h localhost

# Check if database exists
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysql -u root -prootpassword -e "SHOW DATABASES;"
```

---

### Issue: Database Not Found

**Symptoms**:
- "Unknown database 'dolibarr'"
- Installer can't create database

**Diagnosis**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysql -u root -prootpassword -e "SHOW DATABASES;"
```

**Solution**:
```bash
# Create database manually
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysql -u root -prootpassword -e "
CREATE DATABASE IF NOT EXISTS dolibarr CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON dolibarr.* TO 'dolibarr'@'%';
FLUSH PRIVILEGES;
"
```

---

## PHP Issues

### Issue: "Driver mysqli not available"

**Symptoms**:
- Dolibarr installer shows mysqli error
- PHP fatal error about mysqli

**Diagnosis**:
```bash
# Check if mysqli is loaded
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app php -m | grep mysqli
```

**Solution**:
```bash
# Rebuild PHP container with mysqli
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml build --no-cache app
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml up -d
```

**Verify Dockerfile includes**:
```dockerfile
RUN docker-php-ext-install mysqli
```

---

### Issue: "Calendar/IMAP not supported"

**Symptoms**:
- Installer warning about missing extensions
- Features disabled

**Diagnosis**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app php -m | grep -E '(calendar|imap)'
```

**Solution**:

Ensure Dockerfile has:
```dockerfile
FROM php:8.2-fpm-bookworm  # Important: bookworm needed for IMAP

RUN apt-get update && apt-get install -y \
    libc-client-dev \
    libkrb5-dev \
    libssl-dev

RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl
RUN docker-php-ext-install calendar imap
```

Then rebuild:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml build --no-cache app
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml up -d
```

---

### Issue: Memory Limit Exceeded

**Symptoms**:
- "Allowed memory size exhausted"
- Large operations fail

**Diagnosis**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app php -r "echo ini_get('memory_limit');"
```

**Solution**:

Edit Dockerfile:
```dockerfile
RUN sed -i 's/memory_limit = 128M/memory_limit = 512M/' "$PHP_INI_DIR/php.ini"
```

Rebuild:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml build --no-cache app
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml up -d
```

---

### Issue: Maximum Execution Time Exceeded

**Symptoms**:
- "Maximum execution time of 30 seconds exceeded"
- Long operations timeout

**Diagnosis**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app php -r "echo ini_get('max_execution_time');"
```

**Solution**:

Already set to 300 in our Dockerfile. If needed, increase:
```dockerfile
RUN sed -i 's/max_execution_time = 30/max_execution_time = 600/' "$PHP_INI_DIR/php.ini"
```

---

## Dolibarr Application Issues

### Issue: "functions.lib.php not found"

**Symptoms**:
- Error message about missing functions.lib.php
- Blank page or error

**Cause**: conf.php exists but has incorrect paths (usually the example template)

**Diagnosis**:
```bash
# Check if conf.php is the example file
head -20 /workspaces/dolibarr/htdocs/conf/conf.php
```

**Solution**:
```bash
# Remove invalid conf.php
rm /workspaces/dolibarr/htdocs/conf/conf.php

# Access installer at http://localhost:8080/
```

---

### Issue: Stuck on Login Page (Can't Access Installer)

**Symptoms**:
- Installer won't load
- Redirects to login page
- Need to reinstall

**Cause**: Valid conf.php exists OR install.lock exists

**Solution**:

**Option 1**: Remove config (keeps database)
```bash
rm /workspaces/dolibarr/htdocs/conf/conf.php
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app rm -f /var/www/html/documents/install.lock
```

**Option 2**: Fresh install (deletes all data)
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml down -v
rm -f /workspaces/dolibarr/htdocs/conf/conf.php
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml up -d
```

---

### Issue: conf.php Keeps Getting Recreated

**Symptoms**:
- You delete conf.php but it reappears
- File contains example template

**Cause**: 
- conf.php.example being copied somewhere
- A script or process recreating it

**Solution**:
```bash
# Check what's in conf directory
ls -la /workspaces/dolibarr/htdocs/conf/

# Remove conf.php
rm /workspaces/dolibarr/htdocs/conf/conf.php

# Check it's also removed in container
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app ls -la /var/www/html/conf/
```

**Prevent recreation**: The installer will create the proper conf.php once you complete installation.

---

### Issue: Permission Denied Errors

**Symptoms**:
- Can't write to conf/
- Can't write to documents/
- "Permission denied" errors

**Diagnosis**:
```bash
# Check permissions
ls -la /workspaces/dolibarr/htdocs/ | grep -E '(conf|documents)'

# Check inside container
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app ls -la /var/www/html/ | grep -E '(conf|documents)'

# Check effective user
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app id
```

**Solution**:
```bash
# Fix permissions on host
chmod -R 777 /workspaces/dolibarr/htdocs/conf
chmod -R 777 /workspaces/dolibarr/htdocs/documents

# Or specific to dolibarr user (UID 1000)
chown -R 1000:1000 /workspaces/dolibarr/htdocs/conf
chown -R 1000:1000 /workspaces/dolibarr/htdocs/documents
```

---

### Issue: File Upload Fails

**Symptoms**:
- Can't upload files
- "File too large" error
- Upload timeout

**Diagnosis**:
```bash
# Check PHP limits
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app php -r "
echo 'upload_max_filesize: ' . ini_get('upload_max_filesize') . PHP_EOL;
echo 'post_max_size: ' . ini_get('post_max_size') . PHP_EOL;
echo 'max_execution_time: ' . ini_get('max_execution_time') . PHP_EOL;
"

# Check Nginx client body size
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec web nginx -T | grep client_max_body_size
```

**Solution**:

**Increase PHP limits** in Dockerfile:
```dockerfile
RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/' "$PHP_INI_DIR/php.ini"
RUN sed -i 's/post_max_size = 8M/post_max_size = 50M/' "$PHP_INI_DIR/php.ini"
```

**Increase Nginx limit** in nginx.conf:
```nginx
server {
    client_max_body_size 50M;
    # ...
}
```

Then rebuild/restart:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml build --no-cache app
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml restart web
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml up -d
```

---

## Network Issues

### Issue: Can't Access from Codespace URL

**Symptoms**:
- Codespace URL doesn't work
- Connection timeout
- localhost works but not public URL

**Solutions**:

**Check port forwarding**:
1. In VS Code, open "PORTS" panel
2. Ensure port 8080 is forwarded
3. Check visibility is "Public"

**Restart port forwarding**:
1. Right-click port 8080 → "Remove Port"
2. Restart containers
3. Port should auto-forward

**Manual forward**:
```bash
# In VS Code terminal
# Forward port 8080
```

---

### Issue: Nginx Shows Default Page

**Symptoms**:
- "Welcome to nginx!" page
- Not showing Dolibarr

**Cause**: nginx.conf not mounted or default config loading

**Diagnosis**:
```bash
# Check nginx config
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec web cat /etc/nginx/conf.d/default.conf
```

**Solution**:

Verify docker-compose.yml has:
```yaml
web:
  volumes:
    - ./nginx.conf:/etc/nginx/conf.d/default.conf
```

Restart:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml restart web
```

---

## Performance Issues

### Issue: Slow Page Load

**Causes**:
1. PHP not optimized
2. Database queries slow
3. Large file operations

**Diagnosis**:
```bash
# Check PHP-FPM processes
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app ps aux

# Check slow queries
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysql -u root -prootpassword -e "SHOW PROCESSLIST;"

# Check container resources
docker stats
```

**Solutions**:

**Enable PHP OPcache** (add to Dockerfile):
```dockerfile
RUN docker-php-ext-install opcache
```

**Tune MariaDB** (add to docker-compose.yml):
```yaml
db:
  command: >
    --character-set-server=utf8mb4
    --collation-server=utf8mb4_unicode_ci
    --innodb_buffer_pool_size=512M
```

**Add nginx caching** (nginx.conf):
```nginx
location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

---

## Debugging Tools

### View All Container Logs
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml logs -f
```

### Follow Specific Service
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml logs -f app
```

### Execute Commands in Containers
```bash
# PHP container bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app bash

# MariaDB shell
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysql -u root -prootpassword

# Nginx shell
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec web sh
```

### Check Container Stats
```bash
docker stats
```

### Inspect Container
```bash
docker inspect docker-deploy-app-1
```

### Check Docker Disk Usage
```bash
docker system df -v
```

---

## Emergency Recovery

### Complete Reset (Nuclear Option)

**⚠️ WARNING**: This deletes ALL data!

```bash
# Stop everything
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml down -v

# Remove images
docker rmi docker-deploy-app

# Clean Docker system
docker system prune -a

# Remove config
rm -f /workspaces/dolibarr/htdocs/conf/conf.php

# Rebuild from scratch
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml build --no-cache
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml up -d
```

### Restore from Backup

```bash
# Restore database
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec -T db mysql -u dolibarr -pdoblibarrpass dolibarr < backup.sql

# Restore config
cp conf.php.backup /workspaces/dolibarr/htdocs/conf/conf.php

# Restore documents
tar -xzf documents_backup.tar.gz -C /workspaces/dolibarr/htdocs/
```

---

## Getting Help

### Collect Diagnostic Information

```bash
# System info
uname -a
docker --version
docker compose version

# Container status
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml ps

# Logs
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml logs --tail=100 > logs.txt

# PHP info
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app php -v
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app php -m

# Database info
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysql --version
```

### Useful Resources

- **Dolibarr Forums**: https://www.dolibarr.org/forum
- **Dolibarr Wiki**: https://wiki.dolibarr.org/
- **Docker Documentation**: https://docs.docker.com/
- **GitHub Issues**: Create an issue in your repository with diagnostic info

---

**See Also**:
- [Docker Commands](01-docker-commands.md)
- [PHP Configuration](02-php-configuration.md)
- [Nginx Configuration](03-nginx-configuration.md)
- [MariaDB Configuration](04-mariadb-configuration.md)
- [Dolibarr Installation](05-dolibarr-installation.md)
