# Developer Setup

This guide helps developers work on this project layer around Dolibarr. It does not modify Dolibarr core by default.

## Prerequisites
- GitHub Codespaces or local Docker
- No production secrets in the repo. Use `.env` (see `project/ENV.sample`).

## Steps (Codespaces)
1. Create `.env` from `project/ENV.sample` (dev-safe values)
2. Start Docker services using the provided compose files under `docker-deploy/`.
3. Access Dolibarr via the forwarded port (see Codespaces Ports tab).

## Steps (Local Docker)
- Refer to `project/DEPLOYMENT.md` for compose usage and env variables.

## Linting & Checks
- Security audit: `scripts/security/audit.sh`
- Secret scan: `scripts/security/secret-scan.sh`
- Project helpers: `scripts/project/*`

## Documentation
- Project spec: `project/PROJECT_SPEC.md`
- Security: `SECURITY_HARDENING.md`
- Official Dolibarr docs (official): see `project/docs/dolibarr-links.md`.

> Non-official references will be labeled accordingly inside documents.
