#!/bin/bash
# Keep Codespace Alive Script
# Prevents auto-suspension during long configuration sessions
# Aggressive approach: visible terminal activity + CPU usage

set -Eeuo pipefail

# Configuration
INTERVAL=${1:-30}  # Every 30 seconds (more aggressive)
LOG_FILE="/tmp/keep_alive.log"
PID_FILE="/tmp/keep_alive.pid"

# Check if already running
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if ps -p "$OLD_PID" >/dev/null 2>&1; then
        echo "Keep-alive already running (PID: $OLD_PID)"
        exit 0
    fi
fi

# Save PID
echo $$ > "$PID_FILE"

# Initialize log
echo "[$(date +'%Y-%m-%d %H:%M:%S')] Keep-alive started (PID: $$, interval: ${INTERVAL}s)" > "$LOG_FILE"

# Background loop with multiple activity signals
while true; do
    # Generate visible terminal activity
    echo -ne "." >> "$LOG_FILE"
    
    # CPU activity - multiple operations
    docker ps >/dev/null 2>&1 || true
    docker stats --no-stream >/dev/null 2>&1 || true
    ps aux >/dev/null 2>&1 || true
    df -h >/dev/null 2>&1 || true
    
    # Network activity simulation
    curl -s http://localhost:8080 >/dev/null 2>&1 || true
    
    # File system activity
    touch /tmp/keep_alive_heartbeat
    cat /proc/uptime > /tmp/keep_alive_uptime
    
    # Log periodic status
    if [ $(($(date +%s) % 300)) -lt "$INTERVAL" ]; then
        echo "" >> "$LOG_FILE"
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] Active - Containers: $(docker ps -q | wc -l), Uptime: $(cat /proc/uptime | cut -d' ' -f1)s" >> "$LOG_FILE"
    fi
    
    sleep "$INTERVAL"
done
