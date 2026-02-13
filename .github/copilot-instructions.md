# Dolibarr ERP/CRM - AI Coding Agent Instructions

## Project Overview

Dolibarr is a PHP-based open-source ERP & CRM system for managing businesses (invoices, products, inventory, HR, projects, etc.). The codebase is GPL-3.0+ licensed and prioritizes compatibility with PHP 7.1+ and broad deployment environments.

**Key Facts:**
- **Language:** PHP (htdocs/), JavaScript for UI enhancements
- **Database:** MariaDB/MySQL or PostgreSQL (via DOL_DOCUMENT_ROOT abstraction)
- **Architecture:** Module-based monolithic application with file-per-feature structure
- **Entry Point:** [htdocs/main.inc.php](htdocs/main.inc.php) bootstraps all GUI pages; [htdocs/filefunc.inc.php](htdocs/filefunc.inc.php) loads conf.php and core libraries

## Critical Architecture Patterns

### 1. Module System
Modules extend `DolibarrModules` and live in [htdocs/core/modules/](htdocs/core/modules/). Each module descriptor (e.g., `modApi.class.php`) declares:
- Rights, menus, database tables/constants
- Activation via `activateModule()` / `unActivateModule()` in [htdocs/core/lib/admin.lib.php](htdocs/core/lib/admin.lib.php)
- Module parts: triggers, substitutions, hooks, custom CSS/JS ([htdocs/core/modules/DolibarrModules.class.php](htdocs/core/modules/DolibarrModules.class.php) lines 160-180)

**Module Builder:** [htdocs/modulebuilder/](htdocs/modulebuilder/) generates skeleton modules. Always use for new features unless modifying core.

### 2. CommonObject Pattern
Business objects inherit [CommonObject](htdocs/core/class/commonobject.class.php) (~11K lines):
- **Standard methods:** `fetch()`, `create()`, `update()`, `delete()`, `fetchAll()`
- **Properties:** `$element`, `$table_element`, `$fk_element`, `$id`
- **Line objects:** Extend `CommonObjectLine` for multi-line documents (invoices, orders)
- **Example:** [htdocs/projet/class/project.class.php](htdocs/projet/class/project.class.php), [htdocs/societe/class/societe.class.php](htdocs/societe/class/societe.class.php)

### 3. File Organization
```
htdocs/
├── main.inc.php              # Bootstrap: session, DB, permissions, globals
├── filefunc.inc.php          # Loads conf.php, defines constants
├── conf/conf.php             # Database credentials (NEVER commit)
├── core/
│   ├── class/                # CommonObject, Form builders, DB abstraction
│   ├── lib/                  # Reusable functions (*.lib.php)
│   ├── modules/              # Module descriptors (modXxx.class.php)
│   ├── triggers/             # Event system for cross-module logic
│   └── tpl/                  # Reusable HTML templates
├── <module>/
│   ├── class/                # Business logic classes
│   ├── core/triggers/        # Module-specific triggers
│   ├── admin/                # Module configuration pages
│   └── lib/<module>.lib.php  # Module-specific functions
└── install/                  # Database migration scripts
```

### 4. Essential Functions & Constants
- **Input:** `GETPOST('var', 'alpha')`, `GETPOSTINT('id')` - sanitized $_GET/$_POST access
- **Config:** `getDolGlobalString('CONST_NAME')`, `getDolGlobalInt('CONST_NAME')` - read config constants
- **Includes:** `dol_include_once('/path/to/file.php')` or `require_once DOL_DOCUMENT_ROOT.'/path/to/file.php'`
- **Constants:** `DOL_DOCUMENT_ROOT`, `DOL_DATA_ROOT`, `DOL_URL_ROOT` (set in [filefunc.inc.php](htdocs/filefunc.inc.php))
- **Database:** Always use `$db` object methods: `$db->query()`, `$db->fetch_object()`, `$db->escape()`

