# Zapret DPI Bypass — Turkcell Superonline Edition

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux-blue.svg)]()
[![Target ISP](https://img.shields.io/badge/ISP-Turkcell%20Superonline-orange.svg)]()
[![Upstream](https://img.shields.io/badge/Upstream-bol--van%2Fzapret-brightgreen.svg)](https://github.com/bol-van/zapret)

A verified, battle-tested [Zapret](https://github.com/bol-van/zapret) configuration and service toolkit designed specifically for **Turkcell Superonline** subscribers in Turkey to defeat ISP-level Deep Packet Inspection (DPI), Server Name Indication (SNI) sniffing, and TCP reset (RST) injection attacks.

---

## 📖 Background & Problem Statement

In Turkey, major ISPs (especially **Turkcell Superonline** on fiber and VDSL networks) employ advanced DPI hardware (such as Sandvine and Huawei equipment) at network aggregation boundaries. 

### Why Conventional Tools Fail on Modern Superonline:
1. **TCP Stream Reassembly:** Older tools like standard GoodbyeDPI split TLS `ClientHello` packets across simple TCP fragments. Modern Superonline DPI buffers and reassembles fragmented TCP streams before parsing the SNI, subsequently firing forged `TCP RST` packets (`curl error 35: Recv failure: Connection reset by peer`).
2. **The Fragility of TTL Hops:** Fake packet desynchronization (e.g. `TTL=6`) relies on the packet expiring exactly at the ISP middlebox. If your home network adds an extra hop (connecting through a Wi-Fi repeater, mesh node, or secondary router), the fake packet dies prematurely, causing connection drops.
3. **The Robust Solution (MultiDisorder):**
   * **`MultiDisorder` Strategy (Recommended & Default):** Splits the genuine `ClientHello` with a 1-byte sequence number overlap (`split-seqovl=1`). This blinds the DPI reassembly engine without generating synthetic fake packets and is **100% immune to local router/hop count changes**.
   * **QUIC / HTTP/3 Protection:** Desynchronizes UDP Port 443 `Initial` packets so modern browsers using HTTP/3 do not leak domain names over UDP.
   * **Discord Voice / STUN Support:** Handles UDP signaling and media streams, resolving "RTC Connecting" voice channel stalls.

---

## 🚀 Quick Start Guide

### Windows

#### 1. Interactive Run (Testing)
1. Download this repository (**Code -> Download ZIP**) and extract it.
2. Open the `windows` folder.
3. Double-click **`1_START_SUPERONLINE.cmd`** (approve the UAC elevation prompt).
4. Keep the console window open while browsing. To stop, close the window or run **`4_STOP_ZAPRET.cmd`**.

#### 2. Automatic Background Service (Recommended)
1. Open the `windows` folder.
2. Double-click **`2_INSTALL_SERVICE.cmd`**.
3. Zapret will now run silently as a native Windows service in the background on every PC boot—no open command prompt windows needed!
4. To remove the service anytime, run **`3_UNINSTALL_SERVICE.cmd`**.

#### 3. Keeping Core Binaries Updated
* Double-click **`update_zapret.cmd`** in the `windows` folder. It queries GitHub for the latest upstream `bol-van/zapret` release, automatically updates `winws.exe` and `WinDivert` drivers, and keeps your configurations intact.

---

### Linux

Linux operates via **`nfqws`** (Netfilter Queue Web Surrogate) interacting with `iptables` / `ip6tables`.

#### 1. Prerequisites
Ensure `iptables` and `libnetfilter-queue` are installed:
```bash
# Debian / Ubuntu
sudo apt install iptables libnetfilter-queue1

# Arch Linux
sudo pacman -S iptables libnetfilter_queue

# Fedora / RHEL
sudo dnf install iptables libnetfilter_queue
```

Install Zapret binaries from the official repository or package:
```bash
git clone --depth=1 https://github.com/bol-van/zapret.git /opt/zapret
make -C /opt/zapret/nfqws
```

#### 2. Running Manually
```bash
cd linux
chmod +x *.sh
sudo ./start_superonline.sh
```
To stop and restore firewall rules:
```bash
sudo ./stop_superonline.sh
```

#### 3. Installing as a Persistent Systemd Service
```bash
cd linux
sudo ./install_systemd.sh
```
Manage the service:
```bash
sudo systemctl status zapret-superonline.service
sudo systemctl stop zapret-superonline.service
```

---

## ⚙️ Verified Configuration Matrix

| Traffic Type | Strategy & Parameters | Impact / Notes |
| :--- | :--- | :--- |
| **HTTPS (TCP 443) Primary** | `--dpi-desync=multidisorder --dpi-desync-split-pos=2,midsld --dpi-desync-split-seqovl=1` | **Hop-Immune** sequence overlap; zero fake packets |
| **HTTPS (TCP 443) Fallback**| `--dpi-desync=fake --dpi-desync-ttl=6 --dpi-desync-repeats=2` | Calibrated TTL fake packet strategy (requires direct modem hop) |
| **HTTP (TCP 80)** | `--dpi-desync=fake,fakedsplit --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig` | Standard HTTP host header desync |
| **QUIC / HTTP3 (UDP 443)** | `--filter-l7=quic --dpi-desync=fake --dpi-desync-repeats=11` | Intercepts UDP 443 `Initial` packets to protect HTTP/3 |
| **Discord / STUN** | `--filter-l7=discord,stun --dpi-desync=fake` | Bypasses UDP voice channel (RTC) blocking |

---

## 🔒 Recommended DNS Configuration

DPI desynchronization tools resolve packet inspection and TCP resets, but they do not prevent DNS hijacking. To avoid poisoned DNS responses on port 53, configure **DNS over HTTPS (DoH)** or **DNS over TLS (DoT on Port 853)** in your browser, router, or local resolver (Pi-hole / Unbound):
* **Cloudflare:** `https://cloudflare-dns.com/dns-query` (`1.1.1.1`)
* **Quad9:** `https://dns.quad9.net/dns-query` (`9.9.9.9`)

---

## 📚 Technical Documentation

* [Technical Analysis & Hop Evasion Diagnostics](docs/TECHNICAL_ANALYSIS.md)
* [Sanitized Blockcheck Benchmark & Results Matrix](docs/BENCHMARK_AND_TESTS.md)
* [Windows Usage Guide](windows/README_WINDOWS.md)
* [Linux Usage Guide](linux/README_LINUX.md)

---

## ⚖️ Third-Party Notices & Licensing

This project is open-source under the [MIT License](LICENSE). It relies upon and incorporates open-source components under permissive and copyleft licenses:

* **Zapret (`winws.exe`, `nfqws`):** Copyright (c) 2017-2026 **bol-van** ([MIT License](https://github.com/bol-van/zapret/blob/master/docs/LICENSE.txt)).
* **WinDivert (`WinDivert.dll`, `WinDivert64.sys`):** Copyright (c) 2011-2020 **basil00** ([GNU LGPLv3 / GPLv2](https://reqrypt.org/windivert.html)).
* **Cygwin POSIX Emulation Library (`cygwin1.dll`):** Copyright (c) **Red Hat, Inc.** / Cygwin authors ([GNU LGPLv3](https://cygwin.com/licensing.html)).

For full license texts and legal notices, see [NOTICE.md](NOTICE.md).
