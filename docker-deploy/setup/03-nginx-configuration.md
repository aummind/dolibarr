# Nginx Configuration

## Overview
Nginx serves as the web server and reverse proxy, handling HTTP requests and forwarding PHP requests to PHP-FPM via FastCGI.

## Nginx Version
- **Image**: `nginx:stable-alpine`
- **Base OS**: Alpine Linux
- **Architecture**: Lightweight, minimal footprint

## Configuration File

**Location**: `/workspaces/dolibarr/docker-deploy/nginx.conf`
**Mounted to**: `/etc/nginx/conf.d/default.conf` (inside container)

## Complete Configuration

```nginx
server {
    listen 80;
    server_name localhost;
    root /var/www/html;
    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ [^/]\.php(/|$) {
        fastcgi_split_path_info ^(.+?\.php)(/.*)$;
        fastcgi_pass app:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }

    # Deny access to .htaccess files
    location ~ /\.ht {
        deny all;
    }

    # Deny access to sensitive files
    location ~ ^/conf(/|$) {
        deny all;
    }
}
```

## Configuration Breakdown

### Server Block
```nginx
listen 80;
server_name localhost;
root /var/www/html;
index index.php;
```

| Directive | Value | Purpose |
|-----------|-------|---------|
| `listen` | `80` | HTTP port inside container (mapped to 8080 on host) |
| `server_name` | `localhost` | Server identifier |
| `root` | `/var/www/html` | Document root (Dolibarr htdocs directory) |
| `index` | `index.php` | Default file to serve |

### Location Block: Root (/)
```nginx
location / {
    try_files $uri $uri/ /index.php?$args;
}
```

**Purpose**: Handle all requests to root
**Behavior**:
1. Try to serve file directly (`$uri`)
2. Try to serve as directory (`$uri/`)
3. Fall back to `index.php` with query string (`/index.php?$args`)

**Example**:
- Request: `/admin/company.php`
- Nginx: Serves `/var/www/html/admin/company.php`
- Request: `/mypage`
- Nginx: Falls back to `/var/www/html/index.php?mypage`

### Location Block: PHP Files
```nginx
location ~ [^/]\.php(/|$) {
    fastcgi_split_path_info ^(.+?\.php)(/.*)$;
    fastcgi_pass app:9000;
    fastcgi_index index.php;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    fastcgi_param PATH_INFO $fastcgi_path_info;
}
```

**Purpose**: Process PHP files via PHP-FPM

| Directive | Value | Purpose |
|-----------|-------|---------|
| `location ~` | `[^/]\.php(/\|$)` | Match .php files (regex) |
| `fastcgi_split_path_info` | Regex pattern | Split script name from path info |
| `fastcgi_pass` | `app:9000` | Forward to PHP-FPM container on port 9000 |
| `fastcgi_index` | `index.php` | Default PHP file |
| `include` | `fastcgi_params` | Include FastCGI parameters |
| `fastcgi_param SCRIPT_FILENAME` | File path | Tell PHP which script to execute |
| `fastcgi_param PATH_INFO` | Path info | Additional path information |

**How it works**:
1. Client requests `/admin/company.php`
2. Nginx matches PHP location block
3. Forwards request to `app:9000` (PHP-FPM container)
4. PHP-FPM processes `/var/www/html/admin/company.php`
5. Returns HTML to Nginx
6. Nginx sends response to client

### Location Block: Deny .htaccess
```nginx
location ~ /\.ht {
    deny all;
}
```

**Purpose**: Block access to Apache `.htaccess` files
**Security**: Prevents exposure of configuration files

### Location Block: Deny /conf
```nginx
location ~ ^/conf(/|$) {
    deny all;
}
```

**Purpose**: Block direct access to configuration directory
**Security**: Protects `conf.php` and other sensitive config files

**Example**:
- Request: `/conf/conf.php`
- Response: 403 Forbidden

## Port Mapping

### Docker Compose Configuration
```yaml
services:
  web:
    ports:
      - "8080:80"
```

| Location | Port | Description |
|----------|------|-------------|
| Host (Codespace) | 8080 | External access port |
| Container (Nginx) | 80 | Internal Nginx port |

**Access URLs**:
- Local: `http://localhost:8080/`
- Codespace: `https://your-codespace-url-8080.app.github.dev/`

## Volume Mounts

```yaml
volumes:
  - ./nginx.conf:/etc/nginx/conf.d/default.conf
  - ../htdocs:/var/www/html
  - dolibarr_documents:/var/www/html/documents
```

