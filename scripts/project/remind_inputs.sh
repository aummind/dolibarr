#!/usr/bin/env bash
set -euo pipefail

echo "Pending inputs required:" 
cat <<'EOF'
1) Product classifications & sub-classes
   - Provide in project/config/classifications/ as YAML or CSV.
2) Permissions matrix
   - Fill project/config/permissions/USER_ROLES.template.yaml
3) GST e-invoicing specifics
   - Confirm schema version, provider (NIC/GSP), endpoints, and QR template details.
4) Carbon factor sources
   - Additional sources beyond SFC India v1.2 (see project/config/compliance/carbon_factors.md)
EOF
