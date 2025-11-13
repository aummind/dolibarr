#!/usr/bin/env bash
set -euo pipefail
echo "[compat] This script moved to docker-deploy/project/lint.sh"
exec bash "$(cd "$(dirname "$0")/../../docker-deploy/project" && pwd)/lint.sh" "$@"
