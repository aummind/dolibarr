# MariaDB Configuration

## Overview
MariaDB serves as the database backend for Dolibarr, providing MySQL-compatible database services.

## Database Version
- **Image**: `mariadb:10.11`
- **Type**: MySQL-compatible relational database
- **Character Set**: UTF-8 (utf8mb4)

## Configuration

### Database Credentials
| Parameter | Value | Purpose |
|-----------|-------|---------|
| Root Password | `rootpassword` | Database admin access |
| Database Name | `dolibarr` | Dolibarr application database |
| Database User | `dolibarr` | Application database user |
| Database Password | `dolibarrpass` | Application user password |

**⚠️ Security Note**: Change these credentials for production use!

### Character Set Configuration
```yaml
command: --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
```

| Setting | Value | Purpose |
|---------|-------|---------|
| `character-set-server` | `utf8mb4` | Full UTF-8 support (includes emojis) |
| `collation-server` | `utf8mb4_unicode_ci` | Case-insensitive Unicode collation |

**Why utf8mb4?**
- Full Unicode support (4-byte characters)
- Supports international characters and emojis
- Recommended for modern applications

## Port Mapping

```yaml
ports:
  - "3306:3306"
```

| Location | Port | Access |
|----------|------|--------|
| Host | 3306 | External access for tools |
| Container | 3306 | Standard MySQL port |

**Security Note**: In production, remove port mapping to prevent external access.

## Data Persistence

### Volume Configuration
```yaml
volumes:
  - mariadb_data:/var/lib/mysql
```

| Volume | Container Path | Purpose |
|--------|---------------|---------|
| `mariadb_data` | `/var/lib/mysql` | Persistent database storage |

**Data Safety**: 
- Data persists across container restarts
- Survives `docker compose down`
- Only deleted with `docker compose down -v`

## Database Operations

### Accessing MySQL CLI

#### Interactive Shell
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysql -u dolibarr -pdolibarrpass dolibarr
```

#### As Root User
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysql -u root -prootpassword
```

#### Single Command
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysql -u dolibarr -pdolibarrpass dolibarr -e "SHOW TABLES;"
```

### Database Backup

#### Full Database Backup
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysqldump -u dolibarr -pdoblibarrpass dolibarr > dolibarr_backup_$(date +%Y%m%d).sql
```

#### With gzip Compression
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysqldump -u dolibarr -pdoblibarrpass dolibarr | gzip > dolibarr_backup_$(date +%Y%m%d).sql.gz
```

#### Specific Tables Only
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysqldump -u dolibarr -pdoblibarrpass dolibarr llx_user llx_societe > users_companies_backup.sql
```

### Database Restore

#### From SQL File
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec -T db mysql -u dolibarr -pdoblibarrpass dolibarr < dolibarr_backup.sql
```

#### From Compressed File
```bash
gunzip < dolibarr_backup.sql.gz | docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec -T db mysql -u dolibarr -pdoblibarrpass dolibarr
```

### Database Monitoring

#### Check Database Status
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysqladmin -u root -prootpassword status
```

#### Show Databases
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysql -u root -prootpassword -e "SHOW DATABASES;"
```

#### Show Tables in Dolibarr Database
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysql -u dolibarr -pdoblibarrpass dolibarr -e "SHOW TABLES;"
```

#### Check Table Status
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysql -u dolibarr -pdoblibarrpass dolibarr -e "SHOW TABLE STATUS;"
```

#### Database Size
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysql -u dolibarr -pdoblibarrpass dolibarr -e "
SELECT 
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.tables
WHERE table_schema = 'dolibarr'
GROUP BY table_schema;
"
```

## Testing Database Connection

### From PHP Container
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec app php -r "
\$conn = new mysqli('db', 'dolibarr', 'dolibarrpass', 'dolibarr');
if (\$conn->connect_error) {
    die('Connection failed: ' . \$conn->connect_error);
}
echo 'Database connection: OK' . PHP_EOL;
echo 'Server version: ' . \$conn->server_info . PHP_EOL;
\$conn->close();
"
```

### From Host (if port exposed)
```bash
mysql -h 127.0.0.1 -P 3306 -u dolibarr -pdoblibarrpass dolibarr
```

### Test with mysqladmin
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysqladmin -h db -u dolibarr -pdoblibarrpass ping
```

Expected: `mysqld is alive`

## Common Database Queries

### User Management

#### Show Current Users
```sql
SELECT User, Host FROM mysql.user;
```

#### Show User Privileges
```sql
SHOW GRANTS FOR 'dolibarr'@'%';
```

#### Create New User
```sql
CREATE USER 'newuser'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON dolibarr.* TO 'newuser'@'%';
FLUSH PRIVILEGES;
```

### Database Information

#### Show Dolibarr Tables
```sql
USE dolibarr;
SHOW TABLES;
```

