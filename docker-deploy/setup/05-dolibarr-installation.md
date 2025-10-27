# Dolibarr Installation Guide

## Overview
This guide walks through the Dolibarr installation process using the web installer after Docker containers are running.

## Prerequisites

Before starting installation, ensure:
1. ✅ Docker containers are running
2. ✅ Database is accessible
3. ✅ PHP extensions are enabled
4. ✅ conf.php does NOT exist (or is empty)

### Verify Prerequisites

```bash
# Check containers
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml ps

# Check PHP extensions
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app php -m | grep -E '(mysqli|calendar|imap)'

# Check database connection
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app php -r "
\$conn = new mysqli('db', 'dolibarr', 'dolibarrpass', 'dolibarr');
echo \$conn->connect_error ? 'Failed' : 'OK';
"

# Ensure conf.php doesn't exist
ls -la /workspaces/dolibarr/htdocs/conf/conf.php 2>&1
```

## Accessing the Installer

### Local Access
```
http://localhost:8080/
```

### Codespace Access
```
https://your-codespace-name-8080.app.github.dev/
```

**Note**: If the URL shows a login page instead of installer, remove `conf.php`:
```bash
rm /workspaces/dolibarr/htdocs/conf/conf.php
```

## Installation Steps

### Step 1: Start Page

When you access the URL, you'll see:
- **Title**: "Dolibarr install or upgrade"
- **Version**: 23.0.0-alpha (or current version)
- **Language Selection**: Choose your language

**Action**: Click "Start" or "Next"

---

### Step 2: License Agreement

- Review the GPL license
- Check "I agree with the terms of this license"

**Action**: Click "Next"

---

### Step 3: Check Prerequisites

The installer checks:
- ✅ PHP Version (8.2)
- ✅ PHP Extensions:
  - mysqli
  - calendar
  - imap
  - gd
  - intl
  - mbstring
  - xml
  - zip
- ✅ Directory Permissions:
  - `conf/` writable
  - `documents/` writable

**Expected Result**: All checks should be green ✅

**If warnings appear**:
- ⚠️ IMAP not supported → Already fixed in our setup
- ⚠️ Calendar not supported → Already fixed in our setup
- ⚠️ Directory not writable → Check permissions

**Action**: Click "Next" if all checks pass

---

### Step 4: Database Configuration

Enter the database connection details:

