#!/bin/bash
# watchdog.sh - Service monitor and auto restart
# Usage: ./watchdog.sh [interval_seconds]
# Edit SERVICES array to monitor different services

set -uo pipefail

INTERVAL="${1:-30}"
LOG="/home/$(whoami)/projects/phase1/logs/watchdog.log"
SERVICES=("nginx" "ssh" "cron")
RESTART_COUNT=0
CHECK_COUNT=0

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"; }

check_service() {
    local service="$1"
    systemctl is-active --quiet "$service"
}

restart_service() {
    local service="$1"
    log "ALERT: $service is DOWN -- attempting restart..."
    if sudo systemctl restart "$service"; then
        log "OK: $service restarted successfully"
        (( RESTART_COUNT++ )) || true
    else
        log "CRITICAL: Failed to restart $service!"
    fi
}

trap 'log "=== WATCHDOG STOPPED (checks: $CHECK_COUNT, restarts: $RESTART_COUNT) ==="' EXIT

log "=== WATCHDOG STARTED ==="
log "Monitoring: ${SERVICES[*]}"
log "Check interval: ${INTERVAL}s -- Ctrl+C to stop"

while true; do
    (( CHECK_COUNT++ )) || true
    log "--- Check #$CHECK_COUNT ---"
    for service in "${SERVICES[@]}"; do
        if check_service "$service"; then
            log "  OK: $service is running"
        else
            restart_service "$service"
        fi
    done
    sleep "$INTERVAL"
done
