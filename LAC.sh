#!/bin/bash

# Forensic Data Collection Script for Linux
# Detects system type (server/workstation) and collects key artifacts

# Output directory setup
TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")
OUTPUT_DIR="$HOME/Downloads/Linux-Artifacts_$TIMESTAMP"
mkdir -p "$OUTPUT_DIR"

# Check if script is run with sudo
echo "Checking sudo permissions..."
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root or with sudo. Exiting."
    exit 1
fi

# Detect if the system is a server or workstation
SYSTEM_TYPE="unknown"
if systemctl list-units --type=service | grep -q "graphical.target"; then
    SYSTEM_TYPE="workstation"
else
    SYSTEM_TYPE="server"
fi
echo "Detected system type: $SYSTEM_TYPE"

# Collect basic system information
echo "Collecting system information..."
uname -a > "$OUTPUT_DIR/system_info.txt"
lsb_release -a >> "$OUTPUT_DIR/system_info.txt"
cat /etc/os-release >> "$OUTPUT_DIR/system_info.txt"

# Collect user & authentication logs
echo "Collecting user logs..."
cp /var/log/auth.log "$OUTPUT_DIR/auth.log" 2>/dev/null
cp /var/log/secure "$OUTPUT_DIR/secure.log" 2>/dev/null
who -a > "$OUTPUT_DIR/logged_users.txt"

# Running processes & services
echo "Collecting running processes and services..."
ps aux > "$OUTPUT_DIR/running_processes.txt"
systemctl list-units --type=service > "$OUTPUT_DIR/services.txt"

# Collect crontab jobs
echo "Collecting scheduled tasks..."
crontab -l > "$OUTPUT_DIR/crontab.txt" 2>/dev/null
ls -lah /var/spool/cron/ > "$OUTPUT_DIR/cron_jobs.txt"

# Collect active network connections
echo "Collecting network connections..."
netstat -tulnp > "$OUTPUT_DIR/network_connections.txt"
ss -pant > "$OUTPUT_DIR/active_sockets.txt"
iptables -L -v -n > "$OUTPUT_DIR/firewall_rules.txt"

# Collect file system details
echo "Collecting file system information..."
ls -lah /root/ > "$OUTPUT_DIR/root_directory.txt"
find /etc/ -type f -exec md5sum {} \; > "$OUTPUT_DIR/config_file_hashes.txt"

# Collect bash history
echo "Collecting shell history..."
cp ~/.bash_history "$OUTPUT_DIR/bash_history.txt" 2>/dev/null
cp /root/.bash_history "$OUTPUT_DIR/root_bash_history.txt" 2>/dev/null

# Check for abnormal activities
echo "Checking for abnormal activities..."
journalctl -p err -n 100 > "$OUTPUT_DIR/system_errors.txt"
dmesg | tail -n 100 > "$OUTPUT_DIR/dmesg_logs.txt"

# Collect browser artifacts
echo "Collecting browser artifacts..."
mkdir -p "$OUTPUT_DIR/browser_artifacts"
cp -r ~/.mozilla/firefox "$OUTPUT_DIR/browser_artifacts/firefox" 2>/dev/null
cp -r ~/.config/google-chrome "$OUTPUT_DIR/browser_artifacts/chrome" 2>/dev/null
cp -r ~/.config/chromium "$OUTPUT_DIR/browser_artifacts/chromium" 2>/dev/null

# Check if inotifywait is installed, if not install it
echo "Checking for inotifywait availability..."
if ! command -v inotifywait &> /dev/null; then
    echo "inotifywait not found, installing..."
    apt-get update -y && apt-get install -y inotify-tools
fi

# Collect file activity artifacts
echo "Collecting file activity artifacts..."
inotifywait -m / --timefmt "%Y-%m-%d %H:%M:%S" --format "%T %w%f %e" -e create,modify,delete --exclude "proc|sys|dev" > "$OUTPUT_DIR/file_activity.log" &

# Compress the forensic data
echo "Compressing collected data..."
tar -czf "$OUTPUT_DIR.tar.gz" "$OUTPUT_DIR" && rm -rf "$OUTPUT_DIR"

echo "Forensic collection completed. Data saved to: $OUTPUT_DIR.tar.gz"
