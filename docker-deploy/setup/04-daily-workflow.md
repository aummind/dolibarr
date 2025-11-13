# Daily Workflow Guide

Best practices and workflows for daily Dolibarr operations in GitHub Codespaces.

## Overview

This guide covers the recommended daily workflow for using Dolibarr safely in a Codespace environment with automatic data protection.

## Daily Workflow Cycle

```
🌅 Morning Start          🏠 Evening Exit
     ↓                          ↑
🚀 daily_start.sh    →    💼 Work Day    →    🔒 daily_exit.sh
     ↓                                              ↓
✅ Health Checks     →    📊 Use Dolibarr   →   💾 Auto Backup
     ↓                                              ↓
🌐 Access Ready      →    📝 Enter Data     →   🛑 Safe Shutdown
```

## Step 1: Daily Startup Routine

### 1.1 Start Your Codespace
Open your GitHub Codespace and navigate to the project:

```bash
cd /workspaces/dolibarr/docker-deploy
```

### 1.2 Execute Daily Start Script
```bash
./daily_start.sh
```

**This script will:**
- ✅ Start all Docker containers
- ⏳ Wait for services to become ready
- 🏥 Perform comprehensive health checks
- 📊 Display system status and access URLs
- 🚨 Alert you to any issues

### 1.3 Verify System Ready
Look for this success message:
```
🎉 Dolibarr startup completed successfully!

📋 System Information:
   🌐 Web Interface: http://localhost:8080
   🗄️ Database: MariaDB 10.11.8 (Ready)
   🐳 Containers: 3/3 Running
   💾 Disk Usage: 2.1GB / 15GB available

✨ Ready for daily operations!
```

### 1.4 Open Dolibarr Interface
```bash
"$BROWSER" http://localhost:8080
```

Or use the VS Code "Ports" tab to access port 8080.

## Step 2: Create Your Blank Backup (ONE TIME ONLY)

**Important**: After completing the Dolibarr installation but BEFORE adding any real business data, create a "blank" backup:

```bash
cd /workspaces/dolibarr/docker-deploy
./mark_blank_backup.sh
```

This creates a special backup of your clean installation state that will be:
- Permanently preserved (never deleted by cleanup)
- Available for system reset to clean state
- Marked with `_BLANK` suffix for easy identification

**When to create**: After installation wizard is complete, user accounts set up, but before:
- Adding customers/suppliers
- Creating products/services  
- Recording transactions
- Uploading documents

## Step 3: Daily Operations

### 3.1 Normal Dolibarr Usage
Use Dolibarr normally for your business operations:

- **Customer Management:** Add/edit customers and suppliers
- **Product Catalog:** Manage products and services
- **Sales:** Create quotes, orders, and invoices
- **Purchasing:** Handle supplier orders and bills
- **Accounting:** Record transactions and generate reports
- **Document Management:** Upload and organize files

### 3.2 Best Practices During Work

**Data Entry:**
- Save work frequently using Dolibarr's save functions
- Use Dolibarr's built-in validation features
- Keep sessions active (system auto-saves)

**File Management:**
- Upload documents through Dolibarr interface
- Use descriptive filenames
- Organize files in appropriate categories

**Performance:**
- Avoid very large file uploads (>20MB limit)
- Close unused browser tabs to save memory
- Monitor Codespace resource usage

### 3.3 Monitoring System Health

Check system status anytime:
```bash
cd /workspaces/dolibarr/docker-deploy
docker compose ps
```

View recent logs if needed:
```bash
docker compose logs --tail=50 -f
```

## Step 4: Daily Exit Routine

### 4.1 Complete Your Work
- Finish entering data in Dolibarr
- Save any open forms/transactions
- Log out of Dolibarr interface (optional)

### 4.2 Execute Daily Exit Script
```bash
cd /workspaces/dolibarr/docker-deploy
./daily_exit.sh
```

**This script will:**
- 💾 Create complete backup (database + documents + config)
- 🧹 Manage backup retention (keep 3 recent + 1 blank)
- 📊 Show backup statistics and location
- 🛑 Stop all containers gracefully
- ✅ Validate safe shutdown

### 4.3 Verify Safe Exit
Look for this completion message:
```
🎉 Safe exit completed! Your data is secured.

📋 Exit Summary:
   💾 Backup: dolibarr_backup_20251027_183000 (17.4MB)
   🗂️ Location: /workspaces/dolibarr/docker-deploy/backups/
   🔒 Data Protection: Complete
```

### 4.4 Stop Your Codespace
You can now safely stop your GitHub Codespace. Your data is:
- ✅ **Backed up** in the `/workspaces/dolibarr/docker-deploy/backups/` directory
- ✅ **Persistent** in Docker volumes (survives Codespace restart)
- ✅ **Protected** by retention policy (3 recent + 1 blank backup)

