# Linux SysAdmin Portfolio

Production Linux server administration skills built through hands-on projects 
on a live Hetzner VPS running Ubuntu 22.04 LTS.

## Server Stack
- **OS:** Ubuntu 22.04 LTS
- **Web Server:** Nginx
- **Database:** MySQL 8.0
- **Runtime:** PHP 8.3 (FPM)
- **Firewall:** UFW with rate-limited SSH
- **Platform:** Hetzner Cloud VPS (live, publicly accessible)

## Scripts

| Script | Description |
|--------|-------------|
| `health-report.sh` | Generates timestamped system health report — CPU, memory, disk, top processes, listening ports. Runs daily via cron. |
| `backup.sh` | Automated backup with configurable retention rotation. Uses atomic writes to prevent corrupt backups. |
| `watchdog.sh` | Service monitor that detects and automatically restarts crashed services. |
| `network-audit.sh` | Security audit report — network interfaces, open ports, firewall status, SSH hardening verification. |

## Skills Demonstrated
- SSH hardening — key-based auth, disabled root login, MaxAuthTries, AllowUsers
- UFW firewall — rate-limited SSH, default deny incoming
- LEMP stack deployment and configuration from scratch
- Bash scripting — functions, error handling, logging, cron scheduling
- Process monitoring and system resource analysis
- Network security auditing

## Background
Cybersecurity graduate building Linux sysadmin skills for remote freelance work. 
All projects completed on a live production VPS.
