#!/usr/bin/env bash
# Install zapret-superonline as a systemd service
set -e

if [[ $EUID -ne 0 ]]; then
   echo "[ERROR] This script must be run as root (sudo)."
   exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing launcher scripts to /usr/local/bin..."
cp "$DIR/start_superonline.sh" /usr/local/bin/zapret-superonline-start
cp "$DIR/stop_superonline.sh" /usr/local/bin/zapret-superonline-stop
chmod +x /usr/local/bin/zapret-superonline-start /usr/local/bin/zapret-superonline-stop

echo "Installing systemd unit file..."
cp "$DIR/zapret-superonline.service" /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now zapret-superonline.service

echo "[SUCCESS] Service installed and started!"
echo "Check status with: systemctl status zapret-superonline.service"