## Backup Management Strategy

### Automatic Backup Retention

The system maintains **4 backups maximum**:

1. **Blank Backup** (permanent)
   - Created once after installation
   - Never deleted automatically  
   - Use for "factory reset"
   - Marked with `_BLANK` suffix

2. **3 Most Recent Backups** (rolling)
   - Created by `daily_exit.sh`
   - Contains all your business data
   - Oldest of these 3 gets deleted when new backup is created

### Manual Backup Options

**Create additional backup anytime:**
```bash
./backup_dolibarr.sh
```

**List available backups:**
```bash
ls -la backups/
```

**Restore from backup if needed:**
```bash
./restore_dolibarr.sh backups/dolibarr_backup_YYYYMMDD_HHMMSS
```

## Weekly/Monthly Maintenance

### Weekly Tasks

**Review Backup Storage:**
```bash
cd /workspaces/dolibarr/docker-deploy
du -sh backups/
ls -la backups/
```

**System Health Check:**
```bash
./daily_start.sh
# Review all health check results
```

**Update Documentation:**
- Document any configuration changes
- Note any custom modules installed
- Record important business milestones

### Monthly Tasks

**Full System Test:**
1. Create test backup: `./backup_dolibarr.sh`
2. Test restore process: `./restore_dolibarr.sh backups/[latest]`
3. Verify all data integrity
4. Document any issues found

**Performance Review:**
- Check Codespace resource usage
- Review container performance: `docker stats`
- Consider optimization if needed

**Security Review:**
- Update passwords if needed
- Review user access levels in Dolibarr
- Check for Dolibarr updates

## Emergency Procedures

### System Won't Start

```bash
# Check container status
docker compose ps

# View error logs
docker compose logs

# Try recreation if corrupted
./recreate_dolibarr.sh

# Restore from recent backup
./restore_dolibarr.sh backups/[most_recent]
```

### Data Recovery

**If you need to restore to previous state:**

```bash
# List available backups
ls -la backups/

# Restore from specific backup
./restore_dolibarr.sh backups/dolibarr_backup_20251027_183000

# Or restore to blank state
./restore_dolibarr.sh backups/[blank_backup_name]
```

### Codespace Issues

**If Codespace becomes unresponsive:**

1. **GitHub Web Interface:** Use "Restart Codespace" option
2. **After Restart:** Run `./daily_start.sh` to resume
3. **Data Recovery:** Your data persists in Docker volumes
4. **Backup Recovery:** Use `./restore_dolibarr.sh` if volumes are corrupted

## Best Practices Summary

### ✅ Do These Daily

- **Always use `daily_start.sh`** for morning startup
- **Always use `daily_exit.sh`** for evening shutdown  
- **Monitor system health** messages during startup
- **Save work frequently** within Dolibarr
- **Check backup completion** messages during exit

### ❌ Avoid These Actions

- **Don't force-stop** containers (`Ctrl+C` on docker compose)
- **Don't skip daily exit** script (lose backup protection)
- **Don't ignore health warnings** during startup
- **Don't manually edit** Docker volumes (use restore scripts)
- **Don't delete backups manually** (use retention system)

### 🚨 Emergency Actions

- **System corrupted:** Use `./recreate_dolibarr.sh`
- **Data loss:** Use `./restore_dolibarr.sh [backup]`
- **Factory reset:** Restore from blank backup
- **Can't access:** Check `docker compose logs`

## Customization Options

### Modify Startup Behavior

Edit `daily_start.sh` to:
- Change health check timeouts
- Add custom validation steps
- Integrate with monitoring tools
- Customize status reporting

### Modify Backup Behavior

Edit `daily_exit.sh` to:
- Change backup retention policy
- Add backup compression
- Include additional files
- Send backup notifications

### Environment Variables

Set these for customization:
```bash
export BACKUP_RETENTION_DAYS=7
export STARTUP_TIMEOUT=300
export HEALTH_CHECK_RETRIES=10
```

## Integration with Development Workflow

### Version Control

The setup respects your git workflow:
- Scripts and configuration are version controlled
- Data and backups are in `.gitignore`
- Easy to recreate setup in new Codespaces

### CI/CD Integration

Scripts can be integrated with automation:
- Use exit codes for success/failure detection
- Parse JSON output for monitoring
- Integrate with deployment pipelines

### Team Collaboration

For team environments:
- Share configuration changes via git
- Document customizations in setup files
- Use consistent backup naming conventions
- Maintain team access to backup storage

This workflow ensures your Dolibarr data is always protected while providing a smooth daily experience in GitHub Codespaces.