| Host Path | Container Path | Purpose |
|-----------|---------------|---------|
| `./nginx.conf` | `/etc/nginx/conf.d/default.conf` | Nginx configuration |
| `../htdocs` | `/var/www/html` | Dolibarr application files |
| `dolibarr_documents` | `/var/www/html/documents` | Persistent document storage |

## Testing Nginx Configuration

### Check Nginx Status
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml ps web
```

### View Nginx Logs
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml logs -f web
```

### Test Configuration Syntax
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec web nginx -t
```

Expected output:
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

### Reload Configuration (After Changes)
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec web nginx -s reload
```

### Test HTTP Response
```bash
curl -I http://localhost:8080/
```

Expected:
```
HTTP/1.1 200 OK
Server: nginx
Content-Type: text/html; charset=UTF-8
```

## Customizing Nginx Configuration

### Method 1: Edit nginx.conf Directly
1. Edit `/workspaces/dolibarr/docker-deploy/nginx.conf`
2. Reload Nginx:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec web nginx -s reload
```

### Method 2: Restart Container
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml restart web
```

### Common Customizations

#### Increase Client Body Size (File Uploads)
```nginx
server {
    client_max_body_size 50M;
    # ... rest of configuration
}
```

#### Add Caching Headers
```nginx
location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

#### Enable Gzip Compression
```nginx
server {
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
    gzip_min_length 1000;
    # ... rest of configuration
}
```

#### Custom Error Pages
```nginx
error_page 404 /404.html;
error_page 500 502 503 504 /50x.html;
```

## Security Enhancements

### Basic Security Headers
Add to `server` block:
```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
```

### Block Direct IP Access
```nginx
server {
    listen 80 default_server;
    server_name _;
    return 444;
}

server {
    listen 80;
    server_name localhost your-domain.com;
    # ... your configuration
}
```

### Rate Limiting
```nginx
http {
    limit_req_zone $binary_remote_addr zone=one:10m rate=10r/s;
    
    server {
        location / {
            limit_req zone=one burst=20;
            # ... rest of configuration
        }
    }
}
```

## Nginx Access and Error Logs

### View Access Log
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec web tail -f /var/log/nginx/access.log
```

### View Error Log
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec web tail -f /var/log/nginx/error.log
```

### Access Log Format
```
172.18.0.1 - - [27/Oct/2025:09:30:00 +0000] "GET /index.php HTTP/1.1" 200 5000 "-" "Mozilla/5.0..."
```

## Troubleshooting

### Issue: 502 Bad Gateway
**Cause**: PHP-FPM not running or not accessible

**Check PHP-FPM**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml ps app
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml logs app
```

**Solution**: Restart app container
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml restart app
```

### Issue: 403 Forbidden
**Cause**: File permissions or directory access denied

**Check**:
```bash
docker compose exec web ls -la /var/www/html
```

**Solution**: Verify permissions match `dolibarr` user (UID 1000)

### Issue: 404 Not Found
**Cause**: File doesn't exist or wrong document root

**Verify document root**:
```bash
docker compose exec web ls /var/www/html/index.php
```

### Issue: PHP Files Downloaded Instead of Executed
**Cause**: FastCGI not configured correctly

**Check**:
```bash
docker compose exec web nginx -t
docker compose logs app
```

**Solution**: Verify `fastcgi_pass app:9000` points to correct service

### Issue: Configuration Changes Not Applied
**Solution**: Reload or restart Nginx
```bash
docker compose exec web nginx -s reload
# or
docker compose restart web
```

## Performance Tuning

### Worker Processes
Check available CPU cores:
```bash
docker compose exec web nproc
```

Adjust in main nginx.conf (not default.conf):
```nginx
worker_processes auto;
```

### Worker Connections
```nginx
events {
    worker_connections 1024;
}
```

### Keepalive Connections
```nginx
keepalive_timeout 65;
keepalive_requests 100;
```

### FastCGI Buffering
```nginx
location ~ \.php$ {
    fastcgi_buffering on;
    fastcgi_buffer_size 4k;
    fastcgi_buffers 8 4k;
    fastcgi_busy_buffers_size 8k;
    # ... rest of configuration
}
```

## HTTPS/SSL Configuration

For production, add SSL:

```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com;
    
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    
    # ... rest of configuration
}

server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}
```

## Reference

- **Configuration File**: `/workspaces/dolibarr/docker-deploy/nginx.conf`
- **Nginx Documentation**: https://nginx.org/en/docs/
- **Nginx Alpine Image**: https://hub.docker.com/_/nginx

---

**See Also**:
- [Docker Commands](01-docker-commands.md)
- [PHP Configuration](02-php-configuration.md)
- [Troubleshooting](06-troubleshooting.md)
