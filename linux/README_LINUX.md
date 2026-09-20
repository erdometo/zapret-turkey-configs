# Linux Usage Guide

Zapret operates on Linux via **`nfqws`** (Netfilter Queue Web Surrogate) interacting with Netfilter (`iptables` or `nftables`).

## Prerequisites
Ensure `iptables` and `libnetfilter-queue` are installed:
* **Debian/Ubuntu:** `sudo apt install iptables libnetfilter-queue1`
* **Arch Linux:** `sudo pacman -S iptables libnetfilter_queue`
* **Fedora:** `sudo dnf install iptables libnetfilter_queue`

Install Zapret binaries from the official repository or package:
```bash
git clone --depth=1 https://github.com/bol-van/zapret.git /opt/zapret
make -C /opt/zapret/nfqws
```

## Running Manually
```bash
cd linux
chmod +x *.sh
sudo ./start_superonline.sh
```

To stop:
```bash
sudo ./stop_superonline.sh
```

## Running as Systemd Service
```bash
sudo ./install_systemd.sh
```
Manage the service:
```bash
sudo systemctl status zapret-superonline.service
sudo systemctl stop zapret-superonline.service
```
