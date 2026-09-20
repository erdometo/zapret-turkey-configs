# Diagnostic Test Results (Superonline Blockcheck)

Below are the verified results obtained from systematic probing against target services on Turkcell Superonline fiber.

---

## 1. Baseline Connectivity Test

```text
* port block tests ipv4 discord.com:443
162.159.135.232:443 connects
162.159.136.232:443 connects
162.159.137.232:443 connects
162.159.138.232:443 connects
162.159.128.233:443 connects

* Checking without DPI bypass:
curl: (28) Connection timed out after 2007 milliseconds
UNAVAILABLE code=28 (DPI drop / silent timeout)
```

---

## 2. Tested Desynchronization Strategies Matrix

| Strategy Tested | Parameters | Result | Notes |
| :--- | :--- | :--- | :--- |
| **Multisplit (Simple)** | `--dpi-desync=multisplit --dpi-desync-split-pos=2` | ❌ Reset (Code 35) | Middlebox reassembles split segments |
| **Multidisorder (Simple)** | `--dpi-desync=multidisorder --dpi-desync-split-pos=1,midsld` | ❌ Reset (Code 35) | Disordered segments parsed without overlap |
| **Fake with TTL=1..5** | `--dpi-desync=fake --dpi-desync-ttl=1..5` | ❌ Reset / Timeout | Dies before reaching DPI box at Hop 6 |
| **Fake with badseq** | `--dpi-desync=fake --dpi-desync-fooling=badseq` | ❌ Reset (Code 35) | Middlebox ignores badseq fooling |
| **Fake with badsum** | `--dpi-desync=fake --dpi-desync-fooling=badsum` | ❌ Timeout (Code 28) | Dropped by ISP routers |
| **Fake with TTL=6** | `--dpi-desync=fake --dpi-desync-ttl=6` | ✅ **AVAILABLE** | **Verified working strategy** |
| **Fake badseq (inc=0)**| `--dpi-desync=fake --dpi-desync-fooling=badseq --dpi-desync-badseq-increment=0` | ✅ **AVAILABLE** | Passes without sequence drift |
| **Multidisorder Overlap**| `--dpi-desync=multidisorder --dpi-desync-split-pos=2,midsld --dpi-desync-split-seqovl=1` | ✅ **AVAILABLE** | **Zero fake packets, immune to TTL changes** |
| **QUIC / HTTP3** | Direct connection | ✅ **AVAILABLE** | HTTP/3 QUIC not subject to TCP reset attacks |

---

## 3. Conclusions
1. The **`TTL=6`** strategy consistently defeats Superonline's TCP RST injection across all Cloudflare, Fastly, and independent web hosts.
2. The **`multidisorder` with sequence overlap (`seqovl=1`)** serves as a robust fallback that does not rely on hop distance calculations.
