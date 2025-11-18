#!/bin/bash
# Stop Keep-Alive Script
# Gracefully stops the background keep-alive process

set -Eeuo pipefail

PID_FILE="/tmp/keep_alive.pid"
LOG_FILE="/tmp/keep_alive.log"

if [ ! -f "$PID_FILE" ]; then
    echo "Keep-alive not running (no PID file found)"
    exit 0
fi

PID=$(cat "$PID_FILE")

if ps -p "$PID" >/dev/null 2>&1; then
    echo "Stopping keep-alive (PID: $PID)..."
    kill "$PID" 2>/dev/null || true
    
    # Wait for process to stop
    for i in {1..5}; do
        if ! ps -p "$PID" >/dev/null 2>&1; then
            break
        fi
        sleep 1
    done
    
    # Force kill if still running
    if ps -p "$PID" >/dev/null 2>&1; then
        echo "Force stopping keep-alive..."
        kill -9 "$PID" 2>/dev/null || true
    fi
    
    rm -f "$PID_FILE"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] Keep-alive stopped" >> "$LOG_FILE"
    echo "✅ Keep-alive stopped successfully"
else
    echo "Keep-alive process (PID: $PID) not found - cleaning up PID file"
    rm -f "$PID_FILE"
fi
