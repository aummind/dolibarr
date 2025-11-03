#!/usr/bin/env bash
set -euo pipefail

# Run from repository root/docker-deploy
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
cd "${SCRIPT_DIR}/.."

mkdir -p debug_info

# Assume default Dolibarr prefix unless overridden
P="llx_"
echo "DB prefix: $P" | tee debug_info/db_prefix.txt >/dev/null

# Compose status and config
docker compose ps | tee debug_info/compose_ps.txt >/dev/null
docker compose config > debug_info/compose_config.yml

# Recent logs (non-fatal if any container missing)
docker compose logs --tail=200 web > debug_info/logs_web.txt || true
docker compose logs --tail=200 app > debug_info/logs_app.txt || true
docker compose logs --tail=200 db > debug_info/logs_db.txt || true

# Company constants snapshot
docker compose exec -T db mysql -u dolibarr -pdolibarrpass dolibarr -e "
SELECT name, value FROM ${P}const
WHERE name IN ('MAIN_INFO_SOCIETE_NOM','MAIN_INFO_SOCIETE_ADDRESS','MAIN_INFO_SOCIETE_ZIP','MAIN_INFO_SOCIETE_TOWN','MAIN_INFO_SOCIETE_COUNTRY','MAIN_MONNAIE')
ORDER BY name;
" > debug_info/company_constants.txt || true

# Country label for the configured company country
docker compose exec -T db mysql -u dolibarr -pdolibarrpass dolibarr -e "
SELECT co.code AS country_code, co.label AS country_label
FROM ${P}const c
JOIN ${P}c_country co ON co.code = c.value
WHERE c.name='MAIN_INFO_SOCIETE_COUNTRY';
" > debug_info/company_country.txt || true

# Categories presence and sample
docker compose exec -T db mysql -u dolibarr -pdolibarrpass dolibarr -e "
SHOW TABLES LIKE '${P}categorie';
" > debug_info/tables_categorie.txt || true

docker compose exec -T db mysql -u dolibarr -pdolibarrpass dolibarr -e "
SELECT rowid, label, fk_parent, type FROM ${P}categorie ORDER BY type, label LIMIT 50;
" > debug_info/categories_sample.txt || true

# Blank backup metadata if present
BLANKDIR=$(ls -d backups/dolibarr_backup_*_BLANK 2>/dev/null | head -1 || true)
if [[ -n "${BLANKDIR:-}" ]]; then
  ls -la "$BLANKDIR" > debug_info/blank_backup_ls.txt || true
  if [[ -f "$BLANKDIR/backup_info.txt" ]]; then
    cat "$BLANKDIR/backup_info.txt" > debug_info/blank_backup_info.txt
  else
    echo "backup_info.txt not found" > debug_info/blank_backup_info.txt
  fi
fi

echo "Wrote $(ls -1 debug_info | wc -l) files under $(pwd)/debug_info"
