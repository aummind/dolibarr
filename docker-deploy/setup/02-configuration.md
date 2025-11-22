# Configuration Guide# Dolibarr Docker - Configuration Guide



Detailed configuration information for the Dolibarr Docker setup.## Overview

This guide covers customization and configuration options for your Dolibarr Docker deployment, including security, performance, and feature customization.

## Overview

## Container Configuration

This setup uses smart auto-configuration that adapts to the environment automatically. Manual configuration is rarely needed, but this guide explains how everything works.

### PHP Configuration (Dockerfile)

## Configuration Architecture

#### Memory and Execution Limits

```Current settings in Dockerfile:

┌─────────────────────────────────────────────────────────────┐```dockerfile

│                Configuration Flow                            │# Production PHP configuration with optimized settings

├─────────────────────────────────────────────────────────────┤RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \

│                                                             │    && sed -i 's/memory_limit = 128M/memory_limit = 256M/' "$PHP_INI_DIR/php.ini" \

│  conf.php.example  ──→  Auto-Detection  ──→  conf.php      │    && sed -i 's/max_execution_time = 30/max_execution_time = 300/' "$PHP_INI_DIR/php.ini" \

│  (Template)              (Runtime)           (Active)       │    && sed -i 's/;date.timezone =/date.timezone = UTC/' "$PHP_INI_DIR/php.ini"

│                                                             │```

│  • Environment vars     • Docker check      • Database     │

│  • Default values       • Path detection    • Paths        │**To customize these values:**

│  • Security settings    • URL generation    • Security     │1. Edit the Dockerfile

│                                                             │2. Rebuild the container: `docker compose build --no-cache app`

└─────────────────────────────────────────────────────────────┘3. Restart: `docker compose up -d`

```

**Common customizations:**

## Smart Configuration System```dockerfile

# For large installations

### Auto-Detection Featuressed -i 's/memory_limit = 256M/memory_limit = 512M/' "$PHP_INI_DIR/php.ini"



The `conf.php.example` file automatically detects:# For file uploads

sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/' "$PHP_INI_DIR/php.ini"

1. **Environment Type:**sed -i 's/post_max_size = 8M/post_max_size = 50M/' "$PHP_INI_DIR/php.ini"

   - Docker container environment

   - GitHub Codespace setup# For long-running operations

   - Local development setupsed -i 's/max_execution_time = 300/max_execution_time = 600/' "$PHP_INI_DIR/php.ini"

```

2. **Database Settings:**

   - Host: `db` (Docker service name)#### PHP Extensions

   - Database: `dolibarr`Current extensions in Dockerfile:

   - User: `dolibarr````dockerfile

   - Password: `dolibarrpass`RUN docker-php-ext-install -j$(nproc) \

    pdo_mysql \      # Database connectivity

3. **Path Configuration:**    mysqli \         # MySQL improved extension

   - Document root: `/var/www/html`    calendar \       # Calendar functions

   - Data directory: `/var/www/html/documents`    imap \          # Email functionality

   - Configuration path: `/var/www/html/conf`    zip \           # Archive handling

    gd \            # Image processing

4. **URL Settings:**    intl \          # Internationalization

   - Main URL: `http://localhost:8080`    mbstring \      # Multibyte string handling

   - Force HTTPS: Disabled (for Codespace compatibility)    xml \           # XML processing

    soap \          # SOAP web services

### Configuration Template    bcmath \        # Arbitrary precision mathematics

    pcntl           # Process control

```php```

<?php

// Smart Auto-Configuration for Dolibarr in Docker/Codespace**To add more extensions:**

// This file automatically detects environment and configures accordingly```dockerfile

# Add to the docker-php-ext-install command

// Auto-detect if we're running in DockerRUN docker-php-ext-install -j$(nproc) \

$is_docker = file_exists('/.dockerenv') ||     existing_extensions \

             (getenv('HOSTNAME') && preg_match('/^[a-f0-9]{12}$/', getenv('HOSTNAME'))) ||    ldap \          # LDAP authentication

             (getenv('DOCKER_CONTAINER') === 'true');    exif \          # Image metadata

    gettext         # Translation support

