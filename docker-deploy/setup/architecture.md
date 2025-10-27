# Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Host System                          │
│  (GitHub Codespace / Local Machine)                     │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │           Docker Environment                       │ │
│  │                                                    │ │
│  │  ┌──────────────┐         ┌──────────────┐       │ │
│  │  │   Nginx      │ :8080   │  PHP-FPM     │       │ │
│  │  │   (web)      │◄────────┤   (app)      │       │ │
│  │  │ Alpine Linux │  HTTP   │  Debian 12   │       │ │
│  │  └──────┬───────┘         └──────┬───────┘       │ │
│  │         │                        │               │ │
│  │         │ :80              :9000 │               │ │
│  │         │                        │               │ │
│  │         │                        │               │ │
│  │         │         ┌──────────────▼───────┐       │ │
│  │         │         │    MariaDB 10.11     │       │ │
│  │         │         │       (db)           │       │ │
│  │         │         │  MySQL Compatible    │       │ │
│  │         │         └──────────────────────┘       │ │
│  │         │                   :3306                │ │
│  │         │                                        │ │
│  │  ┌──────▼──────────────────────────────────┐    │ │
│  │  │           Volumes                       │    │ │
│  │  │  ┌────────────────┬──────────────────┐ │    │ │
│  │  │  │ mariadb_data   │ dolibarr_docs    │ │    │ │
│  │  │  │  (persistent)  │   (persistent)   │ │    │ │
│  │  │  └────────────────┴──────────────────┘ │    │ │
│  │  │  ┌────────────────────────────────┐    │    │ │
│  │  │  │  ../htdocs (bind mount)        │    │    │ │
│  │  │  │  Dolibarr application files    │    │    │ │
│  │  │  └────────────────────────────────┘    │    │ │
│  │  └─────────────────────────────────────────┘    │ │
│  └────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘

External Access:
  ├─ localhost:8080 (local)
  └─ codespace-url-8080.app.github.dev (Codespace)
```

## Component Breakdown

### 1. Web Layer (Nginx)

**Purpose**: HTTP server and reverse proxy

**Responsibilities**:
- Serve static files (CSS, JS, images)
- Forward PHP requests to PHP-FPM
- Handle HTTP connections
- Security (block access to /conf)

**Configuration**:
- Port: 80 (internal) → 8080 (host)
- Document Root: `/var/www/html`
- FastCGI Proxy: `app:9000`

**Flow**:
```
User Request → Nginx :80
   ├─ Static file? → Serve directly
   └─ PHP file? → Forward to PHP-FPM :9000
```

### 2. Application Layer (PHP-FPM)

**Purpose**: Execute PHP code

**Responsibilities**:
- Process PHP scripts
- Connect to database
- Handle business logic
- Generate dynamic content

**Configuration**:
- PHP Version: 8.2
- User: dolibarr (UID 1000)
- Memory: 256M
- Execution Time: 300s

**Extensions**:
- Database: mysqli, pdo_mysql
- Required: calendar, imap
- Processing: gd, imagick, xml, zip
- Other: intl, mbstring, soap, bcmath

**Flow**:
```
Nginx Request → PHP-FPM :9000
   ├─ Parse PHP code
   ├─ Query database (if needed)
   ├─ Generate HTML
   └─ Return to Nginx
```

### 3. Database Layer (MariaDB)

**Purpose**: Data persistence

**Responsibilities**:
- Store application data
- Execute SQL queries
- Maintain data integrity
- Handle transactions

**Configuration**:
- Version: MariaDB 10.11
- Port: 3306
- Character Set: utf8mb4
- Collation: utf8mb4_unicode_ci

**Data**:
- Database: `dolibarr`
- User: `dolibarr`
- Tables: 200+ (llx_* prefix)

**Flow**:
```
PHP-FPM → MariaDB :3306
   ├─ Execute query
   ├─ Return results
   └─ Commit/rollback transaction
```

## Data Flow

### HTTP Request Flow

```
1. Browser → http://localhost:8080/admin/company.php

2. Host :8080 → Docker web:80

3. Nginx receives request
   ├─ Match location ~ \.php
   └─ Forward to app:9000 via FastCGI

4. PHP-FPM processes script
   ├─ Load /var/www/html/admin/company.php
   ├─ Query database: SELECT * FROM llx_const
   └─ Generate HTML response

5. PHP-FPM → Nginx
   └─ HTML content

6. Nginx → Browser
   └─ HTTP 200 OK + HTML

7. Browser renders page
```

### File Upload Flow

```
1. User uploads document via browser

2. Nginx receives POST request
   ├─ Check client_max_body_size
   └─ Forward to PHP-FPM

3. PHP-FPM processes upload
   ├─ Validate file
   ├─ Move to /var/www/html/documents/
   ├─ Insert record in llx_ecm_files
   └─ Return success

4. File stored in dolibarr_documents volume
```

### Database Query Flow

```
1. PHP executes: $db->query("SELECT * FROM llx_user")

2. PHP mysqli extension
   └─ Connect to db:3306

3. MariaDB processes query
   ├─ Parse SQL
   ├─ Execute on llx_user table
   ├─ Fetch results
   └─ Return dataset

4. PHP receives results
   └─ Process and display
