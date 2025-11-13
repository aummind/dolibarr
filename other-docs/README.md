# Other Docs Index

Purpose: Orientation for non-code documentation related to this workspace. This index explains what lives where and links key entry points.

## Structure
- `guides/`: Procedural runbooks and how‑tos (operations, backups, checklists).
- `references/`: External standards/regulations metadata and official links. Store local PDFs only if user‑provided and licensed.
- `compliance/`: Compliance hub. Start at `compliance/README.md` for ISO 14001:2015, ISO 14067:2018, India GST, and Karnataka references.
- `chat/`: Prompt libraries, reusable snippets for chat sessions.
- `session/`: Optional session artifacts (snapshots/notes) if needed. Primary status remains in repo‑root `session-context.md`.

## Quick Links
- Compliance: `other-docs/compliance/README.md`
- Workspace guidelines: `COPILOT_GUIDELINES.md`
- Chat templates: `chat-templates.md`
- Docker setup docs: `docker-deploy/setup/`

## Conventions
- Prefer official links over storing documents. Do not include copyrighted full texts.
- If a licensed local copy is needed, place it under `other-docs/references/` with a clear name, e.g. `ISO_14001_2015_EMS.pdf` or `ISO_14067_2018_PCF.pdf`.
- Keep a note of license/ownership when adding local files.

## Adding New Docs
- Unsure where to place something? Default to `guides/` and note intent in its header, or ask to confirm placement.
- Avoid creating new top‑level folders without confirmation.