// Auto-detect if we're in a Codespace```

$is_codespace = (getenv('CODESPACE_NAME') !== false) || 

                (getenv('GITHUB_CODESPACE_TOKEN') !== false);### Database Configuration (MariaDB)



// Database Configuration (Docker service names)#### Performance Tuning

$dolibarr_main_db_host = $is_docker ? 'db' : 'localhost';Edit docker-compose.yml:

$dolibarr_main_db_port = '3306';```yaml

$dolibarr_main_db_name = 'dolibarr';db:

$dolibarr_main_db_user = 'dolibarr';  image: mariadb:10.11

$dolibarr_main_db_pass = 'dolibarrpass';

$dolibarr_main_db_type = 'mysqli';    --character-set-server=utf8mb4

$dolibarr_main_db_character_set = 'utf8mb4';    --collation-server=utf8mb4_unicode_ci

$dolibarr_main_db_collation = 'utf8mb4_unicode_ci';    --innodb_buffer_pool_size=512M

    --innodb_log_file_size=256M

// Auto-configure paths based on environment    --max_connections=200

if ($is_docker) {    --query_cache_size=64M

    $dolibarr_main_document_root = '/var/www/html';    --query_cache_type=1

    $dolibarr_main_url_root = 'http://localhost:8080';```

    $dolibarr_main_document_root_alt = '/var/www/html/documents';

} else {#### Security Hardening

    // Fallback for non-Docker environments```yaml

    $dolibarr_main_document_root = dirname(__FILE__);db:

    $dolibarr_main_url_root = 'http://localhost';  environment:

    $dolibarr_main_document_root_alt = $dolibarr_main_document_root . '/documents';    MYSQL_ROOT_PASSWORD: your_secure_root_password

}    MYSQL_DATABASE: dolibarr

    MYSQL_USER: dolibarr

// Security and Performance Settings
// Database password should be stored in .env file
// Never commit passwords to version control
    MYSQL_PASSWORD: dolibarrpass

$dolibarr_main_prod = '1';  // Production mode    # Remove root access from outside

$dolibarr_main_force_https = '0';  // Disabled for Codespace    MYSQL_ROOT_HOST: localhost

$dolibarr_main_authentication = 'dolibarr';```

$dolibarr_session_class = 'php';

$dolibarr_main_upload_maxfilesize = '20971520';  // 20MB### Web Server Configuration (Nginx)

```

#### Current nginx.conf

## Docker Compose Configuration```nginx

