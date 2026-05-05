#!/bin/bash
set -euo pipefail

DATE=$(date '+%Y-%m-%d')
REPORT="$HOME/projects/vps/logs/log-analysis-${DATE}.txt"
ACCESS_LOG="/var/log/nginx/access.log"

log() { echo "$1" | tee -a "$REPORT"; }

log "=== LOG ANALYSIS REPORT: $DATE ==="
log ""

log "--- NGINX REQUEST SUMMARY ---"
log "Total requests today:"
grep $(date '+%d/%b/%Y') "$ACCESS_LOG" | wc -l | tee -a "$REPORT"

log "Top 5 IPs:"
awk '{print $1}' "$ACCESS_LOG" | sort | uniq -c | sort -rn | head -5 | tee -a "$REPORT"

log "HTTP Status breakdown:"
awk '{print $9}' "$ACCESS_LOG" | sort | uniq -c | sort -rn | tee -a "$REPORT"

log ""
log "--- AUTH LOG SUMMARY ---"
log "Failed SSH attempts in last 24h:"
TODAY=$(date '+%b %e' | tr -s ' ')
grep 'Failed password' /var/log/auth.log | grep "$TODAY" | wc -l | tee -a "$REPORT"

log "=== END REPORT ==="