### 5. Database Patterns
- **Queries:** Use `$db->prefix` for table names: `llx_societe` becomes `{$db->prefix}societe`
- **Transactions:** Wrap writes in `$db->begin()` / `$db->commit()` / `$db->rollback()`
- **Example:**
  ```php
  $sql = "SELECT rowid FROM ".$db->prefix()."tablename WHERE fk_field = ".((int) $id);
  $resql = $db->query($sql);
  ```

## Development Workflows

### Starting Development
1. **Docker Environment (Codespaces):**
   ```bash
   cd docker-deploy && ./daily_start.sh
   # Starts PHP 8.2 FPM, MariaDB 10.11, Nginx; opens http://localhost:8080
   ```
   - Container setup: [docker-deploy/docker-compose.yml](docker-deploy/docker-compose.yml)
   - Backup/restore: [docker-deploy/setup/05-backup-system.md](docker-deploy/setup/05-backup-system.md)
   - Database access: `localhost:3306`, user: `dolibarr`, password: `dolibarrpass`

2. **Enabling Developer Mode:**
   - Admin > Setup > Other: Set `MAIN_FEATURES_LEVEL=2` (development modules) or `=1` (experimental)
   - Enable Module Builder module for scaffolding
   - Configuration stored in `llx_const` table and cached in memory

3. **Creating a Module:**
   - Home > Tools > Module Builder > Create New Module
   - Generates structure in [htdocs/custom/<modulename>/](htdocs/custom/)
   - Provides: class files, triggers, permissions, menu entries, database tables
   - 100+ built-in modules follow `mod<ModuleName>` naming convention in [htdocs/core/modules/](htdocs/core/modules/)

### Testing
- **PHPUnit Unit Tests:** `cd test/phpunit && phpunit` - test core functions in [test/phpunit/](test/phpunit/)
- **Functional Tests:** [test/phpunit/functional/](test/phpunit/functional/) - Selenium-based browser tests (requires Firefox)
- **Manual Testing:** Use `/install/` wizard for fresh database setup; access at http://localhost:8080/install/
- **Reset Environment:** `docker-deploy/recreate_dolibarr.sh` for clean state

