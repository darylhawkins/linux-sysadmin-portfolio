#!/bin/bash
# network-audit.sh — Network security audit report
# Usage: sudo ./network-audit.sh
set -uo pipefail

REPORT="/home/daryl/projects/phase1/logs/network-audit-$(date +%y%m%d).txt"
log() { echo "$1" | tee -a "$REPORT";}
sep() { log "--------------------------------------------------"; }

mkdir -p "$(dirname "$REPORT")"
> "$REPORT"

log "=================================================="
log "       NETWORK SECURITY AUDIT REPORT"
log "  Host: $(hostname -f)"
log "  Date: $(date '+%Y-%m-%d %H:%M:%S')"
log "=================================================="
log ""

log "[ NETWORK INTERFACES ]"
sep
ip -o addr show | awk '{print "  " $2 ": " $4}' | tee -a "$REPORT"
log ""

log "[ ROUTING TABLE ]"
sep
ip route | awk '{print "  " $0}' | tee -a "$REPORT"
log ""

log "[ DNS CONFIGURATION ]"
sep
grep "^nameserver" /etc/resolv.conf | awk '{print "  " $0}' | tee -a "$REPORT"
log ""

log "[ LISTENING SERVICES ]"
sep
log "  Port       Proto  Process"
ss -tulpn | grep LISTEN | awk '{
    split($5,a,":")
    port=a[length(a)]
    proto=$1
    proc=$7
    gsub(/users:\(\("/,"",proc)
    gsub(/".*/,"",proc)
    printf "  %-10s %-7s %s\n", port, proto, proc
}' | sort -n | tee -a "$REPORT"
log ""

log "[ ESTABLISHED CONNECTIONS ]"
sep
CONNS=$(ss -tn state established 2>/dev/null | grep -v "Local" | wc -l)
log "  Active connections: $CONNS"
ss -tn state established 2>/dev/null | grep -v "Local" | head -8 | awk '{print "  " $0}' | tee -a "$REPORT"
log ""

log "[ FIREWALL STATUS ]"
sep
if command -v ufw &>/dev/null; then
    ufw status verbose 2>/dev/null | awk '{print "  " $0}' | tee -a "$REPORT"
else
    log "  UFW not installed"
fi
log ""

log "[ SECURITY CHECKS ]"
sep
ROOT_LOGIN=$(grep "^PermitRootLogin" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}')
[[ "$ROOT_LOGIN" == "no" ]] && log "  OK  Root SSH login: disabled" || log "  !! Root SSH login: ENABLED"

PASS_AUTH=$(grep "^PasswordAuthentication" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}')
[[ "$PASS_AUTH" == "no" ]] && log "  OK  SSH password auth: disabled" || log "  !!  SSH password auth: enabled"

UFW_STATUS=$(ufw status 2>/dev/null | head -1)
[[ "$UFW_STATUS" == "Status: active" ]] && log "  OK  Firewall: active" || log "  !! Firewall: INACTIVE"

log ""
log "[ END OF REPORT ]"
log "Saved to: $REPORT"