| Field | Value | Notes |
|-------|-------|-------|
| **Database Type** | MySQL or MariaDB | Select from dropdown |
| **Server/Host** | `db` | Docker service name |
| **Port** | `3306` | Default MySQL port |
| **Database Name** | `dolibarr` | Pre-created database |
| **Database User** | `dolibarr` | Application user |
| **Database Password** | `dolibarrpass` | Application password |
| **Database Prefix** | `llx_` | Default (don't change) |
| **Create Database** | Unchecked | Database already exists |

**Important**: 
- Use `db` as hostname, NOT `localhost` or `127.0.0.1`
- Database `dolibarr` already exists (created by docker-compose)

**Action**: Click "Next"

---

### Step 5: Database Creation/Verification

The installer will:
1. Test database connection
2. Verify database exists
3. Check if tables need to be created

**Expected Result**: 
- ✅ Connection successful
- ✅ Database found
- Ready to create tables

**Action**: Click "Next" to create tables

---

### Step 6: Administrator Account

Create your Dolibarr administrator account:

| Field | Description | Example |
|-------|-------------|---------|
| **Login** | Admin username | `admin` |
| **Password** | Strong password | Choose secure password |
| **Confirm Password** | Re-enter password | Match above |
| **Last Name** | Administrator last name | `Administrator` |
| **First Name** | Administrator first name | `System` |
| **Email** | Admin email | `admin@example.com` |

**Password Requirements**:
- At least 8 characters
- Mix of letters, numbers, symbols recommended

**Action**: Click "Next"

---

### Step 7: Configuration File Creation

The installer creates `conf/conf.php` with:
- Database connection settings
- Document root path
- URL configuration
- Security settings

**Expected Result**: 
- ✅ Configuration file created successfully
- File location: `/var/www/html/conf/conf.php`

**Action**: Click "Next"

---

### Step 8: Completion

**Success Message**: "Installation completed successfully"

The installer creates:
1. ✅ `conf/conf.php` - Main configuration
2. ✅ Database tables (llx_*)
3. ✅ Administrator account
4. ✅ `documents/install.lock` - Prevents reinstallation

**Action**: Click "Go to Dolibarr"

---

## Post-Installation

### First Login

1. You'll be redirected to the login page
2. Enter your administrator credentials:
   - **Login**: Your admin username
   - **Password**: Your admin password
3. Click "Login"

### Initial Setup

After first login:

1. **Company Information**
   - Menu: Home → Setup → Company/Organization
   - Enter your company details

2. **Modules**
   - Menu: Home → Setup → Modules/Applications
   - Enable modules you need (invoices, products, etc.)

3. **Users & Permissions**
   - Menu: Home → Users & Groups
   - Create additional users as needed

4. **Dictionaries**
   - Menu: Home → Setup → Dictionaries
   - Configure countries, currencies, payment types

---

## Verifying Installation

### Check Configuration File

```bash
# View conf.php (first 30 lines)
head -30 /workspaces/dolibarr/htdocs/conf/conf.php
```

Should contain:
```php
$dolibarr_main_url_root='http://localhost:8080';
$dolibarr_main_document_root='/var/www/html';
$dolibarr_main_db_host='db';
$dolibarr_main_db_name='dolibarr';
```

### Check Install Lock

```bash
ls -la /workspaces/dolibarr/htdocs/documents/install.lock
```

Should exist. This prevents reinstallation.

### Check Database Tables

```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysql -u dolibarr -pdoblibarrpass dolibarr -e "SHOW TABLES;" | head -20
```

Should show many `llx_*` tables.

### Verify Login

1. Access: `http://localhost:8080/`
2. Should show login page (not installer)
3. Login with admin credentials
4. Should see Dolibarr dashboard

---

## Troubleshooting Installation

### Issue: Can't Access Installer - Shows Login Page

**Cause**: conf.php exists with valid configuration

**Solution**: Remove conf.php and install.lock
```bash
rm /workspaces/dolibarr/htdocs/conf/conf.php
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app rm -f /var/www/html/documents/install.lock
```

---

### Issue: "functions.lib.php not found"

**Cause**: conf.php exists but has incorrect paths (often the example template)

**Solution**: Delete conf.php
```bash
rm /workspaces/dolibarr/htdocs/conf/conf.php
```

---

### Issue: Database Connection Failed

**Symptoms**: "Can't connect to database" error

**Check database is running**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml ps db
```

**Check credentials**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysql -u dolibarr -pdoblibarrpass dolibarr -e "SELECT 1;"
```

**Common mistakes**:
- Using `localhost` instead of `db` as hostname
- Wrong password
- Database doesn't exist

**Solution**: Verify docker-compose.yml database settings match installer input

---

### Issue: "Driver mysqli not available"

**Cause**: PHP mysqli extension not installed

**Check extension**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app php -m | grep mysqli
```

**Solution**: Rebuild PHP container
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml build --no-cache app
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml up -d
```

---

### Issue: Calendar/IMAP Not Supported Warning

**Cause**: PHP extensions not installed

**Check extensions**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app php -m | grep -E '(calendar|imap)'
```

**Solution**: Already included in our Dockerfile. If missing, rebuild:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml build --no-cache app
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml up -d
```

---

### Issue: Permission Denied Writing conf.php

**Cause**: conf/ directory not writable

**Check permissions**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app ls -ld /var/www/html/conf
```

**Solution**: Fix permissions
```bash
chmod 777 /workspaces/dolibarr/htdocs/conf
```

---

### Issue: 502 Bad Gateway During Installation

**Cause**: PHP-FPM container not running

**Check status**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml ps app
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml logs app
```

**Solution**: Restart containers
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml restart app
```

---

## Reinstalling Dolibarr

If you need to reinstall from scratch:

### Method 1: Keep Database

```bash
# Remove config and lock
rm /workspaces/dolibarr/htdocs/conf/conf.php
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app rm -f /var/www/html/documents/install.lock

# Access installer
# http://localhost:8080/
```

### Method 2: Fresh Install (Deletes All Data)

```bash
# Stop and remove everything including data
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml down -v

# Remove config
rm -f /workspaces/dolibarr/htdocs/conf/conf.php

# Rebuild and start
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml up -d

# Wait for services to be ready
sleep 10

# Access installer
# http://localhost:8080/
```

---

## Configuration File Details

### conf.php Structure

The installer creates `/var/www/html/conf/conf.php` with:

```php
<?php
// Main parameters
$dolibarr_main_url_root='http://localhost:8080';
$dolibarr_main_document_root='/var/www/html';
$dolibarr_main_data_root='/var/www/html/documents';
$dolibarr_main_db_host='db';
$dolibarr_main_db_port='3306';
$dolibarr_main_db_name='dolibarr';
$dolibarr_main_db_prefix='llx_';
$dolibarr_main_db_user='dolibarr';
$dolibarr_main_db_pass='dolibarrpass';
$dolibarr_main_db_type='mysqli';
$dolibarr_main_db_character_set='utf8mb4';
$dolibarr_main_db_collation='utf8mb4_unicode_ci';

// Security
$dolibarr_main_authentication='dolibarr';
$dolibarr_main_force_https='0';

// Other settings...
```

### Important Paths

| Variable | Value | Purpose |
|----------|-------|---------|
| `$dolibarr_main_url_root` | `http://localhost:8080` | Base URL |
| `$dolibarr_main_document_root` | `/var/www/html` | Application root |
| `$dolibarr_main_data_root` | `/var/www/html/documents` | Data storage |

---

## Database Structure

### Core Tables (Sample)

| Table | Purpose |
|-------|---------|
| `llx_user` | User accounts |
| `llx_societe` | Companies/customers |
| `llx_product` | Products/services |
| `llx_facture` | Invoices |
| `llx_commande` | Orders |
| `llx_const` | System configuration |

### View All Tables

```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysql -u dolibarr -pdoblibarrpass dolibarr -e "
SELECT 
    TABLE_NAME,
    TABLE_ROWS,
    ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'dolibarr'
ORDER BY TABLE_NAME;
"
```

---

## Post-Installation Configuration

### Recommended Settings

1. **Setup → Company/Organization**
   - Company name and logo
   - Address and contact info
   - Tax IDs

2. **Setup → Modules/Applications**
   - Enable: Third Parties, Invoices, Products
   - Enable modules based on your needs

3. **Setup → Display**
   - Theme selection
   - Language preferences
   - Date/time format

4. **Setup → Security**
   - Password policy
   - Session timeout
   - Login attempts limit

5. **Setup → Other**
   - Email configuration (SMTP)
   - Document templates
   - Numbering rules

---

## Backup Recommendations

After successful installation:

### Backup Database
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysqldump -u dolibarr -pdoblibarrpass dolibarr > initial_install_backup.sql
```

### Backup Configuration
```bash
cp /workspaces/dolibarr/htdocs/conf/conf.php conf.php.backup
```

### Backup Documents
```bash
tar -czf documents_backup.tar.gz /workspaces/dolibarr/htdocs/documents/
```

---

## Next Steps

After installation:

1. ✅ **Configure company information**
2. ✅ **Enable required modules**
3. ✅ **Create additional users**
4. ✅ **Set up email (SMTP)**
5. ✅ **Configure document templates**
6. ✅ **Import initial data** (products, customers)
7. ✅ **Configure backups**

---

## Reference

- **Dolibarr Documentation**: https://www.dolibarr.org/documentation
- **Dolibarr Wiki**: https://wiki.dolibarr.org/
- **Prerequisites**: https://wiki.dolibarr.org/index.php/Prerequisites

---

**See Also**:
- [Docker Commands](01-docker-commands.md)
- [PHP Configuration](02-php-configuration.md)
- [MariaDB Configuration](04-mariadb-configuration.md)
- [Troubleshooting](06-troubleshooting.md)
