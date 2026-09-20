#!/usr/bin/env bash
# Update Zapret nfqws from official upstream repository
set -e

if [[ $EUID -ne 0 ]]; then
   echo "[ERROR] This script must be run as root (sudo)."
   exit 1
fi

ZAPRET_DIR="/opt/zapret"

if [[ ! -d "$ZAPRET_DIR/.git" ]]; then
    echo "[INFO] Cloning fresh upstream repository to $ZAPRET_DIR..."
    git clone --depth=1 https://github.com/bol-van/zapret.git "$ZAPRET_DIR"
else
    echo "[INFO] Pulling latest commits from upstream..."
    cd "$ZAPRET_DIR"
    git pull origin master
fi

echo "[INFO] Compiling updated nfqws..."
make -C "$ZAPRET_DIR/nfqws"

echo "[INFO] Restarting zapret-superonline service if active..."
if systemctl is-active --quiet zapret-superonline.service 2>/dev/null; then
    systemctl restart zapret-superonline.service
    echo "[INFO] Service restarted."
fi

echo "[SUCCESS] Upstream Zapret nfqws updated successfully!"
