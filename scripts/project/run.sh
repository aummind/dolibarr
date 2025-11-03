#!/usr/bin/env bash
set -euo pipefail

# Helper to run the local docker setup
ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT_DIR/docker-deploy"

echo "[run] Starting Dolibarr stack via docker-compose..."
docker compose up -d
echo "[run] Done. Use 'docker compose ps' to see status."
