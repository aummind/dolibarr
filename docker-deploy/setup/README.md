# Dolibarr Docker Setup Guide

Complete setup documentation for Dolibarr ERP/CRM using Docker containers in GitHub Codespaces.

## Overview

This setup provides a production-ready Dolibarr installation with:
- **PHP 8.2-FPM** with all required extensions
- **MariaDB 10.11.8** with UTF8MB4 support
- **Nginx 1.26.2** as reverse proxy
- **Smart configuration** that auto-detects environment
- **Complete backup system** with retention policy
- **Daily workflow scripts** for safe operations

## Quick Start

1. **Start the system:**
   ```bash
   cd /workspaces/dolibarr/docker-deploy
   ./daily_start.sh
   ```

2. **Open Dolibarr:**
   ```bash
   "$BROWSER" http://localhost:8080
   ```

3. **Complete installation** using the web interface

4. **Create blank backup** (after installation, before real data):
   ```bash
   ./mark_blank_backup.sh
   ```

5. **Daily exit** (creates backup and stops safely):
   ```bash
   ./daily_exit.sh
   ```

## Documentation Structure

- **[01-installation.md](01-installation.md)** - Complete installation process
- **[02-configuration.md](02-configuration.md)** - Configuration details and customization
- **[03-scripts.md](03-scripts.md)** - All operational scripts documentation
- **[04-daily-workflow.md](04-daily-workflow.md)** - Daily usage patterns and best practices
- **[05-backup-system.md](05-backup-system.md)** - Backup, restore, and retention policies


## System Requirements

- **OS:** Ubuntu 24.04.2 LTS (GitHub Codespace)
- **Docker:** 27.3.1+ with Docker Compose 2.29.7+
- **Memory:** 4GB+ recommended
- **Storage:** 10GB+ for application + backups

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     GitHub Codespace                        │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                Docker Environment                       │ │
│  │                                                         │ │
│  │  ┌──────────┐  ┌──────────────┐  ┌─────────────────┐   │ │
│  │  │   Web    │  │     App      │  │    Database     │   │ │
│  │  │  Nginx   │◄─┤  PHP 8.2-FPM │◄─┤  MariaDB 10.11 │   │ │
│  │  │ :80      │  │   Dolibarr   │  │   UTF8MB4       │   │ │
│  │  └──────────┘  └──────────────┘  └─────────────────┘   │ │
│  │       ▲               ▲                    ▲            │ │
│  │       │               │                    │            │ │
│  │  ┌────┴─────┐  ┌──────┴─────┐  ┌─────────┴──────┐     │ │
│  │  │ nginx_   │  │dolibarr_   │  │   dolibarr_    │     │ │
│  │  │ config   │  │documents   │  │   database     │     │ │
│  │  └──────────┘  └────────────┘  └────────────────┘     │ │
│  └─────────────────────────────────────────────────────────┘ │
│                             ▲                                │
│                    ┌────────┴─────────┐                     │
│                    │  Host Port 8080  │                     │
│                    └──────────────────┘                     │
└─────────────────────────────────────────────────────────────┘
```

## Key Features

### Smart Configuration
- Auto-detects Docker environment
- Configures database connections automatically  
- Sets appropriate paths for Codespace environment
- No manual configuration required

### Backup System
- **Retention Policy:** 3 recent backups + 1 permanent blank backup
- **Automatic cleanup** of old backups
- **Complete backups** include database, documents, and configuration
- **One-command restore** capability

### Daily Workflow
- **Safe startup** with health checks (`daily_start.sh`)
- **Safe exit** with automatic backup (`daily_exit.sh`)
- **Status monitoring** and validation
- **Error detection** and reporting

### Security Features
- Proper file permissions and ownership
- Secure database configuration
- Isolated Docker containers
- Regular backup validation

## Getting Help

1. Review logs: `docker compose logs -f`
2. Check container status: `docker compose ps`
4. Verify configuration template in `/workspaces/dolibarr/htdocs/conf/conf.php.example`

## Version Information

- **Creation Date:** October 27, 2025
- **Docker Version:** 27.3.1+
- **Docker Compose:** 2.29.7+
- **PHP Version:** 8.2.24-FPM
- **MariaDB Version:** 10.11.8
- **Nginx Version:** 1.26.2-Alpine
- **Dolibarr:** Latest stable (configured via auto-setup)