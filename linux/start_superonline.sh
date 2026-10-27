#!/usr/bin/env bash
# Zapret Superonline DPI Bypass for Linux (nfqws)
# Supports MultiDisorder (Hop-Immune), IPv4/IPv6, and QUIC/Discord
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

echo "Setting up Netfilter queue redirection on queue $QNUM..."

# Flush any existing rules for queue $QNUM safely
iptables -t mangle -D POSTROUTING -p tcp -m multiport --dports 80,443 -m mark ! --mark 0x40000000/0x40000000 -j NFQUEUE --queue-num $QNUM --queue-bypass 2>/dev/null || true
iptables -t mangle -D POSTROUTING -p udp --dport 443 -m mark ! --mark 0x40000000/0x40000000 -j NFQUEUE --queue-num $QNUM --queue-bypass 2>/dev/null || true

# Insert IPv4 redirection rules
iptables -t mangle -I POSTROUTING -p tcp -m multiport --dports 80,443 -m mark ! --mark 0x40000000/0x40000000 -j NFQUEUE --queue-num $QNUM --queue-bypass
iptables -t mangle -I POSTROUTING -p udp --dport 443 -m mark ! --mark 0x40000000/0x40000000 -j NFQUEUE --queue-num $QNUM --queue-bypass

# Insert IPv6 redirection rules if ip6tables is available
if command -v ip6tables >/dev/null 2>&1; then
    ip6tables -t mangle -D POSTROUTING -p tcp -m multiport --dports 80,443 -m mark ! --mark 0x40000000/0x40000000 -j NFQUEUE --queue-num $QNUM --queue-bypass 2>/dev/null || true
    ip6tables -t mangle -D POSTROUTING -p udp --dport 443 -m mark ! --mark 0x40000000/0x40000000 -j NFQUEUE --queue-num $QNUM --queue-bypass 2>/dev/null || true
    ip6tables -t mangle -I POSTROUTING -p tcp -m multiport --dports 80,443 -m mark ! --mark 0x40000000/0x40000000 -j NFQUEUE --queue-num $QNUM --queue-bypass
    ip6tables -t mangle -I POSTROUTING -p udp --dport 443 -m mark ! --mark 0x40000000/0x40000000 -j NFQUEUE --queue-num $QNUM --queue-bypass
fi

echo "Starting nfqws daemon (MultiDisorder hop-immune + QUIC)..."
"$NFQWS_BIN" --qnum=$QNUM --daemon \
  --filter-tcp=80 --dpi-desync=fake,fakedsplit --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --new \
  --filter-tcp=443 --dpi-desync=multidisorder --dpi-desync-split-pos=2,midsld --dpi-desync-split-seqovl=1 --new \
  --filter-udp=443 --dpi-desync=fake --dpi-desync-repeats=11

echo "[SUCCESS] Zapret nfqws is now running for Superonline."