### Code Quality Tools
- **Pre-commit hooks:** [dev/setup/pre-commit/](dev/setup/pre-commit/) - auto-formats PHP/JS before commits
- **PHPStan:** [phpstan.neon.dist](phpstan.neon.dist) + [dev/tools/](dev/tools/) - static analysis (`phpstan analyze`)
- **Documentation:** Doxygen-style comments required; auto-generated at [doxygen.dolibarr.org](https://doxygen.dolibarr.org/)

## Conventions & Constraints

### UI-First Development Rule
**STRICT:** Always attempt solutions via Dolibarr's UI/modules before writing code. Only code when:
- Feature confirmed unavailable in UI
- Module limitation documented
- Custom integration/API explicitly requested

### Coding Standards
- **PHP 7.1+ compatible** - avoid modern PHP syntax unsupported in 7.1
- **No PSR-4 autoloading** - use explicit `require_once` or `dol_include_once()`
- **Indentation:** Tabs (not spaces)
- **Naming:** `functionName()`, `$variableName`, `ClassName`, `CONSTANT_NAME`
- **Security:** Always sanitize with `GETPOST()` family; never raw `$_GET`/`$_POST`
- **Error handling:** Set `$this->error` and `$this->errors[]`, return 0 or negative values
- **Extensions:** Do not suggest installing frivolous extensions (e.g., Rainbow CSV) unless explicitly requested

### File Placement
- **Core changes:** Rarely needed; prefer [htdocs/custom/](htdocs/custom/) for customizations
- **Third-party libs:** [htdocs/includes/](htdocs/includes/) via composer (see [composer.json.disabled](composer.json.disabled))
- **Documentation:** [other-docs/](other-docs/) for compliance/guides (project-specific non-code docs)

### Database Migrations
Add SQL to module descriptor's `_init()` method or [install/mysql/migration/](install/mysql/migration/) for core changes.

## Common Tasks

### Adding a New Field to an Object
1. **Database:** Add column via migration script
2. **Class:** Add property in CommonObject subclass
3. **ExtraFields (preferred):** Admin > Setup > Dictionaries > Extra Fields - configure via UI

### Creating a New Page
```php
<?php
require '../main.inc.php';
require_once DOL_DOCUMENT_ROOT.'/core/lib/admin.lib.php';

$action = GETPOST('action', 'aZ09');
$id = GETPOSTINT('id');

// Permissions check
if (!$user->hasRight('mymodule', 'read')) {
    accessforbidden();
}

// Actions
if ($action == 'dosomething') {
    // Handle POST logic
}

// View
llxHeader('', $langs->trans('PageTitle'), '', '', 0, 0, [], []);
print '<div class="fichecenter">';
// ... HTML ...
print '</div>';
llxFooter();
```

### Triggering Events
Triggers fire on object lifecycle events (create, modify, delete). Place in [htdocs/custom/<module>/core/triggers/](htdocs/custom/):
```php
public function runTrigger($action, $object, User $user, Translate $langs, Conf $conf) {
    if ($action == 'PRODUCT_CREATE') {
        // Custom logic after product creation
    }
    return 0;
}
```

### Working with CommonObject Subclasses
Key patterns when extending `CommonObject`:
```php
class MyObject extends CommonObject {
    public $element = 'myobject';               // Element type
    public $table_element = 'myobject';         // Base DB table
    public $fk_element = 'fk_myobject';         // FK column name
    public $lines = [];                         // For multi-line objects
    
    public function create($user = null, $notrigger = false) {
        $sql = "INSERT INTO ".$this->db->prefix().$this->table_element;
        // Standard pattern: begin/commit/trigger
        $this->db->begin();
        $resql = $this->db->query($sql);
        if ($resql) {
            $this->id = $this->db->last_insert_id('llx_myobject');
            $this->db->commit();
            if (!$notrigger) dolibarr_set_const($this->db, 'ACTION_'.strtoupper($this->element).'_CREATE', 1);
        }
    }
}

## Integration Points

- **REST API:** [htdocs/api/](htdocs/api/) - Swagger docs at `/api/index.php/explorer`
- **WebServices (SOAP):** [htdocs/webservices/](htdocs/webservices/) - legacy SOAP interface
- **Hooks:** Module parts define hookContexts; use `executeHooks()` in code
- **Exports/Imports:** [htdocs/exports/](htdocs/exports/), [htdocs/imports/](htdocs/imports/) - CSV/Excel data exchange

## Known Gotchas

1. **Module activation requires reload:** After enabling a module, users must reload or logout/login for rights/menus to appear
2. **Permissions cascade:** Always check `$user->hasRight('module', 'action')` before showing/executing features
3. **Multicompany filtering:** If enabled (via `MAIN_FEATURES_LEVEL`), always filter queries by `$conf->entity`
4. **Config constants cache:** Changes via `dolibarr_set_const()` may need `$conf->setValues($db)` to reload in memory
5. **File paths:** Use `DOL_DATA_ROOT` for user documents/uploads, `DOL_DOCUMENT_ROOT` for code files
6. **Language/translation:** Use `$langs->trans('KeyName')` for all UI text; keys defined in [htdocs/langs/](htdocs/langs/)
7. **Line item operations:** Multi-line objects (invoices, orders) use separate line classes extending `CommonObjectLine`
8. **Trigger execution:** Triggers run asynchronously; check return codes, never assume synchronous state changes
9. **Environment vars:** Dolibarr reads from `conf.php` only once on startup; new constants need config reload
10. **REST API versioning:** API routes in [htdocs/api/class/](htdocs/api/class/) follow `/api/index.php/<version>/<resource>` pattern

## Useful Links

- **Wiki:** https://wiki.dolibarr.org/ (module development, user guides)
- **Doxygen:** https://doxygen.dolibarr.org/ (API reference)
- **GitHub:** https://github.com/Dolibarr/dolibarr (issues, PRs)

---

**When in doubt:** Search [htdocs/core/lib/](htdocs/core/lib/) for reusable functions before reinventing. The codebase prioritizes backward compatibility and broad PHP version support over modern patterns.