```

## Network Architecture

### Docker Networks

```
docker-deploy_default (bridge network)
├─ web (nginx)       - 172.18.0.2
├─ app (php-fpm)     - 172.18.0.3
└─ db (mariadb)      - 172.18.0.4
```

**Communication**:
- `web` → `app`: Via service name `app` (port 9000)
- `app` → `db`: Via service name `db` (port 3306)
- Host → `web`: Via localhost:8080

**DNS Resolution**:
- Docker provides internal DNS
- Service names resolve to container IPs
- Example: `db` resolves to `172.18.0.4`

## Storage Architecture

### Volumes

#### 1. mariadb_data (Named Volume)
```
Location: Managed by Docker
Purpose: Database files
Persistence: Survives container restarts
Backup: Use mysqldump
```

#### 2. dolibarr_documents (Named Volume)
```
Location: Managed by Docker
Purpose: Uploaded files, generated PDFs
Persistence: Survives container restarts
Backup: Use tar or docker volume backup
```

#### 3. ../htdocs (Bind Mount)
```
Host: /workspaces/dolibarr/htdocs
Container: /var/www/html
Purpose: Application code
Editable: Yes (live changes)
```

### Directory Structure in Container

```
/var/www/html/                 (htdocs - bind mount)
├── index.php                  (main entry point)
├── admin/                     (administration)
├── core/                      (core libraries)
├── conf/                      (configuration)
│   ├── conf.php              (main config - created by installer)
│   └── conf.php.example      (template)
├── documents/                 (files - docker volume)
│   ├── admin/                (admin docs)
│   ├── societe/              (company docs)
│   └── install.lock          (prevents reinstall)
├── includes/                  (external libraries)
├── langs/                     (translations)
└── theme/                     (UI themes)
```

## Security Architecture

### Network Security

**Exposed Ports**:
- ✅ 8080 (HTTP) - Nginx
- ⚠️ 3306 (MySQL) - MariaDB (optional, can be removed)

**Internal Ports** (not exposed):
- 9000 - PHP-FPM (only accessible from Nginx)

### File System Security

**Nginx Protection**:
```nginx
location ~ ^/conf(/|$) {
    deny all;  # Block /conf access
}

location ~ /\.ht {
    deny all;  # Block .htaccess files
}
```

**User Isolation**:
- PHP-FPM runs as `dolibarr` user (UID 1000)
- Not root (principle of least privilege)

**File Permissions**:
- conf/ - Writable by dolibarr user
- documents/ - Writable by dolibarr user
- Other files - Read-only

### Application Security

**Database**:
- Separate application user (`dolibarr`)
- Limited privileges (not root)
- Strong password (change in production)

**Configuration**:
- conf.php contains sensitive data
- Protected by Nginx (not web-accessible)
- Should have restricted permissions

## Scalability Architecture

### Horizontal Scaling (Future)

```
                  ┌─────────────┐
                  │ Load Balancer│
                  └──────┬───────┘
                         │
         ┌───────────────┼───────────────┐
         │               │               │
    ┌────▼────┐    ┌────▼────┐    ┌────▼────┐
    │ Nginx+  │    │ Nginx+  │    │ Nginx+  │
    │ PHP-FPM │    │ PHP-FPM │    │ PHP-FPM │
    └────┬────┘    └────┬────┘    └────┬────┘
         │               │               │
         └───────────────┼───────────────┘
                         │
                  ┌──────▼────────┐
                  │  MariaDB      │
                  │  (Primary)    │
                  └───────────────┘
                         │
                  ┌──────▼────────┐
                  │  MariaDB      │
                  │  (Replica)    │
                  └───────────────┘
```

**Requirements**:
- Shared storage for documents (NFS, S3)
- Session storage in Redis/Memcached
- Database replication
- Load balancer (Nginx, HAProxy)

### Vertical Scaling (Current)

**Increase Resources**:
```yaml
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
```

**Tune PHP-FPM**:
```ini
pm.max_children = 50
pm.start_servers = 10
pm.min_spare_servers = 5
pm.max_spare_servers = 20
```

**Tune MariaDB**:
```yaml
db:
  command: >
    --innodb_buffer_pool_size=2G
    --max_connections=200
```

## Deployment Models

### Development (Current)
```
Single host
├── All containers on one machine
├── Bind mounts for live code editing
└── Port forwarding for access
```

### Production (Recommended)
```
Single host
├── All containers on one server
├── SSL/TLS termination
├── Volumes for data
├── No bind mounts (immutable)
└── Automated backups
```

### High Availability
```
Multiple hosts
├── Load-balanced web/app tier
├── Replicated database
├── Shared storage (NFS/S3)
├── Redis for sessions
└── Monitoring and alerting
```

## Monitoring Architecture

### Container Monitoring
```bash
docker stats  # Real-time stats
```

### Application Logs
```
Nginx: /var/log/nginx/
PHP-FPM: Docker logs
MariaDB: /var/log/mysql/
```

### Health Checks (Optional)
```yaml
services:
  app:
    healthcheck:
      test: ["CMD", "php-fpm-healthcheck"]
      interval: 30s
      timeout: 3s
      retries: 3
```

## Backup Architecture

### What to Backup
1. **Database** (mariadb_data volume)
2. **Documents** (dolibarr_documents volume)
3. **Configuration** (conf/conf.php)

### Backup Strategy
```
Daily:
├── Database dump (mysqldump)
├── Documents snapshot
└── Configuration backup

Weekly:
└── Full system backup

Monthly:
└── Archive to cold storage
```

## Configuration Management

### Environment Variables (docker-compose.yml)
```yaml
environment:
  - MYSQL_DATABASE=dolibarr
  - MYSQL_USER=dolibarr
  - MYSQL_PASSWORD=dolibarrpass
```

### Configuration Files
- **docker-compose.yml** - Service orchestration
- **Dockerfile** - PHP image build
- **nginx.conf** - Web server config
- **conf.php** - Dolibarr application config

### Secrets (Production)
```yaml
secrets:
  db_password:
    external: true
```

---

**See Also**:
- [System Requirements](system-requirements.md)
- [Docker Commands](01-docker-commands.md)
- [PHP Configuration](02-php-configuration.md)
- [Nginx Configuration](03-nginx-configuration.md)
- [MariaDB Configuration](04-mariadb-configuration.md)
