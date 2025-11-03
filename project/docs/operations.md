# Operations Guide (Daily)

This guide summarizes the repository-provided daily helper scripts. These are convenience wrappers around `docker compose` flows for local/Codespaces use. Non-official operational guidance—review before adapting to production.

## Daily scripts (docker-deploy/)
- daily_start.sh: Bring up or refresh the stack for the day (build/compose up as defined by repo).
- daily_pause.sh: Pause containers to free CPU while preserving memory state.
- daily_unpause.sh: Resume paused containers.
- daily_exit.sh: Graceful stop/cleanup at the end of day.

## Related helpers
- scripts/project/run.sh: Minimal `docker compose up -d` helper.
- scripts/project/redis_toggle.sh: Enable/disable Redis-backed PHP sessions by writing/removing `htdocs/.user.ini`.
- scripts/security/audit.sh: Non-destructive workspace security checks.
- scripts/project/backup_coos.sh: Prepare `coos_backup/` for publishing compliance trace.

## Verification
- `docker compose ps` to check status.
- `docker compose logs -f <service>` to tail logs.

## Notes
- In production/staging, prefer CI/CD-defined start/stop flows and infrastructure tooling.
