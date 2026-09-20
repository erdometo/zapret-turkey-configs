# Zapret DPI Bypass — Turkcell Superonline Edition

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux-blue.svg)]()
[![Tested on](https://img.shields.io/badge/ISP-Turkcell%20Superonline-orange.svg)]()

A verified, battle-tested [Zapret](https://github.com/bol-van/zapret) configuration and service toolkit designed specifically for **Turkcell Superonline** subscribers in Turkey to defeat state-level Deep Packet Inspection (DPI) and TCP reset (RST) attacks.

---

## 🇹🇷 Türkçe Açıklama

Bu proje, **Turkcell Superonline** fiber/VDSL altyapısında uygulanan Derin Paket İncelemesi (DPI), SNI sansürlemesi ve TCP Reset saldırılarını aşmak için `blockcheck` ile test edilmiş ve doğrulanmış yapılandırmaları içerir.

### Neden GoodbyeDPI ve Eski Zapret Ayarları Çalışmıyor?
1. **DPI Güncellemeleri:** Superonline, TCP segmentlerini yeniden birleştiren (reassembly) ve yaygın `autottl=2` veya standart `badseq` hilelerini yok sayan yeni DPI filtreleri kullanmaktadır. Bu durumlarda bağlantı anında `Connection reset by peer` hatası ile sonlandırılır.
2. **Hop Sınırı:** Superonline omurga sınırında DPI cihazları kullanıcının çıkış noktasından yaklaşık 5-6 hop mesafededir. Bu projede kullanılan **TTL=6** stratejisi, sahte paketin DPI kutusuna ulaşıp filtreyi yanıltmasını sağlarken, hedef web sunucusuna varmadan sonlanmasını garanti eder.
3. **Alternatif Sıra Örtüşmesi (`multidisorder`):** Sahte paket üretmeden, sadece gerçek paketleri özel sıra örtüşmesi (`seqovl=1`) ile bölerek DPI motorunu tamamen körleştiren ikinci bir kanıtlanmış yöntem de sunulmaktadır.

---

## 🚀 Quick Start / Hızlı Başlangıç

### Windows Kullanıcıları
1. Bu repoyu indirin (**Code -> Download ZIP**) ve bir klasöre çıkartın.
2. `windows` klasörüne girin:
   - **Hemen denemek için:** `1_START_SUPERONLINE_TTL6.cmd` dosyasına çift tıklayın (Yönetici iznini onaylayın).
   - **Kalıcı Arka Plan Servisi (Önerilen):** `2_INSTALL_SERVICE.cmd` dosyasına çift tıklayın. Bilgisayar her açıldığında arka planda görünmez şekilde çalışır.
   - **Kaldırmak için:** `3_UNINSTALL_SERVICE.cmd` dosyasını çalıştırmanız yeterlidir.

### Linux Kullanıcıları
`linux` klasöründeki betikler yerel `nfqws` motorunu kullanarak trafiği `NFQUEUE` üzerinden işler:
```bash
cd linux
chmod +x *.sh
sudo ./start_superonline.sh
```
Kalıcı `systemd` servisi kurmak için:
```bash
sudo ./install_systemd.sh
```

---

## ⚙️ Tested Strategy Summary

| Target | Desynchronization Rule | Notes |
| :--- | :--- | :--- |
| **HTTPS (TCP 443)** | `--dpi-desync=fake --dpi-desync-ttl=6 --dpi-desync-repeats=2` | Primary strategy discovered via live blockcheck |
| **HTTPS Alternative**| `--dpi-desync=multidisorder --dpi-desync-split-pos=2,midsld --dpi-desync-split-seqovl=1` | Sequence overlap, zero fake packets |
| **HTTP (TCP 80)** | `--dpi-desync=fake,fakedsplit --dpi-desync-ttl=6` | Standard HTTP header desync |
| **Discord / STUN** | `--filter-l7=discord,stun --dpi-desync=fake` | Fixes Discord voice channel (RTC) connection |

---

## 🔒 Recommended DNS Setup
DPI atlatma araçları ağ paketlerini düzenler ancak DNS zehirlenmesini engellemez. Tarayıcınızda veya yerel ağınızda (Pi-hole / Unbound) **DNS over HTTPS (DoH)** veya **DNS over TLS (DoT - Port 853)** aktif olmalıdır:
* Cloudflare: `https://cloudflare-dns.com/dns-query` (1.1.1.1)
* Quad9: `https://dns.quad9.net/dns-query` (9.9.9.9)

---

## 📚 Technical Documentation
* [Hop Analysis & Technical Mechanics](docs/TECHNICAL_ANALYSIS.md)
* [Sanitized Blockcheck Benchmark & Logs](docs/BENCHMARK_AND_TESTS.md)

---

## ⚖️ License & Acknowledgements
* Core engine developed by **bol-van**: [bol-van/zapret](https://github.com/bol-van/zapret) (MIT License).
* Windows packet redirection powered by [WinDivert](https://reqrypt.org/windivert.html) (LGPLv3 / GPLv2).
* Scripts and Superonline-specific configurations released under the [MIT License](LICENSE).
