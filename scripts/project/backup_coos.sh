#!/usr/bin/env bash
set -euo pipefail

# Assemble compliance-oriented backup directory (coos_backup)
ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
OUT_DIR="$ROOT_DIR/coos_backup"
mkdir -p "$OUT_DIR"

echo "[backup] Creating compliance/OSS backup at $OUT_DIR"

# Manifest with timestamps and commit
COMMIT_SHA=$(git -C "$ROOT_DIR" rev-parse --short HEAD 2>/dev/null || echo "unknown")
DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)
cat > "$OUT_DIR/MANIFEST.md" <<EOF
# coos_backup Manifest

- Generated: $DATE UTC
- Commit: $COMMIT_SHA
- Source repo: $(git -C "$ROOT_DIR" config --get remote.origin.url 2>/dev/null || echo "unknown")

Included references (not copies unless noted):
- COPYING (GNU GPL), COPYRIGHT, ChangeLog
- SECURITY_HARDENING.md (non-official sections labeled)

To refresh this backup, re-run scripts/project/backup_coos.sh.
EOF

# Trace document
cat > "$OUT_DIR/TRACE.md" <<'EOF'
# Compliance & Open-Source Trace

This project is based on Dolibarr ERP/CRM (open-source). We maintain the following trace:

- Upstream license: See COPYING and COPYRIGHT in repository root (authoritative).
- Modifications: Project-layer documentation, security hardening snippets, and helper scripts under `project/` and `scripts/`.
- Non-official references are labeled within documents.
- No proprietary data is included in this backup.

Distribution intent: This directory can be published to document license compliance and high-level changes.
EOF

# Copy small license files for convenience (leave canonical files at root)
cp -f "$ROOT_DIR/COPYING" "$OUT_DIR/COPYING" 2>/dev/null || true
cp -f "$ROOT_DIR/COPYRIGHT" "$OUT_DIR/COPYRIGHT" 2>/dev/null || true
cp -f "$ROOT_DIR/ChangeLog" "$OUT_DIR/ChangeLog" 2>/dev/null || true

echo "[backup] Backup assembled. Files:"
ls -1 "$OUT_DIR"
