# Dolibarr Manufacturing Project Workspace

This workspace tailors Dolibarr for chemical manufacturing with Indian GST, Karnataka compliance, and ISO 14001/14076 alignment. It adds documentation, scripts, and structure without altering Dolibarr core.

- Official Dolibarr docs are the source of truth. This project layer adds implementation guidance. Non-official references are marked.
- No data population included. This is scaffolding only.

## How to run (Codespaces)
- Use the included Docker deployment under `docker-deploy/`.
- Open the repository in Codespaces and start the compose services (PHP-FPM, DB, Nginx) using your preferred workflow (see `project/DEPLOYMENT.md`). For convenience, you can run `docker-deploy/daily_start.sh`.

## How to run (Local Docker)
- See `project/DEPLOYMENT.md` for Docker Compose examples and environment variables.

## Where to start
- Project spec: `project/PROJECT_SPEC.md`
- Deployment: `project/DEPLOYMENT.md`
- Security: `SECURITY_HARDENING.md`
- Developer setup: `project/docs/developer-setup.md`
- Official references: `project/docs/dolibarr-links.md` (official docs noted)

## Scripts
- Security audits: `scripts/security/`
- Project helper scripts: `scripts/project/`
 - Daily ops: `docker-deploy/daily_start.sh`, `daily_pause.sh`, `daily_unpause.sh`, `daily_exit.sh`

## Compliance & backups
- See `coos_backup/` and `scripts/project/backup_coos.sh` for traceability and license backup preparation.