#!/bin/bash
# Quick workflow commands for chemical manufacturing project

# Session context loader
session_context() {
    echo "=== CHEMICAL MANUFACTURING DOLIBARR PROJECT ==="
    echo "Current Date: $(date)"
    echo "Project Phase: Installation Wizard"
    echo ""
    
    echo "=== CONTAINER STATUS ==="
    docker compose ps 2>/dev/null || echo "Containers not running - use ./daily_start.sh"
    echo ""
    
    echo "=== CURRENT FILES ==="
    echo "Session Context: session-context.md"
    echo "Company Config: chemical-company-config.md" 
    echo "Implementation Guide: chemical-implementation-guide.md"
    echo "Product Templates: chemical-products-import.csv"
    echo ""
    
    echo "=== QUICK ACCESS ==="
    echo "Dolibarr URL: https://mysterious-shadow-v67rgqjgp56xfx95p-8080.app.github.dev"
    echo "Install URL: https://mysterious-shadow-v67rgqjgp56xfx95p-8080.app.github.dev/install/"
    echo ""
    
    echo "=== TODO STATUS ==="
    grep -E "^\- \[.\]" /workspaces/dolibarr/session-context.md 2>/dev/null || echo "Check session-context.md for current status"
}

# Update session status
update_status() {
    local task="$1"
    local status="$2"  # completed, in-progress, blocked
    
    echo "Updated: $task -> $status at $(date)" >> /workspaces/dolibarr/session-log.txt
}

# Backup current work
quick_backup() {
    cd /workspaces/dolibarr/docker-deploy
    ./backup_dolibarr.sh
    echo "Backup completed at $(date)" >> /workspaces/dolibarr/session-log.txt
}

# Show current context
alias ctx='session_context'
alias status='session_context'
alias backup='quick_backup'

echo "Chemical Manufacturing Dolibarr Workflow Commands Loaded"
echo "Commands: ctx, status, backup, update_status"