#### Count Rows in Tables
```sql
SELECT 
    TABLE_NAME,
    TABLE_ROWS
FROM information_schema.tables
WHERE TABLE_SCHEMA = 'dolibarr'
ORDER BY TABLE_ROWS DESC;
```

#### Show Table Structure
```sql
DESCRIBE llx_user;
```

### Performance Queries

#### Show Running Queries
```sql
SHOW FULL PROCESSLIST;
```

#### Show Database Variables
```sql
SHOW VARIABLES LIKE '%max_connections%';
SHOW VARIABLES LIKE '%buffer%';
```

#### Check InnoDB Status
```sql
SHOW ENGINE INNODB STATUS\G
```

## Database Logs

### View MariaDB Container Logs
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml logs -f db
```

### Check Error Log Inside Container
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db cat /var/log/mysql/error.log
```

### Enable Query Log (Development Only)
```sql
SET GLOBAL general_log = 'ON';
SET GLOBAL general_log_file = '/var/log/mysql/query.log';
```

## Troubleshooting

### Issue: Can't Connect to Database
**Check if MariaDB is running**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml ps db
```

**Check logs**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml logs db | tail -50
```

**Test connection**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysqladmin ping
```

### Issue: Access Denied for User
**Verify credentials**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysql -u dolibarr -pdoblibarrpass dolibarr -e "SELECT 1;"
```

**Check user exists**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysql -u root -prootpassword -e "SELECT User, Host FROM mysql.user WHERE User='dolibarr';"
```

### Issue: Database Not Found
**List databases**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysql -u root -prootpassword -e "SHOW DATABASES;"
```

**Create database manually**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysql -u root -prootpassword -e "CREATE DATABASE dolibarr CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

### Issue: Out of Disk Space
**Check volume size**:
```bash
docker system df -v
```

**Check database size**:
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db du -sh /var/lib/mysql
```

### Issue: Slow Queries
**Enable slow query log**:
```sql
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2;
SET GLOBAL slow_query_log_file = '/var/log/mysql/slow.log';
```

**View slow queries**:
```bash
docker compose exec db cat /var/log/mysql/slow.log
```

## Performance Tuning

### Adjust Buffer Pool Size
For production, add to docker-compose.yml:
```yaml
db:
  command: >
    --character-set-server=utf8mb4
    --collation-server=utf8mb4_unicode_ci
    --innodb_buffer_pool_size=1G
    --innodb_log_file_size=256M
```

### Connection Limits
```yaml
db:
  command: >
    --max_connections=200
    --connect_timeout=10
```

### Query Cache (MySQL 5.x only)
```yaml
db:
  command: >
    --query_cache_size=32M
    --query_cache_type=1
```

## Security Best Practices

### 1. Change Default Passwords
Edit docker-compose.yml:
```yaml
environment:
  MYSQL_ROOT_PASSWORD: your_secure_root_password
  MYSQL_PASSWORD: your_secure_app_password
```

### 2. Restrict Database User Privileges
```sql
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER 
ON dolibarr.* 
TO 'dolibarr'@'%';
```

### 3. Remove Port Exposure (Production)
Remove from docker-compose.yml:
```yaml
# ports:
#   - "3306:3306"
```

### 4. Use Docker Secrets
Instead of environment variables, use Docker secrets for credentials.

### 5. Regular Backups
Set up automated backup cron job:
```bash
0 2 * * * docker compose -f /path/to/docker-compose.yml exec db mysqldump -u dolibarr -p... dolibarr > /backups/dolibarr_$(date +\%Y\%m\%d).sql
```

## Maintenance

### Optimize Tables
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysqlcheck -u root -prootpassword --optimize dolibarr
```

### Repair Tables
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysqlcheck -u root -prootpassword --repair dolibarr
```

### Analyze Tables
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysqlcheck -u root -prootpassword --analyze dolibarr
```

### Check Tables
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml exec db mysqlcheck -u root -prootpassword --check dolibarr
```

## Upgrading MariaDB

1. **Backup database first**:
```bash
docker compose exec db mysqldump -u root -prootpassword --all-databases > full_backup.sql
```

2. **Update docker-compose.yml**:
```yaml
db:
  image: mariadb:10.12  # or newer version
```

3. **Recreate container**:
```bash
docker compose down
docker compose up -d
```

4. **Run upgrade**:
```bash
docker compose exec db mysql_upgrade -u root -prootpassword
```

## Reference

- **MariaDB Documentation**: https://mariadb.org/documentation/
- **MariaDB Docker Hub**: https://hub.docker.com/_/mariadb
- **MySQL Command Reference**: https://dev.mysql.com/doc/refman/8.0/en/

---

**See Also**:
- [Docker Commands](01-docker-commands.md)
- [PHP Configuration](02-php-configuration.md)
- [Dolibarr Installation](05-dolibarr-installation.md)
- [Troubleshooting](06-troubleshooting.md)
