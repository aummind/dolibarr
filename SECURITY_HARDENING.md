# Security Hardening Guide

This guide provides pragmatic hardening steps for running Dolibarr in Codespaces and in production (CloudClusters.io or your own Docker hosts). These steps are additive and non-breaking. Apply in CI/CD or as part of infrastructure automation.

Note: Dolibarr core security docs are authoritative. This file complements them. When we cite external guidance (non-official), it is explicitly marked as such.

## Overview
- Environment isolation: use per-environment .env files and secrets, never commit live credentials.
- Network exposure: terminate TLS at a hardened reverse proxy and restrict admin endpoints by IP where possible.
- Runtime posture: run PHP-FPM and web server as non-root; read-only filesystem for app except explicit writable dirs.
- Data hygiene: restrict permissions on `documents/`, `custom/`, and upload directories; enable antivirus/clamav scanning on uploads (optional).
- Audits: run the provided scripts under `scripts/security/` regularly.

## Minimum file/dir permissions
- Application code: 0644 files, 0755 directories.
- Writable directories (example): `documents/`, `htdocs/custom/`, `htdocs/conf/` (if used for dynamic conf) → 0750, owned by web user group.
- Disallow PHP execution in upload dirs using web server rules.

## PHP recommendations (non-official reference)
- disable_functions: exec, shell_exec, system, passthru, popen, proc_open, eval, curl_multi_exec (evaluate impact)
- expose_php = Off
- display_errors = Off (On in dev only)
- log_errors = On
- session.cookie_httponly = 1
- session.cookie_secure = 1 (when behind TLS)
- session.use_strict_mode = 1

## Nginx reverse proxy hardening
A sample hardened snippet is provided at `docker-deploy/security/nginx.hardening.conf`. Key items:
- Force TLS 1.2+ with strong ciphers
- HSTS (opt-in after verifying)
- Security headers: X-Frame-Options, X-Content-Type-Options, Referrer-Policy, Permissions-Policy
- Deny execution in upload/static dirs

## Dolibarr specific
- Limit API keys and rotate periodically. Disable deprecated REST routes if unused.
- Configure WAF (`htdocs/waf.inc.php`) and enable brute-force protection.
- Restrict module activation to required set; remove unused external modules from `htdocs/custom/`.

## Secrets management
- Use `.env.local` or environment variables in deployment; never commit real secrets.
- Provide `project/ENV.sample` for structure.

## Audits and checks
- Run `scripts/security/audit.sh` to scan permissions, world-writable files, and basic exposure.
- Run `scripts/security/secret-scan.sh` for simple pattern-based secret detection (non-official).

## Backups
- Use `scripts/backup_coos.sh` to assemble a compliance-oriented backup in `coos_backup/`.

## Incident response (non-official reference)
- Enable access logs with request IDs.
- Keep 30–90 days of logs with logrotate.
- Document escalation contacts and steps.

---

Maintainer notes: keep this guide minimal, actionable, and environment-agnostic. When diverging from Dolibarr official guidance, mark sections as non-official.