server {

### docker-compose.yml Structure    listen 80;

    server_name localhost;

```yaml    root /var/www/html;

version: '3.8'    index index.php index.html;



services:    # Security headers

  # Nginx Web Server (Port 8080)    add_header X-Frame-Options "SAMEORIGIN" always;

  web:    add_header X-XSS-Protection "1; mode=block" always;

    image: nginx:1.26.2-alpine    add_header X-Content-Type-Options "nosniff" always;

    ports:

      - "8080:80"    # Main application

    volumes:    location / {

      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro        try_files $uri $uri/ /index.php?$query_string;

      - dolibarr_documents:/var/www/html/documents    }

    depends_on:

      - app    # PHP processing

    location ~ \.php$ {

  # PHP-FPM Application Server          fastcgi_pass app:9000;

  app:        fastcgi_index index.php;

    build: .        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;

    volumes:        include fastcgi_params;

      # Dolibarr Docker – Configuration Guide

      Detailed configuration information for the Dolibarr Docker setup: containers, PHP/NGINX tuning, database, security, and performance.

      ## How configuration flows

      conf.php.example → auto-detection at runtime → conf.php (active)

      - Template lives at: `/workspaces/dolibarr/htdocs/conf/conf.php.example`
      - After installation, the active config is generated at: `/workspaces/dolibarr/htdocs/conf/conf.php`
      - Auto-detection chooses sane defaults for Docker/Codespaces; manual edits are rarely needed.

      ## Docker Compose configuration

      Key services and mounts (from `docker-deploy/docker-compose.yml`):

      ```yaml
      services:
        web:
          image: nginx:stable-alpine
          ports: ["8080:80"]
          volumes:
            - ./nginx.conf:/etc/nginx/conf.d/default.conf
            - ../htdocs:/var/www/html
            - dolibarr_documents:/var/www/html/documents
          depends_on: [app]

        app:
          build:
            context: .
            dockerfile: Dockerfile
          environment:
            PHP_INI_DIR: /usr/local/etc/php
          volumes:
            - ../htdocs:/var/www/html
            - dolibarr_documents:/var/www/html/documents
          depends_on: [db]

        db:
          image: mariadb:10.11
          command: ["--character-set-server=utf8mb4","--collation-server=utf8mb4_unicode_ci"]
          environment:
            MYSQL_ROOT_PASSWORD: rootpassword
            MYSQL_DATABASE: dolibarr
            MYSQL_USER: dolibarr
            MYSQL_PASSWORD: dolibarrpass
          volumes:
            - mariadb_data:/var/lib/mysql
          ports: ["3306:3306"]

      volumes:
        mariadb_data:
        dolibarr_documents:
      ```

      Notes
      - Web is exposed on host port 8080; DB is exposed on 3306 (handy for external tools; consider removing in production).
      - Code is mounted from `../htdocs`; documents have a named volume shared by web/app.
      - Service order: web → app → db.

      ## PHP configuration (App container)

      Base image and extensions are defined in `docker-deploy/Dockerfile` (PHP 8.2 FPM, Debian Bookworm). Installed extensions include: pdo_mysql, mysqli, calendar, imap, zip, gd, intl, mbstring, xml, soap, bcmath, pcntl, imagick.

      Production-leaning defaults (already applied in Dockerfile):

      ```dockerfile
      RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
          && sed -i 's/memory_limit = 128M/memory_limit = 256M/' "$PHP_INI_DIR/php.ini" \
          && sed -i 's/max_execution_time = 30/max_execution_time = 300/' "$PHP_INI_DIR/php.ini" \
          && sed -i 's/;date.timezone =/date.timezone = UTC/' "$PHP_INI_DIR/php.ini"
      ```

      Customize
      - Edit `docker-deploy/Dockerfile` (e.g., memory_limit, upload/post sizes, OPcache) and rebuild:

      ```bash
      docker compose build --no-cache app
      docker compose up -d
      ```

      Optional: Enable OPcache (for production):

      ```dockerfile
      RUN docker-php-ext-install opcache \
       && echo "opcache.enable=1" >> "$PHP_INI_DIR/php.ini" \
       && echo "opcache.memory_consumption=128" >> "$PHP_INI_DIR/php.ini" \
       && echo "opcache.max_accelerated_files=4000" >> "$PHP_INI_DIR/php.ini"
      ```

      ## Nginx configuration (Web)

      Defined in `docker-deploy/nginx.conf`:

      ```nginx
      server {
          listen 80;
          server_name localhost;
          root /var/www/html;
          index index.php;

          location / { try_files $uri $uri/ /index.php?$args; }

          location ~ [^/]\.php(/|$) {
              fastcgi_split_path_info ^(.+?\.php)(/.*)$;
              fastcgi_pass app:9000;
              fastcgi_index index.php;
              include fastcgi_params;
              fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
              fastcgi_param PATH_INFO $fastcgi_path_info;
          }

          # Block access to sensitive files/dirs
          location ~ /\.ht { deny all; }
          location ~ ^/conf(/|$) { deny all; }
      }
      ```

      Tips
      - Increase upload size by adding `client_max_body_size 50M;` inside `server {}` if needed.
      - For HTTPS in production, terminate TLS upstream or provide an SSL server block.

      ## Database configuration (MariaDB)

      Environment (from compose):

      ```yaml
      environment:
        MYSQL_ROOT_PASSWORD: rootpassword
        MYSQL_DATABASE: dolibarr
        MYSQL_USER: dolibarr
        MYSQL_PASSWORD: dolibarrpass
      ```

      Charset/collation are set to utf8mb4/unicode_ci via the container command. For production, consider not publishing `3306` to the host and placing DB on an internal-only network.

      ## Dolibarr application configuration

      - Template: `/workspaces/dolibarr/htdocs/conf/conf.php.example`
      - Active (after installer runs): `/workspaces/dolibarr/htdocs/conf/conf.php`

      Key runtime values selected automatically for Docker/Codespaces:
      - DB host `db`, port `3306`, name `dolibarr`, user `dolibarr`, pass `dolibarrpass`
      - URL root `http://localhost:8080`
      - Document root `/var/www/html`, documents `/var/www/html/documents`
      - Production mode on by default; HTTPS forced off in Codespaces

      ## Ports and volumes

      - Web: host 8080 → container 80
      - DB: host 3306 → container 3306 (optional in production)
      - Volumes: `mariadb_data` (DB persistence), `dolibarr_documents` (shared docs)

      ## Security hardening

      - Least exposure: avoid publishing DB port in prod; use a private Docker network.
      - File permissions: keep `htdocs/conf/conf.php` read-only post-install; ensure `htdocs/documents/` is writable by the app only.
      - Reverse-proxy headers: add security headers (X-Frame-Options, X-Content-Type-Options, etc.) in Nginx if required by policy.
      - Secrets: prefer environment injection via CI or Docker secrets (optional).

      ## Optional health checks (compose override)

      Health checks are optional and not required for local use, but you can enable them via a small compose override without touching your base file.

      - Override file: `docker-deploy/docker-compose.healthchecks.yml`
      - What it adds:
        - `db`: waits for MariaDB to accept connections via `mysqladmin ping`
        - `app`: verifies PHP is up with required extensions (mysqli, gd)
        - `web`: probes Nginx on http://localhost/ inside the container
        - Tightens startup order using `depends_on: condition: service_healthy`

      To use it, combine the files when starting your stack:

      ```bash
      cd docker-deploy
      docker compose -f docker-compose.yml -f docker-compose.healthchecks.yml up -d
      ```

      You can omit the override any time; it’s purely additive.

      Example (optional secrets wiring):

      ```yaml
      services:
        db:
          environment:
            MYSQL_ROOT_PASSWORD_FILE: /run/secrets/db_root_password
          secrets: [db_root_password]

      secrets:
        db_root_password:
          file: ./secrets/db_root_password.txt
      ```

      ## Performance tuning

      - PHP: raise `memory_limit`, `max_execution_time`, `upload_max_filesize`, `post_max_size` as needed in the Dockerfile and rebuild.
      - OPcache: enable and size per above.
      - MariaDB: tune buffer pool/log sizes based on dataset and memory.
      - Nginx: consider caching headers for static assets.

      ## Development vs production

      - Development (Codespaces): keep current ports; logs via `docker compose logs -f`.
      - Production: remove DB port publishing; add healthchecks, restarts, logging drivers; terminate TLS; consider external storage for volumes.

      ## Validate your configuration

      ```bash
      # Validate compose file
      docker compose config

      # PHP modules/ini
      docker compose exec app php --ini
      docker compose exec app php -m | sort

      # Nginx syntax
      docker compose exec web nginx -t

      # DB variables
      docker compose exec db mysql -e "SHOW VARIABLES LIKE 'collation_server';"
      ```

      ## Troubleshooting

      Quick checks:
        - `docker compose ps` – container status
        - `docker compose logs -f [service]` – service logs
        - Verify `htdocs/conf/conf.php` exists after installation

      ---

      Next steps
      - Docker commands reference: `03-scripts.md`
      - Daily workflow: `04-daily-workflow.md`
      - Backup & restore: `05-backup-system.md`