# Is systemd available and running?
if ! command -v systemctl &>/dev/null; then
  echo "⚠ Systemd is not available."
elif ! systemctl is-system-running >/dev/null 2>&1; then
  echo "⚠ Systemd is not running."
else
  # Show failed systemd services
  failed_services=$(systemctl --failed --no-legend --plain 2>/dev/null)

  if [[ -n "$failed_services" ]]; then
    echo
    echo "⚠ Failed systemd services detected:"
    systemctl --failed --no-pager
    echo
  fi

  # Detect clock drift (NTP not synchronized)
  timedatectl show -p NTPSynchronized --value | \
  grep -q yes || echo "⚠ NTP not synchronized"
fi

# Check for high filesystem usage
check_disk_usage() {
  df -"$1" -x iso9660 -x udf |
    awk -v threshold="$2" '
      NR == 1 { header = $0; next }
      $5+0 > threshold &&
      $6 !~ /^\/usr\/lib\/(modules|linux-tools)(\/|$)/ {
        rows = rows $0 ORS
      }
      END {
        if (rows != "")
          printf "%s\n%s", header, rows
      }'
}

# Check for high filesystem usage
check_disk_usage hP "$disk_threshold"

# Check inode exhaustion
check_disk_usage iP "$disk_inode_threshold"

# Only for root
if (( EUID == 0 )); then
  # Check for kernel errors
  kernel_errors=$(journalctl -k -p err -b --no-pager --quiet 2>/dev/null | wc -l)
  (( kernel_errors > 0 )) && echo "⚠ $kernel_errors kernel errors since boot, check: journalctl -k -p err"
  # Check for OOM events in dmesg
  dmesg | grep -qi "out of memory" && echo "⚠ OOM event detected"
fi

# Selinux status
if command -v getenforce &>/dev/null; then
  selinux_status=$(getenforce)
  if [[ "$selinux_status" ]]; then
    echo "Selinux status: $selinux_status"
  fi
fi

