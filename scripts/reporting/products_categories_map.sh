#!/usr/bin/env bash

set -euo pipefail

COMPOSE_FILE="/workspaces/dolibarr/docker-deploy/docker-compose.yml"
OUT_DIR="/workspaces/dolibarr/docker-deploy/reports"
mkdir -p "$OUT_DIR"

echo "[products_categories_map] Generating products → categories/tags map (with hierarchy)..."

# Detect if product extrafield 'iupac_name' exists
HAS_IUPAC=$(docker compose -f "$COMPOSE_FILE" exec -T db sh -lc "mysql -N -u dolibarr -pdolibarrpass dolibarr -e \"SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='llx_product_extrafields' AND column_name='iupac_name'\"" || echo 0)

if [ "${HAS_IUPAC}" = "1" ]; then
  IUPAC_SELECT="pe.iupac_name AS iupac_name,"
  IUPAC_JOIN="LEFT JOIN llx_product_extrafields pe ON pe.fk_object = p.rowid"
else
  IUPAC_SELECT="p.label AS iupac_name,"
  IUPAC_JOIN=""
fi

CMD="SET SESSION group_concat_max_len=32768; \\
WITH RECURSIVE cat_tree AS ( \\
  SELECT c.rowid, c.fk_parent, c.label, CAST(c.label AS CHAR(1024)) AS path \\
  FROM llx_categorie c \\
  WHERE c.fk_parent IS NULL OR c.fk_parent = 0 \\
  UNION ALL \\
  SELECT c.rowid, c.fk_parent, c.label, CONCAT(ct.path, ' > ', c.label) \\
  FROM llx_categorie c \\
  JOIN cat_tree ct ON c.fk_parent = ct.rowid \\
) \\
SELECT \\
  p.ref AS ref, \\
  ${IUPAC_SELECT} \\
  p.label AS label, \\
  IFNULL(GROUP_CONCAT(DISTINCT c.label ORDER BY c.label SEPARATOR ', '), '') AS categories, \\
  IFNULL(GROUP_CONCAT(DISTINCT ct.path ORDER BY ct.path SEPARATOR ', '), '') AS category_paths, \\
  IFNULL(GROUP_CONCAT(DISTINCT CONCAT(s.nom, ': ', IFNULL(pfp.ref_fourn, '')) ORDER BY s.nom SEPARATOR ' | '), '') AS trade_names \\
FROM llx_product p \\
${IUPAC_JOIN} \\
LEFT JOIN llx_categorie_product cp ON cp.fk_product = p.rowid \\
LEFT JOIN llx_categorie c ON c.rowid = cp.fk_categorie \\
LEFT JOIN cat_tree ct ON ct.rowid = c.rowid \\
LEFT JOIN llx_product_fournisseur_price pfp ON pfp.fk_product = p.rowid \\
LEFT JOIN llx_societe s ON s.rowid = pfp.fk_soc \\
GROUP BY p.rowid, p.ref, p.label, iupac_name \\
ORDER BY p.ref;"

# Human-readable table
docker compose -f "$COMPOSE_FILE" exec -T db sh -lc "mysql -u dolibarr -pdolibarrpass dolibarr -e \"$CMD\"" | tee "$OUT_DIR/products_categories_map.txt"

# CSV export
docker compose -f "$COMPOSE_FILE" exec -T db sh -lc "mysql -B -u dolibarr -pdolibarrpass dolibarr -e \"$CMD\"" \
  | sed 's/\t/,/g' > "$OUT_DIR/products_categories_map.csv"

echo "[products_categories_map] Written:"
echo "- $OUT_DIR/products_categories_map.txt"
echo "- $OUT_DIR/products_categories_map.csv"
