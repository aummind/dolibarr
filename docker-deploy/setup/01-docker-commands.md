# Docker Commands Reference

## Overview
This guide explains all Docker Compose commands used to manage the Dolibarr deployment, when to use each command, and what they do.

## Command Formats

### Short Format (from docker-deploy directory)
```bash
cd /workspaces/dolibarr/docker-deploy
docker compose COMMAND
```

### Full Path Format (from anywhere)
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml COMMAND
```

**Note**: Both formats do the same thing. Use full path when working from different directories or in scripts.

## Starting Commands

### docker compose up -d

**When to use**: 
- First time starting the services
- After running `docker compose down`
- After Codespace restart/resume
- After making changes to docker-compose.yml

**What it does**:
- Creates containers if they don't exist
- Starts stopped containers
- Recreates containers if configuration changed
- `-d` flag runs in detached mode (background)

**Examples**:
```bash
# From docker-deploy directory
docker compose up -d

# From anywhere
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml up -d

# Start specific service
docker compose up -d app

# View startup logs
docker compose up
```

**Use this command**: ✅ After Codespace resumes, after `down`, for first start

---

### docker compose start

**When to use**:
- Containers exist but are stopped
- After running `docker compose stop`
- When you want a faster start

**What it does**:
- Only starts existing stopped containers
- Does NOT recreate or rebuild
- Faster than `up` but doesn't apply config changes

**Examples**:
```bash
docker compose start
docker compose start app web
```

**Use this command**: ⚠️ Only if containers exist and are stopped

---

### docker compose restart

**When to use**:
- Containers are running but need restart
- After editing PHP config files
- To apply minor changes without full restart

**What it does**:
- Restarts running containers in place
- Quick operation
- Useful for configuration reloads

**Examples**:
```bash
# Restart all services
docker compose restart

# Restart specific service
docker compose restart app

# Restart with timeout
docker compose restart -t 30 app
```

**Use this command**: ✅ For quick restarts when containers are already running

---

## Stopping Commands

### docker compose stop

**When to use**:
- Temporarily pause services
- Keep containers for quick restart
- Save system resources

**What it does**:
- Stops containers gracefully
- Keeps containers (not removed)
- Fast to start again with `docker compose start`
- Data and state preserved

**Examples**:
```bash
# Stop all services
docker compose stop

# Stop specific service
docker compose stop app

# Stop with timeout
docker compose stop -t 10
```

**Use this command**: ✅ Temporary pause, planning to resume soon

---

### docker compose down

**When to use**:
- Done working, shutting down Codespace
- Before rebuilding containers
- Cleaning up for fresh start (keeps data)

**What it does**:
- Stops all containers
- Removes containers
- Removes networks
- **Keeps volumes** (database and files persist)
- Use `up -d` to start again

**Examples**:
```bash
# Stop and remove containers
docker compose down

# Also remove orphaned containers
docker compose down --remove-orphans

# Remove specific volumes (careful!)
docker compose down -v
```

**Use this command**: ✅ End of work session, before rebuild

---

### docker compose down -v

**⚠️ DANGER**: This deletes ALL data!

**When to use**:
- Complete reset needed
- Fresh install required
- Troubleshooting data corruption

**What it does**:
- Stops and removes containers
- Removes networks
- **REMOVES VOLUMES** (deletes database and documents!)
- Cannot undo - data is lost

**Examples**:
```bash
# Nuclear option - deletes everything
docker compose down -v

# Remove specific volumes
docker compose down
docker volume rm docker-deploy_mariadb_data
```

**Use this command**: ⚠️ ONLY for complete fresh start

---

## Monitoring Commands

### docker compose ps

**What it does**: Shows status of all services

**Examples**:
```bash
# Show all services
docker compose ps

# Show all including stopped
docker compose ps -a

# Show specific service
docker compose ps app
```

**Output**:
```
NAME                  IMAGE                 STATUS
docker-deploy-app-1   docker-deploy-app     Up 5 minutes
docker-deploy-db-1    mariadb:10.11         Up 5 minutes
docker-deploy-web-1   nginx:stable-alpine   Up 5 minutes
```

---

### docker compose logs

**What it does**: Shows service logs

**Examples**:
```bash
# Follow all logs
docker compose logs -f

# Follow specific service
docker compose logs -f app

# Last 50 lines
docker compose logs --tail=50 app

# Since specific time
docker compose logs --since 30m app

# Timestamps
docker compose logs -f -t app
```

---

### docker compose exec

**What it does**: Execute commands inside running containers

**Examples**:
```bash
# Open bash shell in app container
docker compose exec app bash

# Run PHP command
docker compose exec app php -v

# Check PHP extensions
docker compose exec app php -m

# Database shell
docker compose exec db mysql -u dolibarr -pdoblibarrpass dolibarr

# Nginx shell (Alpine uses sh)
docker compose exec web sh
```

---

## Building Commands

### docker compose build

**When to use**:
- After changing Dockerfile
- After adding PHP extensions
- First time setup

**What it does**:
- Builds Docker images from Dockerfile
- Can use cache for faster builds
- `--no-cache` forces complete rebuild

**Examples**:
```bash
# Build all services
docker compose build

# Build without cache (clean build)
docker compose build --no-cache

# Build specific service
docker compose build app

# Build and start
docker compose up -d --build
```

---

## Advanced Commands

### docker compose pull

**What it does**: Pull latest versions of base images (nginx, mariadb)

```bash
docker compose pull
```

---

### docker compose top

**What it does**: Show running processes in containers

```bash
docker compose top
```

---

### docker compose config

**What it does**: Validate and view docker-compose.yml

```bash
# Validate configuration
docker compose config

# Show full merged config
docker compose config --services
```

---

## Recommended Workflows

### Daily Start (After Codespace Resume)
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml up -d
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml ps
```

### Daily End (Shutdown)
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml down
```

### After Dockerfile Changes
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml build --no-cache app
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml up -d
```

### Check Status and Logs
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml ps
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml logs -f app
```

### Troubleshooting - Full Restart
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml down
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml up -d
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml logs -f
```

### Complete Reset (Deletes Data!)
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml down -v
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml build --no-cache
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml up -d
```

---

## Command Comparison

| Command | Containers | Networks | Volumes | Config Changes | Speed |
|---------|-----------|----------|---------|----------------|-------|
| `up -d` | Create/Start | Create | Keep | Apply | Medium |
| `start` | Start | Keep | Keep | Ignore | Fast |
| `restart` | Restart | Keep | Keep | Ignore | Fast |
| `stop` | Stop | Keep | Keep | N/A | Fast |
| `down` | Remove | Remove | Keep | N/A | Fast |
| `down -v` | Remove | Remove | **DELETE** | N/A | Fast |

---

## Common Patterns

### First Time Setup
```bash
cd /workspaces/dolibarr/docker-deploy
docker compose build
docker compose up -d
docker compose logs -f
```

### After Codespace Pause/Resume
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml up -d
```

### View Service Status
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml ps
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml logs --tail=20 app
```

### Restart Single Service
```bash
docker compose -f /workspaces/dolibarr/docker-deploy/docker-compose.yml restart app
```

---

## Tips

1. **Always use `-d` flag with `up`** for detached mode (runs in background)
2. **Use full paths in scripts** to avoid directory dependency
3. **Check logs with `-f`** to follow real-time output
4. **Use `ps` frequently** to verify services are running
5. **Avoid `down -v`** unless you truly want to delete all data

---

**See Also**:
- [PHP Configuration](02-php-configuration.md)
- [Troubleshooting](06-troubleshooting.md)
- [Architecture](architecture.md)
