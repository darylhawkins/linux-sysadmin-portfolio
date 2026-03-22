#!/bin/bash
# backup.sh — Backup with rotation and logging
# Usage: ./backup.sh <source> <destination> [keep_count]
# Example: ./backup.sh /var/www /backups/www 7

set -euo pipefail

SOURCE="${1:?ERROR: Provide source directory. Usage: $0 <source> <dest> [keep]}"
DEST="${2:?ERROR: Provide destination directory.}"
KEEP="${3:-7}"
LOG="/home/$(whoami)/projects/phase1/logs/backup.log"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
BACKUP_FILE="backup_$(basename "$SOURCE")_${TIMESTAMP}.tar.gz"
TEMP_FILE="$DEST/.tmp_$BACKUP_FILE"

log()     { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"; }
log_err() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" | tee -a "$LOG" >&2; }

cleanup() {
    [[ -f "$TEMP_FILE" ]] && rm -f "$TEMP_FILE" && log "Cleaned up temp file"
}
trap cleanup EXIT ERR

[[ -d "$SOURCE" ]] || { log_err "Source '$SOURCE' is not a directory"; exit 1; }

mkdir -p "$DEST"
log "=== BACKUP START ==="
log "Source: $SOURCE -> $DEST/$BACKUP_FILE"

# Write to temp first, then rename (atomic operation)
log "Compressing..."
tar -czf "$TEMP_FILE" -C "$(dirname "$SOURCE")" "$(basename "$SOURCE")"
mv "$TEMP_FILE" "$DEST/$BACKUP_FILE"

SIZE=$(du -sh "$DEST/$BACKUP_FILE" | cut -f1)
log "Backup complete: $SIZE"

# Rotate — keep only N most recent backups
BASE=$(basename "$SOURCE")
COUNT=$(ls -1 "$DEST"/backup_${BASE}_*.tar.gz 2>/dev/null | wc -l)
if [[ $COUNT -gt $KEEP ]]; then
    log "Rotating backups (keeping $KEEP of $COUNT)..."
    ls -1t "$DEST"/backup_${BASE}_*.tar.gz | tail -n +$(( KEEP + 1 )) | xargs rm -v 2>&1 | tee -a "$LOG"
fi

log "Total backups kept: $(ls -1 "$DEST"/backup_${BASE}_*.tar.gz 2>/dev/null | wc -l)"
log "=== BACKUP DONE ==="
