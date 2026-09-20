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
2. **DPI Hop Distance & Sequence Immunity:** Superonline's middleboxes ignore generic TCP sequence desynchronization tricks (e.g. `badseq` or `autottl=2`). Fake packets must be tuned to match the exact hop boundary of the ISP core.
3. **The Solution:** 
   * **`TTL=6` Strategy:** Fake handshakes are sent with a Time-To-Live of 6. The fake packet poisons the DPI state table at the Hop 6 boundary, decrements to TTL=0, and expires *before* reaching the destination server. The real TLS handshake then passes through unimpeded.
   * **`multidisorder` Strategy:** Alternatively, the genuine `ClientHello` is split with sequence number overlapping (`seqovl=1`), blinding the DPI reassembly engine without generating any fake packets.

---

## 🚀 Quick Start Guide

### Windows

#### Option A: Interactive Run (Testing)
1. Download this repository (**Code -> Download ZIP**) and extract it.
2. Open the `windows` folder.
3. Double-click **`1_START_SUPERONLINE_TTL6.cmd`** (approve the UAC elevation prompt).
4. Keep the console window open while browsing. To stop, close the window or run **`4_STOP_ZAPRET.cmd`**.

#### Option B: Automatic Background Service (Recommended)
1. Open the `windows` folder.
2. Double-click **`2_INSTALL_SERVICE.cmd`**.
3. Zapret will now run silently as a native Windows service in the background on every PC boot—no open command prompt windows needed!
4. To remove the service anytime, run **`3_UNINSTALL_SERVICE.cmd`**.

#### Option C: Keeping Core Binaries Updated
* Double-click **`update_zapret.cmd`** in the `windows` folder. It queries GitHub for the latest upstream `bol-van/zapret` release, automatically updates `winws.exe` and `WinDivert` drivers, and keeps your Superonline configs intact.

---

### Linux

Linux operates via **`nfqws`** (Netfilter Queue Web Surrogate) interacting with `iptables` or `nftables`.

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
| **HTTPS (TCP 443)** | `--dpi-desync=fake --dpi-desync-ttl=6 --dpi-desync-repeats=2` | Primary strategy discovered and verified via `blockcheck` |
| **HTTPS Fallback** | `--dpi-desync=multidisorder --dpi-desync-split-pos=2,midsld --dpi-desync-split-seqovl=1` | Sequence overlap desync; requires zero fake packets |
| **HTTP (TCP 80)** | `--dpi-desync=fake,fakedsplit --dpi-desync-ttl=6` | Standard HTTP host header desync |
| **Discord / STUN** | `--filter-l7=discord,stun --dpi-desync=fake` | Bypasses UDP voice channel (RTC) blocking |

---

## 🔒 Recommended DNS Configuration

DPI desynchronization tools resolve packet inspection and TCP resets, but they do not prevent DNS hijacking. To avoid poisoned DNS responses on port 53, configure **DNS over HTTPS (DoH)** or **DNS over TLS (DoT on Port 853)** in your browser, router, or local resolver (Pi-hole / Unbound):
* **Cloudflare:** `https://cloudflare-dns.com/dns-query` (`1.1.1.1`)
* **Quad9:** `https://dns.quad9.net/dns-query` (`9.9.9.9`)

---

## 📚 Technical Documentation

* [Technical Analysis & Superonline Hop Diagnostics](docs/TECHNICAL_ANALYSIS.md)
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
