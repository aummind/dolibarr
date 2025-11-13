# Scripts Documentation

Complete documentation for all operational scripts in the Dolibarr Docker setup.

## Overview

The setup includes several automated scripts for common operations:

- **Daily Workflow:** `daily_start.sh`, `daily_exit.sh`
- **Backup System:** `backup_dolibarr.sh`, `restore_dolibarr.sh`, `mark_blank_backup.sh`, `make_blank_backup.sh`
- **First Install:** `first_install.sh`
- **System Management:** `recreate_dolibarr.sh`, `uninstall_app.sh`
 - **Debug/Support:** `tools/capture_debug_info.sh`

## Daily Workflow Scripts

### daily_start.sh

**Purpose:** Safe startup routine with comprehensive health checks.

**Location:** `/workspaces/dolibarr/docker-deploy/daily_start.sh`

**Usage:**
```bash
cd /workspaces/dolibarr/docker-deploy
./daily_start.sh
```

**What it does:**
1. ✅ Starts all Docker containers
2. 🔍 Waits for services to become ready
3. 🏥 Performs health checks on database
4. 🌐 Verifies web interface accessibility  
5. 📊 Shows system status and URLs
6. ⚠️ Reports any issues found

**Sample Output:**
```
=======================================
🚀 Dolibarr Daily Startup Routine
=======================================

[2025-10-27 10:30:15] 🔄 Starting Docker containers...
✅ All containers started successfully

[2025-10-27 10:30:20] ⏳ Waiting for services to become ready...
✅ Database service is ready
✅ Web service is ready  
✅ Application service is ready

[2025-10-27 10:30:35] 🏥 Performing health checks...
✅ Database connection: OK
✅ Web interface: OK (HTTP 200)
✅ PHP-FPM: OK

🎉 Dolibarr startup completed successfully!

📋 System Information:
   🌐 Web Interface: http://localhost:8080
   🗄️ Database: MariaDB 10.11.8 (Ready)
   🐳 Containers: 3/3 Running
   💾 Disk Usage: 2.1GB / 15GB available

✨ Ready for daily operations!
```

**Exit Codes:**
- `0` - Success, all services ready
- `1` - Container startup failed
- `2` - Health check failed
- `3` - Service timeout

---

### tools/capture_debug_info.sh

**Purpose:** Capture a quick diagnostic bundle (compose status, logs, DB constants) for support.

**Location:** `/workspaces/dolibarr/docker-deploy/tools/capture_debug_info.sh`

**Usage:**
```bash
cd /workspaces/dolibarr/docker-deploy
./tools/capture_debug_info.sh
```

**Outputs:**
- `debug_info/compose_ps.txt`, `compose_config.yml`
- Recent logs for `web`, `app`, `db`
- Selected Dolibarr constants and sample category listing
- Blank backup listing if present

---

### first_install.sh

**Purpose:** Guided first install with environment checks and quick fixes.

**Location:** `/workspaces/dolibarr/docker-deploy/first_install.sh`

**Usage:**
```bash
cd /workspaces/dolibarr/docker-deploy
./first_install.sh --auto-conf --unlock --open
```

**What it does:**
1. 🚀 Starts Docker stack (`docker compose up -d`)
2. 📁 Ensures `/var/www/html/documents` exists and is writable (symlink `/var/www/documents`)
3. ⚙️ Copies `conf.php.example` to `conf.php` if missing (`--auto-conf`)
4. 🔓 Removes installer lock if present (`--unlock`)
5. 🌐 Optionally opens installer URL (`--open`)

---

### daily_exit.sh

**Purpose:** Safe shutdown with automatic backup creation.

**Location:** `/workspaces/dolibarr/docker-deploy/daily_exit.sh`

**Usage:**
```bash
cd /workspaces/dolibarr/docker-deploy
./daily_exit.sh
```

**What it does:**
1. 💾 Creates complete system backup
2. 🧹 Manages backup retention (3 recent + 1 blank)
3. 📊 Shows backup statistics
4. 🛑 Stops containers gracefully
5. ✅ Validates shutdown completion

**Sample Output:**
```
=======================================
🔒 Dolibarr Daily Exit Routine  
=======================================

[2025-10-27 18:30:00] 💾 Creating backup before shutdown...
✅ Database backup: 2.1MB
✅ Documents backup: 15.3MB  
✅ Configuration backup: 4KB
✅ Total backup size: 17.4MB

[2025-10-27 18:30:45] 🧹 Managing backup retention...
ℹ️ Current backups: 4 (3 recent + 1 blank)
🗑️ No cleanup needed

[2025-10-27 18:30:50] 🛑 Stopping containers gracefully...
✅ Containers stopped successfully

📋 Exit Summary:
   💾 Backup: dolibarr_backup_20251027_183000 (17.4MB)
   🗂️ Location: /workspaces/dolibarr/docker-deploy/backups/
   🔒 Data Protection: Complete
   
🎉 Safe exit completed! Your data is secured.
```

