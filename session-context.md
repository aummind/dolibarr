# Session Context

Status: Updated 2025-11-16 (Phase: Installation Wizard)

## Quick Access
- Dolibarr (localhost): http://localhost:8080
- Dolibarr (Codespace): https://mysterious-shadow-v67rgqjgp56xfx95p-8080.app.github.dev
- Installer: https://mysterious-shadow-v67rgqjgp56xfx95p-8080.app.github.dev/install/

> **Warning:** The Codespace URL above is dynamically generated and will change when stopped/restarted. Do **not** share externally or commit to public repos if it exposes sensitive data.
- Docker Setup Docs: `docker-deploy/setup/README.md`
- Compliance Index: `other-docs/compliance/README.md`

## Phase
- Installation and base configuration with compliance lenses (India/Karnataka, ISO 14001/14067)

## Objectives
- Stand up Docker-based Dolibarr reliably in this workspace.
- Configure for India manufacturing with Karnataka-specific needs and GST.
- Align processes with ISO 14001:2015 (EMS) and ISO 14067:2018 (PCF) guidance.
- Establish clear next steps and owners.

## Constraints & Lenses
- Geography: India; State: Karnataka.
- Compliance priority: GST, Karnataka EHS norms, ISO 14001:2015 and ISO 14067:2018.
- Prefer Dolibarr UI/module configuration over code changes.
- Use `docker-deploy` lifecycle scripts for start/exit/backup/restore.

## Environment
- Deployment: Docker (`docker-deploy` folder) on Ubuntu 24.04.2 LTS.
- Start: `cd docker-deploy && ./daily_start.sh`
- Exit + backup: `./daily_exit.sh`
- Blank snapshot: `./mark_blank_backup.sh`
- Restore: `./restore_dolibarr.sh`

## Current Status Checklist
- [x] Containers started (`./daily_start.sh` ran successfully)
- [ ] Web installer completed and admin created
- [ ] Blank backup marked post-install
- [ ] Company basics set (name, address, FY, locale)
- [ ] GST tax rates and HSN/SAC mapping configured
- [ ] Manufacturing modules enabled (BOM, Workstations if needed)
- [ ] Batch/Lot/Serial tracking enabled where required
- [ ] EMS skeleton (ISO 14001) documented in `other-docs/`
- [ ] PCF scope (ISO 14067) drafted in `other-docs/`

## Company & ERP Configuration (to fill)
- Legal name:
- Registered address:
- State: Karnataka (state code 29)
- GSTIN / PAN / CIN:
- Financial year start: 01-Apr (confirm)
- Timezone / Locale: Asia/Kolkata / en-IN (confirm)
- Currency: INR
- Banking details:

## Tax & Compliance Setup (to fill)
- GST rates and rules required:
- HSN/SAC codes for products/services:
- Place-of-supply and intra/inter-state logic:
- E-Invoicing (IRP) and E-Waybill needs (Y/N):
- Karnataka specific consents (CTE/CTO) and reporting (Y/N):

## Manufacturing & Traceability (to fill)
- Product families and units of measure:
- BOM, work centers, routings:
- Batch/Lot tracking (Y/N) and serials:
- Quality docs: COA, SDS, TDS storage locations:
- Nonconformance/CAPA handling in Dolibarr (process owner):

## ISO References (metadata only)
- ISO 14001:2015 — Environmental Management Systems (EMS)
	- Official catalog: https://www.iso.org/search.html?q=ISO%2014001%3A2015
	- Local licensed copy path (if provided):
- ISO 14067:2018 — Carbon footprint of products (PCF)
	- Official catalog: https://www.iso.org/search.html?q=ISO%2014067%3A2018
	- Local licensed copy path (if provided):

## PCF Scope (for ISO 14067) — to define
- Goal & scope, functional unit:
- System boundary and life-cycle stages:
- Allocation rules and data sources:
- Reporting format and verification approach:

## Open Decisions
- …

## Next Steps
- Complete web installer; create admin user
- Mark blank backup snapshot
- Enter company master data and FY/locale
- Configure GST tax rates and HSN/SAC codes
- Enable manufacturing modules and set UoM
- Decide batch/lot/serial tracking policies
- Draft EMS and PCF skeleton documents

## Future Tasks
- Change MySQL/MariaDB root and dolibarr database user passwords from default values; update credentials in `docker-compose.yml`, Dolibarr `conf.php`, and any backup/restore scripts that reference database credentials

## Risks & Assumptions
- Codespace URL will change when stopped/restarted; keep localhost as fallback
- GST/e-invoicing integration may need third-party add-ons

## Contacts / Owners
- Project owner:
- Compliance owner (ISO/GST/EHS):
- IT/DevOps owner:
