#!/bin/bash
# Kill Hanging Processes Script
# Quick recovery tool for frozen terminals and processes

set -Eeuo pipefail

DRY_RUN=false
AUTO_YES=false

confirm() {
    local prompt="$1"; local response
    if $AUTO_YES; then echo "$prompt (auto-yes)"; return 0; fi
    read -p "$prompt (y/N): " response
    [[ $response =~ ^[Yy]$ ]]
}

while (( "$#" )); do
    case "$1" in
        -y|--yes) AUTO_YES=true; shift;;
        -n|--dry-run) DRY_RUN=true; shift;;
        -h|--help)
            echo "Usage: $0 [option] [--yes|-y] [--dry-run|-n]"; exit 0;;
        *) break;;
    esac
done

echo "🔍 Checking for hanging processes..."

# Function to kill hanging browser processes
kill_browsers() {
    echo "🌐 Checking for hanging network download processes (curl/wget)..."
    # Safer filter: only curl/wget, exclude our own script
    local pids
    pids=$(ps -eo pid,comm | awk '$2=="curl" || $2=="wget" {print $1}')
    if [ -n "${pids}" ]; then
        echo "Found processes: ${pids}"
        if confirm "Kill these processes?"; then
            if $DRY_RUN; then echo "+ kill -9 ${pids}"; else kill -9 ${pids}; fi
            echo "✅ Killed network download processes"
        else
            echo "Skipped killing network processes"
        fi
    else
        echo "✅ No hanging curl/wget processes found"
    fi
}

# Function to show and optionally kill terminal processes
kill_terminals() {
    echo "🖥️  Current terminal processes:"
    ps aux | grep -E "(bash|sh)" | grep pts | head -5
    
    echo ""
    if confirm "Kill hanging terminal processes?"; then
        # Kill only hung terminals (status S+ or similar)
        HUNG_TERMS=$(ps -eo pid,stat,comm,tty | awk '$3 ~ /^(bash|sh)$/ && $2 ~ /S\+/ {print $1}')
        if [ -n "$HUNG_TERMS" ]; then
            echo "Killing hung terminals: $HUNG_TERMS"
            if $DRY_RUN; then echo "+ kill -9 $HUNG_TERMS"; else kill -9 $HUNG_TERMS; fi
            echo "✅ Killed hung terminal processes"
        else
            echo "✅ No hung terminals found"
        fi
    fi
}

# Function to check background jobs
check_jobs() {
    echo "📋 Background jobs in current shell:"
    jobs -l || echo "No background jobs"
}

# Function to quick process check
quick_check() {
    echo "⚡ Quick process health check:"
    echo "Memory usage: $(free -h | grep Mem: | awk '{print $3"/"$2}')"
    echo "Load average: $(uptime | awk -F'load average:' '{print $2}')"
    echo "Active processes: $(ps aux | wc -l)"
}

# Main menu
case "$1" in
    "browser"|"b")
        kill_browsers
        ;;
    "terminal"|"t")
        kill_terminals
        ;;
    "jobs"|"j")
        check_jobs
        ;;
    "quick"|"q")
        quick_check
        ;;
    "all"|"a")
        kill_browsers
        check_jobs
        quick_check
        ;;
    *)
        echo "🚨 Kill Hanging Processes Tool"
        echo ""
    echo "Usage: $0 [option] [--yes|-y] [--dry-run|-n]"
        echo ""
        echo "Options:"
        echo "  browser, b    - Kill hanging browser processes"
        echo "  terminal, t   - Show/kill hanging terminal processes"
        echo "  jobs, j       - Check background jobs"
        echo "  quick, q      - Quick system health check"
        echo "  all, a        - Run all checks"
        echo ""
        echo "Quick commands:"
        echo "  ./kill_hanging.sh b     # Kill browsers"
        echo "  ./kill_hanging.sh a     # Full check"
        echo ""
        echo "Running automatic browser cleanup..."
        kill_browsers
        ;;
esac