**Backup Retention Logic:**
- Keeps **last 3 daily backups** (rolling)
- **Preserves oldest backup** (assumed to be blank)
- **Maximum 4 backups** total at any time
- Automatically removes middle-aged backups

---

## Backup System Scripts

### backup_dolibarr.sh

**Purpose:** Create complete system backup on demand.

**Location:** `/workspaces/dolibarr/docker-deploy/backup_dolibarr.sh`

**Usage:**
```bash
cd /workspaces/dolibarr/docker-deploy
./backup_dolibarr.sh
```

**What it creates:**
- **Database dump:** Complete SQL export
- **Documents archive:** All uploaded files
- **Configuration backup:** System settings
- **Metadata file:** Backup information

**Backup Structure:**
```
backups/dolibarr_backup_YYYYMMDD_HHMMSS/
├── database.sql              # Complete database dump
├── documents.tar.gz          # All document files  
├── config/
│   └── conf.php             # Configuration file
└── backup_info.txt          # Backup metadata
```

**Sample Output:**
```
=======================================
📦 Dolibarr Backup Creation
=======================================

[2025-10-27 15:45:00] 🗄️ Backing up database...
✅ Database exported: 2,347 KB

[2025-10-27 15:45:15] 📁 Backing up documents...  
✅ Documents archived: 15,892 KB

[2025-10-27 15:45:30] ⚙️ Backing up configuration...
✅ Configuration saved: 4 KB

✅ Backup completed successfully!

📋 Backup Details:
   📦 Name: dolibarr_backup_20251027_154500
   📍 Location: /workspaces/dolibarr/docker-deploy/backups/
   📊 Total Size: 18.2 MB
   🕐 Duration: 45 seconds
```

---

### restore_dolibarr.sh

**Purpose:** Restore system from backup with validation.

**Location:** `/workspaces/dolibarr/docker-deploy/restore_dolibarr.sh`

**Usage:**
```bash
cd /workspaces/dolibarr/docker-deploy
./restore_dolibarr.sh /path/to/backup/directory
```

**What it does:**
1. 🔍 Validates backup integrity
2. 🛑 Stops running containers safely
3. 🗄️ Restores database from SQL dump
4. 📁 Restores documents and files
5. ⚙️ Restores configuration
6. 🚀 Restarts system with restored data
7. ✅ Validates restoration success

**Sample Usage:**
```bash
# List available backups
ls -la backups/

# Restore from specific backup
./restore_dolibarr.sh backups/dolibarr_backup_20251027_154500

# Restore from blank backup (reset to clean state)
./restore_dolibarr.sh backups/dolibarr_backup_20251025_120000_BLANK
```

**Sample Output:**
```
=======================================
🔄 Dolibarr Restore Process
=======================================

[2025-10-27 16:00:00] 🔍 Validating backup...
✅ Backup directory exists
✅ Database dump found: 2.3MB  
✅ Documents archive found: 15.9MB
✅ Configuration file found: 4KB

[2025-10-27 16:00:05] 🛑 Stopping current containers...
✅ Containers stopped safely

[2025-10-27 16:00:15] 🗄️ Restoring database...
✅ Database restored: 2,347KB imported

[2025-10-27 16:00:45] 📁 Restoring documents...
✅ Documents restored: 15,892KB extracted

[2025-10-27 16:01:00] ⚙️ Restoring configuration...
✅ Configuration restored

[2025-10-27 16:01:10] 🚀 Starting restored system...
✅ All containers started
✅ Health checks passed

🎉 Restore completed successfully!
   🕐 Backup Date: 2025-10-27 15:45:00
   📊 Data Restored: 18.2MB
   🌐 Access: http://localhost:8080
```

---

### mark_blank_backup.sh

**Purpose:** Create and mark initial "blank" backup for system reset capability.

**Location:** `/workspaces/dolibarr/docker-deploy/mark_blank_backup.sh`

**Usage:**
```bash
cd /workspaces/dolibarr/docker-deploy
./mark_blank_backup.sh
```

**When to use:**
- After completing Dolibarr installation
- Before adding any real business data  
- When you want a "factory reset" backup

**What it creates:**
- Backup with `_BLANK` suffix
- Special marker file: `BLANK_BACKUP_INFO.txt`
- Documentation of clean state
- Permanent preservation flag

**Sample Output:**
```
=======================================
🏷️ Dolibarr Blank Backup Marker
=======================================

[2025-10-25 12:00:00] 📊 Backing up database (blank state)...
✅ Clean database exported: 145KB

[2025-10-25 12:00:10] 📁 Backing up documents (minimal)...
✅ Empty document structure: 2KB

[2025-10-25 12:00:15] ⚙️ Backing up configuration...
✅ Fresh configuration saved: 4KB

✅ Blank backup created successfully!

📋 Backup Details:
   📦 Name: dolibarr_backup_20251025_120000_BLANK
   📍 Location: /workspaces/dolibarr/docker-deploy/backups/
   📊 Size: 151KB (minimal clean state)
   🏷️ Type: BLANK/INITIAL

🔒 This backup will be preserved by retention system
   (keeps oldest backup as blank + 3 most recent)

📝 IMPORTANT: This backup is now your 'clean slate'
   Use restore script with this backup to return to fresh state
```

