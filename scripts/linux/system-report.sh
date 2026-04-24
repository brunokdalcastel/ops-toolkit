#!/usr/bin/env bash
#
# system-report.sh — relatório rápido de saúde do sistema Linux
#
# Usage: ./system-report.sh [-o FILE] [--services svc1,svc2] [-h]
#
#   -o FILE         salva o relatório no arquivo especificado
#   --services LIST serviços extras a verificar, separados por vírgula (ex: nginx,mysql)
#   -h, --help      exibe esta ajuda
#
# Author: Bruno K. Dalcastel
# Requires: bash 4+, coreutils, procps

set -euo pipefail
IFS=$'\n\t'

die() { printf '[ERROR] %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
output=''
extra_services=''

while [[ $# -gt 0 ]]; do
    case "$1" in
        -o)
            [[ -n "${2-}" ]] || die "-o requires a file path argument"
            output="$2"
            shift 2
            ;;
        --services)
            [[ -n "${2-}" ]] || die "--services requires a comma-separated service list"
            extra_services="$2"
            shift 2
            ;;
        -h|--help)
            printf 'Usage: %s [-o FILE] [--services svc1,svc2]\n' "$0"
            exit 0
            ;;
        *)
            die "Unknown option: $1"
            ;;
    esac
done

# ---------------------------------------------------------------------------
# Section helpers
# ---------------------------------------------------------------------------
section() { printf '\n===== %s =====\n' "$1"; }

# ---------------------------------------------------------------------------
# CPU
# ---------------------------------------------------------------------------
report_cpu() {
    section "CPU"
    local cores load
    cores=$(nproc)
    load=$(awk '{printf "%s (1m)  %s (5m)  %s (15m)", $1, $2, $3}' /proc/loadavg)
    printf 'Cores      : %s\n' "$cores"
    printf 'Load avg   : %s\n' "$load"
}

# ---------------------------------------------------------------------------
# Memory
# ---------------------------------------------------------------------------
report_memory() {
    section "Memory"
    free -h
}

# ---------------------------------------------------------------------------
# Disk — excludes pseudo-filesystems
# ---------------------------------------------------------------------------
report_disk() {
    section "Disk"
    df -h | grep -v -E '^(tmpfs|devtmpfs|udev)' || true
}

# ---------------------------------------------------------------------------
# Uptime
# ---------------------------------------------------------------------------
report_uptime() {
    section "Uptime"
    uptime -p 2>/dev/null || uptime
}

# ---------------------------------------------------------------------------
# Service check — supports systemd and SysV init
# ---------------------------------------------------------------------------
check_service() {
    local svc="$1" status
    if command -v systemctl > /dev/null 2>&1; then
        if systemctl is-active --quiet "$svc" 2>/dev/null; then
            status='ACTIVE'
        else
            status='INACTIVE'
        fi
    else
        if service "$svc" status > /dev/null 2>&1; then
            status='ACTIVE'
        else
            status='INACTIVE'
        fi
    fi
    printf '  %-20s [%s]\n' "$svc" "$status"
}

report_services() {
    section "Services"
    local svc
    for svc in sshd cron; do
        check_service "$svc"
    done
    if [[ -n "$extra_services" ]]; then
        local -a extra_list
        IFS=',' read -ra extra_list <<< "$extra_services"
        for svc in "${extra_list[@]}"; do
            [[ -n "$svc" ]] && check_service "$svc"
        done
    fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
    printf 'System Report — %s\n' "$(date '+%Y-%m-%d %H:%M:%S')"
    report_cpu
    report_memory
    report_disk
    report_uptime
    report_services
    printf '\n'
}

if [[ -n "$output" ]]; then
    main | tee "$output"
else
    main
fi
