#!/usr/bin/env bash
# Stop Zapret and remove firewall rules
set -e

if [[ $EUID -ne 0 ]]; then
   echo "[ERROR] This script must be run as root (sudo)."
   exit 1
fi

QNUM=200
echo "Removing iptables NFQUEUE rules..."
iptables -t mangle -D POSTROUTING -p tcp -m multiport --dports 80,443 -m mark ! --mark 0x40000000/0x40000000 -j NFQUEUE --queue-num $QNUM --queue-bypass 2>/dev/null || true

echo "Terminating nfqws..."
killall nfqws 2>/dev/null || true

echo "[SUCCESS] Zapret stopped and iptables rules flushed."
