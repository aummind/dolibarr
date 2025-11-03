# Deployment Guide

Primary target: CloudClusters.io. Alternatives: DigitalOcean, AWS ECS, traditional VPS. This guide is additive and does not modify Dolibarr core.

## Environments
- Dev: Codespaces Docker
- Staging/Prod: CloudClusters.io (managed DB + Docker runtime)

## Environment variables
See `project/ENV.sample` and provide per-environment `.env` (not committed):
- APP_BASE_URL, DOLI_DB_HOST, DOLI_DB_NAME, DOLI_DB_USER, DOLI_DB_PASS
- DOLI_ADMIN_USER, DOLI_ADMIN_PASS
- SMTP_* (host/user/pass/from)
- REGION/COUNTRY (IN), GST_ENABLED=1, KARNATAKA_RULES=1

## Docker Compose (local example)
This repository ships `docker-deploy/docker-compose.yml`. Adapt variables via `.env`.

High-level services:
- db: MariaDB with persistent volume
- php: PHP-FPM serving Dolibarr code
- nginx: reverse proxy (see `docker-deploy/nginx.conf` and `docker-deploy/security/nginx.hardening.conf`)
 - redis (optional): enabled in compose for internal use; no external port published

## CloudClusters.io
- Provision a PHP + DB stack.
- Upload code from this repo; mount persistent storage for `documents/`.
- Set environment variables per `ENV.sample`.
- Import initial (empty) database schema via Dolibarr installer.

## Alternatives
- DigitalOcean Droplets: Use docker-compose; secure with UFW and Fail2Ban.
- AWS ECS/Fargate: Build PHP-FPM and Nginx images; use RDS for DB; S3 for documents (via s3fs or application-level sync). Non-official design pattern.
- Traditional VPS: Install Nginx + PHP-FPM + MariaDB; follow `SECURITY_HARDENING.md`.

## Backups
- Database: nightly `mysqldump` with retention.
- Documents: rsync or object storage snapshot.
- Use `scripts/project/backup_coos.sh` to assemble compliance backup in `coos_backup/`.

## Observability
- Enable Nginx access/error logs; rotate daily.
- Optionally add reverse proxy metrics (non-official reference).

## Redis usage (optional)
- Redis service is included and PHP Redis extension is installed.
- By default, PHP sessions remain file-based. To switch sessions to Redis:
	- scripts/project/redis_toggle.sh enable
	- To revert: scripts/project/redis_toggle.sh disable
- Security note: Redis is only available on the internal compose network. For external deployments, bind to private networks and require authentication.

## Daily operations scripts
Located in `docker-deploy/` (scripts are repository-provided helpers):
- daily_start.sh: Bring up or refresh the stack for daily work (builds/starts compose as defined).
- daily_pause.sh / daily_unpause.sh: Pause/unpause containers to preserve state without full stop.
- daily_exit.sh: Graceful stop/cleanup for end-of-day.

Notes:
- These scripts are convenience wrappers around `docker compose` flows. Review their content before adapting to production. Non-official operational guidance.
