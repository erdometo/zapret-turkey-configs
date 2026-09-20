#!/usr/bin/env bash
# Zapret Superonline DPI Bypass for Linux (nfqws)
set -e

if [[ $EUID -ne 0 ]]; then
   echo "[ERROR] This script must be run as root (sudo)."
   exit 1
fi

QNUM=200
NFQWS_BIN=$(command -v nfqws || echo "/opt/zapret/nfqws/nfqws")

if [[ ! -x "$NFQWS_BIN" ]]; then
    echo "[ERROR] nfqws binary not found. Please install zapret or place nfqws in PATH."
    exit 1
fi

echo "Setting up iptables NFQUEUE redirection on queue $QNUM..."
iptables -t mangle -D POSTROUTING -p tcp -m multiport --dports 80,443 -m mark ! --mark 0x40000000/0x40000000 -j NFQUEUE --queue-num $QNUM --queue-bypass 2>/dev/null || true
iptables -t mangle -I POSTROUTING -p tcp -m multiport --dports 80,443 -m mark ! --mark 0x40000000/0x40000000 -j NFQUEUE --queue-num $QNUM --queue-bypass

echo "Starting nfqws with Superonline parameters (TTL=6 & multidisorder)..."
"$NFQWS_BIN" --qnum=$QNUM --daemon \
  --filter-tcp=80 --dpi-desync=fake,fakedsplit --dpi-desync-ttl=6 --new \
  --filter-tcp=443 --dpi-desync=fake --dpi-desync-ttl=6 --dpi-desync-repeats=2

echo "[SUCCESS] Zapret nfqws is now running for Superonline."
