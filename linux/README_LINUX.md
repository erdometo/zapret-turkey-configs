# Linux Usage Guide

Zapret operates on Linux via **`nfqws`** (Netfilter Queue Web Surrogate) interacting with Netfilter (`iptables` / `ip6tables`).

## Prerequisites
Ensure `iptables` and `libnetfilter-queue` are installed:
* **Debian / Ubuntu:** `sudo apt install iptables libnetfilter-queue1`
* **Arch Linux:** `sudo pacman -S iptables libnetfilter_queue`
* **Fedora / RHEL:** `sudo dnf install iptables libnetfilter_queue`

Build or install Zapret binaries:
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

## Running as a Persistent Systemd Service
```bash
cd linux
sudo ./install_systemd.sh
```
Manage service:
```bash
sudo systemctl status zapret-superonline.service
sudo systemctl stop zapret-superonline.service
```

## Upstream Updates
Run `sudo ./update_zapret.sh` to fetch the latest commits from upstream `bol-van/zapret` and rebuild `nfqws`.
