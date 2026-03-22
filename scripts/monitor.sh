#!/bin/bash
set -euo pipefail

while true; do
	clear
	echo "=== SERVER MONITOR ==="
	echo "Host: $(hostname)"
	echo "Date: $(date)"
	echo "Uptime: $(uptime -p)"
	echo "CPU Load: $(cat /proc/loadavg)"
	echo "Memory: $(grep -E 'MemTotal|MemFree|MemAvailable' /proc/meminfo)"
	echo "Disk Usage: $(df -h)"
	echo "Top 5 Processes: $(ps aux --sort=-%cpu | head -6)"
	echo "listening Ports: $(ss -tulpn | head -10)"
	sleep 5
done
