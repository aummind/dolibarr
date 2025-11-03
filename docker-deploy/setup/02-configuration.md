# Configuration Guide (clean)

This guide explains how to configure the Docker-based Dolibarr stack. It references the live files in this repo and keeps examples consistent with the current compose and Dockerfile.

Authoritative sources in this repo:
- Compose: `docker-deploy/docker-compose.yml`
- App image: `docker-deploy/Dockerfile`
- Nginx: `docker-deploy/nginx.conf`
- Security hardening (non-official): `docker-deploy/security/nginx.hardening.conf`
- Healthchecks override: `docker-deploy/docker-compose.healthchecks.yml`

## 1) PHP configuration (Dockerfile)

Current defaults applied in the image:
- memory_limit = 256M
- max_execution_time = 300
- date.timezone = UTC

Installed extensions (subset):
- Core: pdo_mysql, mysqli, mbstring, intl, xml, soap, bcmath, zip, gd, imap, calendar, pcntl
- PECL: imagick, redis (enabled)

How to change PHP settings
1) Edit `docker-deploy/Dockerfile` (e.g., memory_limit, upload/post sizes)
2) Rebuild and restart:
   - `cd docker-deploy`
   - `docker compose build --no-cache app`
   - `docker compose up -d`

Optional: enable OPcache for production
```dockerfile
RUN docker-php-ext-install opcache \
 && echo "opcache.enable=1" >> "$PHP_INI_DIR/php.ini" \
 && echo "opcache.memory_consumption=128" >> "$PHP_INI_DIR/php.ini" \
 && echo "opcache.max_accelerated_files=4000" >> "$PHP_INI_DIR/php.ini"
```

## 2) Nginx configuration

Base config: `docker-deploy/nginx.conf`
- Serves `/var/www/html` with PHP via `app:9000`
- Blocks access to `conf/` and dotfiles
- You can raise upload size by adding inside `server {}`:
  - `client_max_body_size 50M;`

Non-official hardening (optional): `docker-deploy/security/nginx.hardening.conf`
- TLS ciphers/policies, HSTS, security headers, deny script execution in uploads, basic rate limits.
- Review and adapt before production.

## 3) Compose services overview

Services (`docker-deploy/docker-compose.yml`):
- web: `nginx:stable-alpine`, exposes 8080→80, mounts code and documents volume
- app: PHP 8.2 FPM (built from Dockerfile), mounts code and documents
- db: `mariadb:10.11`, publishes 3306 for local tools (remove in production)
- redis: `redis:7-alpine`, internal only (no host port)

Volumes
- `mariadb_data`: DB persistence
- `dolibarr_documents`: shared Dolibarr documents directory

## 4) Sessions and Redis (optional)

- Redis service and PHP Redis extension are included, but sessions default to file-based.
- To enable Redis-backed PHP sessions (opt-in):
  - `scripts/project/redis_toggle.sh enable`
- To revert to file-based:
  - `scripts/project/redis_toggle.sh disable`

The toggle writes `htdocs/.user.ini` with:
```
session.save_handler = redis
session.save_path = "tcp://redis:6379?persistent=1&database=0&timeout=2&prefix=PHPSESSID:"
```

## 5) Environment variables

Use `project/ENV.sample` as a template and do not commit real secrets.

Key variables
- App: `APP_BASE_URL`, `TIMEZONE`
- DB: `DOLI_DB_HOST`, `DOLI_DB_NAME`, `DOLI_DB_USER`, `DOLI_DB_PASS`
- Bootstrap admin (first install only): `DOLI_ADMIN_USER`, `DOLI_ADMIN_PASS`
- Mail: `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASS`, `SMTP_FROM`
- Compliance: `COUNTRY=IN`, `STATE=KA`, `GST_ENABLED=1`, `KARNATAKA_RULES=1`
- E-invoicing (commented placeholders): `GST_EINVOICE_ENABLED`, `EINVOICE_PROVIDER`, `EINVOICE_API_BASE`, credentials
- Redis: `REDIS_HOST=redis`, `REDIS_PORT=6379` (feature toggled via script above)

## 6) MariaDB tuning (optional, non-official)

Adjust `db` command flags in compose for larger datasets, e.g.:
```yaml
db:
  image: mariadb:10.11
  command: >
    --character-set-server=utf8mb4
    --collation-server=utf8mb4_unicode_ci
    --innodb_buffer_pool_size=512M
    --innodb_log_file_size=256M
    --max_connections=200
```
Validate settings according to your instance size and memory.

## 7) Production notes

- Remove DB port publishing (3306) and keep DB on a private network.
- Add healthchecks with the provided override file:
  - `docker compose -f docker-compose.yml -f docker-compose.healthchecks.yml up -d`
- Secrets: inject via environment/secret management; avoid committing sensitive values.
- Logging/observability: enable access/error logs and log rotation.

## 8) Rebuild/apply changes

Typical workflow:
```bash
cd docker-deploy
# Update Dockerfile/nginx/compose as needed
docker compose build --pull app
docker compose up -d
# Verify
docker compose ps
docker compose logs -f app
```

---

This guide is kept short and aligned with the live files. For broader security and deployment guidance, see `SECURITY_HARDENING.md` and `project/DEPLOYMENT.md`. Non-official sections above are labeled accordingly.

## 9) Database charset and collation (recommended)

Dolibarr works best with full Unicode. Use utf8mb4 with utf8mb4_unicode_ci for both the server and the Dolibarr database.

Check current server defaults and database:
```bash
docker compose exec db mysql -e "SHOW VARIABLES LIKE 'character_set_server'; SHOW VARIABLES LIKE 'collation_server';"
docker compose exec db mysql -e "SELECT DEFAULT_CHARACTER_SET_NAME, DEFAULT_COLLATION_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME='dolibarr';"
```

Create or convert the database to utf8mb4 (destructive if you drop/recreate):
```bash
docker compose exec db sh -lc "mysql -u root -prootpassword -e \"
  DROP DATABASE IF EXISTS dolibarr;
  CREATE DATABASE dolibarr CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;\""
```

Align Dolibarr application config (first install via wizard will set this automatically):
```php
// htdocs/conf/conf.php
$dolibarr_main_db_character_set='utf8mb4';
$dolibarr_main_db_collation='utf8mb4_unicode_ci';
```

## 10) Re-run the installer (clean reset)

If you want to run the first-install wizard again:
```bash
# Restore the BLANK snapshot to reset DB + documents
printf 'y\n' | /workspaces/dolibarr/docker-deploy/restore_dolibarr.sh \
  /workspaces/dolibarr/docker-deploy/backups/dolibarr_backup_20251031_120719_BLANK

# Remove conf.php so Dolibarr exposes /install/
rm -f /workspaces/dolibarr/htdocs/conf/conf.php

# Ensure no install.lock remains
docker compose exec app sh -lc 'rm -f /var/www/html/documents/install.lock || true'

# Open the installer
"$BROWSER" http://localhost:8080/install/
```

Security note: After installation completes, keep `install.lock` in the documents directory and ensure `htdocs/conf/conf.php` is read-only (440).
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