#!/bin/bash
#health-report.sh - System health report generator
#Usage: ./health-report.sh [output-file]

set -euo pipefail

REPORT_FILE="${1:-/home/$(whoami)/projects/phase1/logs/health-$(date +%Y%m%d-%H%M).log}"
ALERT_THRESHOLD_DISK=85
ALERT_THRESHOLD_MEM=90

log() { echo "[$(date '+%H:%M:%S')] $1" | tee -a "$REPORT_FILE"; }
alert() { echo "[$(date '+%H:%M:%S')] ALERT: $1" | tee -a "$REPORT_FILE"; }

mkdir -p "$(dirname "$REPORT_FILE")"

log "============================================"
log "HEALTH REPORT -- $(hostname -f)"
log "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
log "Uptime: $(uptime -p)"
log "============================================"

# CPU Load
LOAD_1=$(cat /proc/loadavg | awk '{print $1}')
CPUS=$(nproc)
log "CPU: load=$LOAD_1 Cores=$CPUS"

# Memory
MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
MEM_AVAIL=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
MEM_USED=$((MEM_TOTAL - MEM_AVAIL))
MEM_PCT=$((MEM_USED * 100 / MEM_TOTAL))
log "MEM: ${MEM_PCT}% used  ($(( MEM_USED/1024 ))MB / $(( MEM_TOTAL/1024 ))MB)"
[[ $MEM_PCT -gt $ALERT_THRESHOLD_MEM ]] && alert "Memory ${MEM_PCT}% used!"

# Disk
DISK_PCT=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
DISK_INFO=$(df -h / | tail -1 | awk '{print $3"/"$2}')
log "DISK /: ${DISK_PCT}% used ($DISK_INFO)"
[[ $DISK_PCT -gt $ALERT_THRESHOLD_DISK ]] && alert "Disk ${DISK_PCT}% full!"

# Top 5 processes
log "TOP PROCESSES (CPU):"
ps aux --sort=-%cpu | awk 'NR>1 && NR<=6 {printf "  %-8s %-20s CPU:%-6s MEM:%s\n", $2, $11, $3, $4}' | tee -a "$REPORT_FILE"

# Listening ports
log "LISTENING PORTS:"
ss -tulpn | grep LISTEN | awk '{print "  " $5}' | tee -a "$REPORT_FILE"

log "============================================"
log "Report saved to: $REPORT_FILE"
