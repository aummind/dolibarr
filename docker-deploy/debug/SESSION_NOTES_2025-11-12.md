# Session Notes — 2025-11-12

These notes capture the current working state and how to resume. You restored backup `docker-deploy/backups/dolibarr_backup_20251103_164637`.

## What Changed
- Fixed a 500 on `/admin/company.php` caused by an empty custom module file `htdocs/custom/ops/core/modules/modOps.class.php` by removing it (class autoload tried to `new modOps`).
- You then restored from backup `20251103_164637` (earlier working snapshot). The restore script handles `conf.php`, DB, and documents.

## Current State
- Containers: `web`, `app`, `db`, `redis` up via Compose (nginx, PHP-FPM 8.2, MariaDB 10.11, optional Redis).
- `conf.php`: Restored from backup; URL root, DB creds, and paths reflect that snapshot.
- Documents: Restored; permissions normalized for Codespaces.
- Database: Restored from the backup SQL inside `backups/dolibarr_backup_20251103_164637/database`.

## Resume Steps
1) Start/verify stack
```bash
cd /workspaces/dolibarr/docker-deploy
docker compose up -d
docker compose ps
```

2) Open the app and verify no 500
- Go to `/admin/index.php` then `/admin/company.php?mainmenu=home&action=edit` and submit.

## Quick Checks
- PHP extensions
```bash
docker compose exec app php -m | grep -E '^(gd|intl|mysqli)$' || true
```
- App logs (Dolibarr)
```bash
docker compose exec app sh -lc 'tail -n 200 /var/www/html/documents/dolibarr.log || true'
```
- Nginx/PHP-FPM logs
```bash
docker compose logs --tail=200 web
docker compose logs --tail=200 app
```

## If 500 Appears Again on Company Page
1) Check for stray/broken custom module files from backup:
```bash
test -s /workspaces/dolibarr/htdocs/custom/ops/core/modules/modOps.class.php || rm -f /workspaces/dolibarr/htdocs/custom/ops/core/modules/modOps.class.php
```

2) Temporarily show errors (optional, for diagnostics): set `$dolibarr_main_prod='0'` in `htdocs/conf/conf.php`, reproduce the error, then set back to `'1'`.

## Installer/Schema Notes
- Incoterms data includes `DTP(DHL)`; if you ever re-run the installer on a fresh DB, ensure `llx_c_incoterms.code` allows up to 8 chars. To check:
```bash
docker compose exec db mysql -u dolibarr -pdolibarrpass -e "\
SELECT COLUMN_NAME, COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS \
WHERE TABLE_SCHEMA='dolibarr' AND TABLE_NAME='llx_c_incoterms' AND COLUMN_NAME='code';"
```
If needed (fresh install only):
```bash
docker compose exec db mysql -u dolibarr -pdolibarrpass dolibarr \
  -e "ALTER TABLE llx_c_incoterms MODIFY code VARCHAR(8);"
```

## Backup/Restore Commands
- Latest backups are under `docker-deploy/backups/`. To restore a specific one:
```bash
cd /workspaces/dolibarr/docker-deploy
chmod +x restore_dolibarr.sh
./restore_dolibarr.sh \
  "/workspaces/dolibarr/docker-deploy/backups/dolibarr_backup_20251103_164637"
```

## What to Upload Back
- This file: `docker-deploy/debug/SESSION_NOTES_2025-11-12.md`.
- Any new logs showing failures: `docker compose logs --tail=200 web`, `app`, and the last 200 lines of `documents/dolibarr.log`.
- If present, the content or existence of `htdocs/custom/ops/core/modules/modOps.class.php` after restore.

## Post-Restore Warning (modOps descriptor)
If you see in Admin > Modules: `Warning bad descriptor file : /var/www/html/custom/ops/core/modules/modOps.class.php (Class modOps not found into file)`, it means the backup restored an empty descriptor.

Fix options (choose one):

- Option A — Remove placeholder file (recommended if you don’t use this module)
```bash
rm -f /workspaces/dolibarr/htdocs/custom/ops/core/modules/modOps.class.php
# Then reload the Modules page
```

- Option B — Replace with a minimal valid stub (keeps the module folder without activating anything)
Create `htdocs/custom/ops/core/modules/modOps.class.php` with:
```php
<?php
// Minimal placeholder to silence descriptor warning
require_once DOL_DOCUMENT_ROOT.'/core/modules/DolibarrModules.class.php';

class modOps extends DolibarrModules
{
  public $numero = 999999;           // Temporary unique ID for custom module
  public $rights_class = 'ops';
  public $family = 'other';
  public $name = array('en_US' => 'Ops');
  public $description = 'Operations placeholder module (inactive)';
  public $version = 'development';
  public $automatic_activation = array(); // Keep empty to avoid auto-activation by country

  public function __construct($db)
  {
    $this->db = $db;
    $this->editor_name = 'Local';
    $this->editor_url = '';
    $this->picto = 'generic';
    $this->module_parts = array();
    $this->dirs = array();
    $this->depends = array();
    $this->requiredby = array();
    $this->langfiles = array('admin');
    $this->phpmin = array(7,4);
    $this->need_dolibarr_version = array('23.0');
    $this->const = array();
    $this->tabs = array();
    $this->rights = array();
    $this->menu = array();
  }
}
```
Reload the Modules page; the warning should be gone. This stub does nothing unless you later implement it.
