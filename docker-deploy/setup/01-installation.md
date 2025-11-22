# Complete Installation Guide

Step-by-step installation process for Dolibarr Docker setup in GitHub Codespaces.

## Prerequisites

- GitHub Codespace with Ubuntu 24.04.2 LTS
- Docker 27.3.1+ and Docker Compose 2.29.7+ (pre-installed)
- 4GB+ RAM and 10GB+ storage space

## Step 1: Initial Setup

### 1.1 Navigate to Project Directory
```bash
cd /workspaces/dolibarr/docker-deploy
```

### 1.2 Verify Files Present
Check that all required files exist:
```bash
ls -la
```

You should see:
- `docker-compose.yml` - Container orchestration
- `Dockerfile` - PHP application container
- `nginx.conf` - Web server configuration  
- `htdocs/conf/conf.php.example` - Smart configuration template (already in repo)
- `daily_start.sh` - Startup script
- `daily_exit.sh` - Shutdown script
- `backup_dolibarr.sh` - Backup script
- `restore_dolibarr.sh` - Restore script
- `mark_blank_backup.sh` - Blank backup marker
 - `make_blank_backup.sh` - Create a labeled blank backup (e.g., BLANK02)
 - `uninstall_app.sh` - Reset app to uninstalled state (removes DB/docs volumes)
 - `first_install.sh` - Bring stack up and check conf.php, documents dir, install.lock

## Step 2: Start the System

### 2.1 Start Containers (Recommended)
```bash
./daily_start.sh
```

This script will:
- Start all Docker containers
- Wait for services to become ready
- Perform health checks
- Display access URLs and status

### 2.2 Alternative Basic Start
```bash
docker compose up -d
```

### 2.2.1 First-Install Helper (optional)
For a guided first install with checks and optional auto-setup:
```bash
./first_install.sh --auto-conf --unlock --open
```
This will copy `conf.php.example` if missing, remove `install.lock` if present,
ensure the documents directory is ready inside the container, and open the installer.

### 2.3 Verify Containers Are Running
```bash
docker compose ps
```

Expected output:
```
NAME                     IMAGE                    COMMAND                  SERVICE   CREATED         STATUS         PORTS
docker-deploy-app-1      docker-deploy_app        "docker-php-entrypoi…"   app       2 minutes ago   Up 2 minutes   9000/tcp
docker-deploy-db-1       mariadb:10.11.8          "docker-entrypoint.s…"   db        2 minutes ago   Up 2 minutes   0.0.0.0:3306->3306/tcp
docker-deploy-web-1      nginx:1.26.2-alpine      "/docker-entrypoint.…"   web       2 minutes ago   Up 2 minutes   0.0.0.0:8080->80/tcp
```

## Step 3: Access Dolibarr

### 3.1 Open in Browser
```bash
"$BROWSER" http://localhost:8080
```

### 3.2 Alternative: Use VS Code Simple Browser
In VS Code, press `Ctrl+Shift+P` and type "Simple Browser: Show" then enter `http://localhost:8080`

## Step 4: Complete Dolibarr Installation

### 4.1 Start Installation Wizard
When you first access http://localhost:8080, you'll see the Dolibarr installation wizard.

### 4.2 Database Configuration
Use these **exact** database settings:

| Setting | Value |
|---------|-------|
| **Setting** | **Value** |
|------------|----------|
| **Database Type** | MySQL/MariaDB |
| **Database Server** | `db` |
| **Database Port** | `3306` |
| **Database Name** | `dolibarr` |
| **Database Username** | `dolibarr` |
| **Database Password** | `dolibarrpass` |
| **Database Prefix** | `llx_` |

### 4.3 Administrator Account
Create your admin account:
- **Login:** Your choice (e.g., `admin`)
- **Password:** Strong password of your choice
- **Email:** Your email address

### 4.4 Company Information
Fill in your company/organization details as needed.

### 4.5 Complete Installation
Follow the wizard through all steps until installation is complete.

## Step 5: Create Blank Backup

**IMPORTANT:** After installation is complete but **before** adding any real business data:

```bash
cd /workspaces/dolibarr/docker-deploy
./mark_blank_backup.sh
```

This creates a "blank" backup that:
- Contains your fresh installation
- Will be permanently preserved
- Can be used to reset to clean state
- Is marked with `_BLANK` suffix

## Step 6: Verify Installation

### 6.1 Check Dolibarr Access
- Navigate to http://localhost:8080
- Log in with your admin credentials
- Verify all modules load correctly

### 6.2 Check File Permissions
```bash
docker compose exec app ls -la /var/www/html/conf/
```

Should show proper ownership (www-data:www-data).

### 6.3 Check Database Connection
```bash
docker compose exec db mysql -u dolibarr -pdolibarrpass -e "SHOW TABLES;" dolibarr
```

Should show Dolibarr tables created during installation.

## Step 7: Daily Workflow Setup

### 7.1 Test Daily Exit
```bash
./daily_exit.sh
```

This should:
- Create a backup
- Stop all containers safely
- Display backup information

### 7.2 Test Daily Start  
```bash
./daily_start.sh
```

This should:
- Start all containers
- Perform health checks
- Show system status

## Configuration Details

### Smart Configuration Features
The system automatically configures:
- Database connection parameters
- Document storage paths  
- URL and domain settings
- File permissions and security
- Performance optimizations

### Configuration Location
The active configuration is generated automatically at:
`/var/www/html/conf/conf.php`

Based on the template:
`/workspaces/dolibarr/htdocs/conf/conf.php.example`

## Post-Installation Steps

### Enable Required Modules
In Dolibarr admin interface:
1. Go to **Home > Setup > Modules**
2. Enable modules you need:
   - Users & Groups
   - Third Parties (Customers/Suppliers)  
   - Products & Services
   - Invoices
   - Orders
   - Accounting
   - etc.

### Configure Basic Settings
1. **Company:** Setup > Company
2. **Numbering:** Setup > Numbering  
3. **Display:** Setup > Display
4. **Security:** Setup > Security

## Backup Strategy

After installation:
1. **Blank backup** created with `mark_blank_backup.sh`
2. **Daily backups** created automatically with `daily_exit.sh`
3. **Retention:** 3 recent + 1 blank backup (4 total max)
4. **Manual backups** available with `backup_dolibarr.sh`

## Troubleshooting Installation

### Common Issues

**Issue: Can't connect to database**
```bash
# Check database container
docker compose logs db

# Verify database credentials
docker compose exec db mysql -u root -prootpassword -e "SHOW DATABASES;"
```

**Issue: Permission denied errors**
```bash
# Check file ownership
docker compose exec app ls -la /var/www/html/

# Fix permissions if needed
docker compose exec app chown -R www-data:www-data /var/www/html/
```

**Issue: Containers won't start**
```bash
# Check Docker status
docker --version
docker compose version

# Check for port conflicts
netstat -tuln | grep 8080
netstat -tuln | grep 3306
```

### Getting Help

1. Check logs: `docker compose logs -f [service]`
2. Check container status: `docker compose ps`
3. Review configuration: `cat /workspaces/dolibarr/htdocs/conf/conf.php.example` (template) or `cat /workspaces/dolibarr/htdocs/conf/conf.php` (active after install)
4. See Getting Help in [setup/README.md](README.md) for quick diagnostics

## Next Steps

After successful installation:
1. Read [04-daily-workflow.md](04-daily-workflow.md) for daily usage
2. Review [05-backup-system.md](05-backup-system.md) for data protection
3. Customize configuration in [02-configuration.md](02-configuration.md)
4. Check [03-scripts.md](03-scripts.md) for available automation