---

### make_blank_backup.sh

**Purpose:** Create and label a blank backup (e.g., `BLANK02`).

**Location:** `/workspaces/dolibarr/docker-deploy/make_blank_backup.sh`

**Usage:**
```bash
cd /workspaces/dolibarr/docker-deploy
./make_blank_backup.sh BLANK02
```

**Notes:**
- Tags the latest backup dir with the provided label
- Writes `BLANK_BACKUP_INFO.txt` and adds `.protected`

---

## System Management Scripts

### recreate_dolibarr.sh

**Purpose:** Complete system recreation from scratch.

**Location:** `/workspaces/dolibarr/docker-deploy/recreate_dolibarr.sh`

**Usage:**
```bash
cd /workspaces/dolibarr/docker-deploy
./recreate_dolibarr.sh [new-installation]
```

**What it does:**
1. 🗑️ Removes all containers and volumes
2. 🧹 Cleans up Docker images
3. 🔄 Rebuilds containers from scratch
4. 🚀 Starts fresh system
5. ✅ Validates new installation

**Use cases:**
- System corruption recovery
- Clean installation on new environment
- Docker image updates
- Complete environment reset

**Sample Output:**
```
=======================================
🔄 Dolibarr Complete Recreation
=======================================

[2025-10-27 16:30:00] 🛑 Stopping and removing containers...
✅ Containers removed

[2025-10-27 16:30:10] 🗑️ Removing volumes and data...
✅ Volumes cleaned

[2025-10-27 16:30:20] 🧹 Cleaning Docker images...
✅ Images pruned  

[2025-10-27 16:30:30] 🔄 Building fresh containers...
✅ Images built successfully

[2025-10-27 16:30:45] 🚀 Starting recreated system...
✅ All services started
✅ Health checks passed

🎉 Recreation completed successfully!
   🌐 Access: http://localhost:8080
   📝 Ready for fresh Dolibarr installation
```

---

### uninstall_app.sh

**Purpose:** Reset to an uninstalled application state (keeps repository files).

**Location:** `/workspaces/dolibarr/docker-deploy/uninstall_app.sh`

**Usage:**
```bash
cd /workspaces/dolibarr/docker-deploy
./uninstall_app.sh -y
```

**What it does:**
1. 🛑 Stops the compose stack
2. 🗑️ Removes `htdocs/conf/conf.php` and `htdocs/install/install.lock`
3. 🧹 Removes project volumes (database + documents)
4. 🚀 Starts services fresh
5. 📣 Prints installer URL and next steps

---

## Script Management

### Making Scripts Executable

All scripts should be executable. If needed:

```bash
cd /workspaces/dolibarr/docker-deploy
chmod +x *.sh
```

### Script Dependencies

All scripts require:
- Docker and Docker Compose installed
- Being run from `/workspaces/dolibarr/docker-deploy` directory
- Proper file permissions on the scripts

### Error Handling

All scripts include:
- **Exit codes** for automation
- **Error messages** with colors
- **Validation checks** before operations
- **Safe failure modes** that don't corrupt data

### Logging

Scripts log to:
- **Console output** with timestamps and colors
- **File logs** in `logs/` directory (if configured)
- **Backup metadata** in backup directories

## Advanced Script Usage

### Automation Examples

**Daily Cron Jobs:**
```bash
# Add to crontab for automated daily operations
0 9 * * * /workspaces/dolibarr/docker-deploy/daily_start.sh
0 18 * * * /workspaces/dolibarr/docker-deploy/daily_exit.sh
```

**Backup Scheduling:**
```bash
# Weekly full backup (in addition to daily)
0 2 * * 0 /workspaces/dolibarr/docker-deploy/backup_dolibarr.sh
```

### Script Customization

**Environment Variables:**
```bash
# Customize backup retention
export BACKUP_RETENTION_DAYS=7
export BACKUP_MAX_COUNT=5

# Customize startup timeouts  
export STARTUP_TIMEOUT=300
export HEALTH_CHECK_RETRIES=10
```

**Configuration Files:**
- Edit scripts directly for permanent changes
- Use environment variables for runtime customization
- Create wrapper scripts for specific use cases

### Troubleshooting Scripts

**Check Script Status:**
```bash
# Verify all scripts are executable
ls -la *.sh

# Test script syntax
bash -n daily_start.sh
bash -n daily_exit.sh
```

**Debug Mode:**
```bash
# Run scripts with debug output
bash -x daily_start.sh
bash -x daily_exit.sh
```

For troubleshooting tips, see Getting Help in [README.md](README.md) and use:
```bash
docker compose ps
docker compose logs -f [service]
```