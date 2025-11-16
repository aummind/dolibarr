# Session Context

Status: Initialized 2025-11-16

## Phase
- Initial setup and compliance-focused configuration for Dolibarr ERP/CRM.

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
- Access: "$BROWSER" http://localhost:8080 after `./daily_start.sh`.
- Backups: Use `mark_blank_backup.sh` after first clean install; `daily_exit.sh` for daily backups.

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
- …

## Risks & Assumptions
- …

## Contacts / Owners
- Project owner:
- Compliance owner (ISO/GST/EHS):
- IT/DevOps owner:
