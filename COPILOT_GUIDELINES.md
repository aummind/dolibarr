# Workspace Copilot Guidelines

Purpose: Standing instructions for this workspace. At the start of each session, load these guidelines and treat the files listed under "Session Context Sources" as persistent context for the duration of the session.

Docs Index: `other-docs/README.md`

## Session Context Sources and Guidelines

 Create instruction/reference files, but confirm placement hierarchy when unsure.
 `session-context.md`: Authoritative current status and next steps.
 `/workspaces/dolibarr/README.md` (Dolibarr 23.0.0-alpha): Prefer official sources.
 Configure for manufacturing in India with Karnataka state considerations.


- Docker configuration reference: `/workspaces/dolibarr/docker-deploy/setup/README.md`.
 Assist in compliance with ISO 14001:2015 (EMS) and ISO 14067:2018 (Product Carbon Footprint).
 References for standards (ISO 14001/14067, others): store metadata and official links; request user-provided copies if needed.
 - Compliance and references live under `other-docs/` (see `other-docs/compliance/README.md`).

### File Placement Defaults (when not specified)
 - Compliance, guides, references, chat/session references: `other-docs/`.
 - Operational runbooks and setup notes: `docker-deploy/setup/`.
 - Chat prompt libraries: keep `chat-templates.md` at repo root unless it grows (then `other-docs/chat/`).
 - Workspace rules: `COPILOT_GUIDELINES.md` (this file, repository root).
 - Ask before adding new top-level folders.

 Load: `COPILOT_GUIDELINES.md`, `session-context.md`, `/workspaces/dolibarr/README.md`, `other-docs/compliance/README.md`, and `docker-deploy/setup/README.md`.

- When changes are needed in this repo, propose them and use apply_patch.

 "Load workspace guidelines from `COPILOT_GUIDELINES.md`. For this session, use `session-context.md`, `/workspaces/dolibarr/README.md`, `chat-templates.md`, `other-docs/compliance/README.md`, and `docker-deploy/setup/*.md` as standing context. Confirm loaded, summarize key constraints (India manufacturing, Karnataka, ISO 14001:2015 and ISO 14067:2018), and list any missing items for me to fill."
- Pin `session-context.md` in chat.
- Summarize key constraints (India manufacturing, Karnataka, ISO compliance) and list any missing details to fill.


## Abbreviations & Shortforms
Add and update as we work together. Use these consistently in responses.
- GST: Indian Goods and Services Tax
- COA: Certificate of Analysis
- SDS: Safety Data Sheet
- GHS: Globally Harmonized System (hazard classification)
- EHS: Environment, Health, and Safety
- TDS: Technical Data Sheet
- IUPAC: International Union of Pure and Applied Chemistry nomenclature.
- [Add user-specific abbreviations here]

## Dolibarr & Project Context
- Domain: manufacturing ERP, CRM on Dolibarr (installation → configuration → implementation).
- Prioritize: Compliance (Indian GST, ISO 14001), safety, batch tracking.
- When uncertain: Offer safe defaults and ask minimum clarifying questions.
- Use the docker-deploy scripts for lifecycle (start/exit/backup/restore).
- **Session start protocol**: Wait for user to run `./daily_start.sh` before referencing web installer or accessing Dolibarr UI.
- Treat session-context.md as the single source of truth for current phase.

## Implementation Rules
- **STRICT: Work through Dolibarr modules and UI first.** All configuration, setup, and customization must be attempted via the Dolibarr interface before considering code changes. Only propose direct coding when:
  - The feature is confirmed unavailable in Dolibarr's UI/modules
  - A module limitation is documented and requires extension
  - Custom integration or API work is explicitly requested
  - When proposing code, always explain why the UI approach won't work
- Keep changes minimal and focused; no unrelated refactors.
- Prefer root-cause fixes over surface-level patches.
- Respect existing structure and naming; don't add licenses/headers.
- Avoid one-letter variables unless explicitly requested.
- When adding files, place them where discoverable and documented.

## Compliance & Downloads Policy
- Karnataka and Indian GST requirements: treat as priority lenses for guidance; this is not legal advice.
- ISO standards are copyrighted; do not store full texts. Store metadata and links to official sources. If local copies are needed, request user-provided files.
- When a referenced document is missing, prompt the user to supply or confirm the authoritative source.

## Chat Usage Protocol
- On session start: Load the sources in "Session Context Sources" and acknowledge.
- If memory resets: Use the Emergency Context in chat-templates.md.
- Pin session-context.md in the chat whenever possible.
- Summarize what you’ve loaded and list any missing fields to fill in.

## Safety & Compliance
- Do not produce harmful or unsafe instructions.
- Highlight safety and compliance implications in guidance.

## Quick Loader Prompt (for Chat)
Paste or trigger this at session start:

"Load workspace guidelines from `COPILOT_GUIDELINES.md`. For this session, use `session-context.md`, `/workspaces/dolibarr/README.md`, `chat-templates.md`, and `docker-deploy/setup/*.md` as standing context. Confirm loaded, summarize key constraints (India manufacturing, Karnataka, ISO 14001/14076), and list any missing items for me to fill."
