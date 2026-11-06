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
  local options="$1"
  local threshold="$2"
  local output rc

  # For monitoring, use something like 5-10 seconds
  # Exclude virtual and temporary filesystems
  output=$(
    timeout 1s df -"$options" \
        -x iso9660 \
        -x udf \
        -x efivarfs \
        -x tmpfs \
        -x devtmpfs \
        2>&1
  )
  rc=$?

  if [ $rc -eq 124 ]; then
    echo "ERROR: 'df' timed out! Is a mounted remote share unreachable (nsf, smb, ...)?" >&2
    return 1
  elif [ $rc -ne 0 ]; then
    echo "ERROR: 'df' failed: $output" >&2
    return $rc
  fi

  awk -v threshold="$threshold" '
    NR == 1 {
      header = $0
      next
    }

    # Check filesystems exceeding threshold.
    $5+0 > threshold &&

    # Ignore /tmp/[Folder].
    $6 !~ /^\/tmp(\/|$)/ &&

    # Exclude /usr/lib/[modules|linux-tools].
    $6 !~ /^\/usr\/lib\/(modules|linux-tools)(\/|$)/ {
      rows = rows $0 ORS
    }

    # Print header and matching entries only.
    END {
      if (rows != "")
        printf "%s\n%s", header, rows
    }
  ' <<< "$output"
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
    echo "SELinux: $selinux_status"
  fi
fi

