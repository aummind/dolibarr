#!/usr/bin/env bash
set -euo pipefail
echo "[compat] This script moved to docker-deploy/project/redis_toggle.sh"
exec bash "$(cd "$(dirname "$0")/../../docker-deploy/project" && pwd)/redis_toggle.sh" "$@"
