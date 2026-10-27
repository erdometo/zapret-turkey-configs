# Technical Analysis: Superonline DPI & Evasion Mechanics

## 1. Network Topology & Traceroute Hop Analysis

A standard connection through Turkcell Superonline fiber traverses a centralized CGNAT and regional aggregation boundary before hitting the international border gateway:

```text
Hop 1: 192.168.1.1       (Local LAN / Home Fiber Modem)
Hop 2: 10.57.0.1         (Superonline BNG / CGNAT Gateway)
Hop 3: 10.36.7.110       (Regional Aggregation Router)
Hop 4: 172.16.51.10      (Superonline Core Backbone)
Hop 5: 172.16.244.17     (Superonline Transit / Traffic Shaping)
Hop 6: 172.17.225.158    (DPI Middlebox Interception Boundary)
Hop 7+: External Transit (Cloudflare / Destination Web Servers)
```

---

## 2. Real-World Findings: Why TTL Strategies Are Fragile

### The Hop-Shift Phenomenon
In practice, home network environments frequently change. For example, connecting through a secondary router, Wi-Fi mesh node, or range extender inserts an extra gateway:

```text
Hop 1: 192.168.2.1       (Secondary Router / Wi-Fi Mesh Node)
Hop 2: 192.168.1.1       (Superonline Fiber Modem)
Hop 3: 10.57.0.1         (Superonline BNG Gateway)
...
Hop 7/8: 172.17.225.140  (DPI Middlebox is now at Hop 7 or 8!)
```

* When configured with a static `--dpi-desync-ttl=6`:
  - The packet decrements to TTL=0 at Hop 6 (`172.16.244.18`), **dying prematurely before reaching the DPI box**.
  - The DPI middlebox never receives the fake packet and therefore never marks the flow as clean.
  - The genuine TLS handshake arrives unaltered, prompting the middlebox to drop packets or inject TCP resets (`curl: (28) Connection timed out`).

---

## 3. The Winning Solutions Compared

### Strategy 1: MultiDisorder (The Hop-Immune Standard)
```text
--filter-tcp=443 --dpi-desync=multidisorder --dpi-desync-split-pos=2,midsld --dpi-desync-split-seqovl=1
```
* **Mechanism:** Rather than generating synthetic fake packets with an expiration timer, MultiDisorder splits the genuine TLS `ClientHello` across TCP segments with a **1-byte sequence overlap (`seqovl=1`)**.
* **Why It Is Superior:**
  1. **Hop Independence:** Does not rely on TTL distance. Works identically over Ethernet, Wi-Fi repeaters, double-NAT subnets, or mobile hotspots.
  2. **Zero Fake Packets:** All packets are 100% genuine TCP segments. Segment fragmentation and reordering occur naturally on IP networks, leaving no synthetic packet footprint on the wire.
  3. **High Performance:** Modern operating systems (Windows, Linux, macOS) reassemble overlapping TCP segments in hardware/kernel stack without penalty. In-line DPI string parsers fail to reassemble the disjointed stream and miss the SNI.

### Strategy 2: Calibrated TTL Evasion (Fallback)
```text
--filter-tcp=443 --dpi-desync=fake --dpi-desync-ttl=6 --dpi-desync-repeats=2
```
* **Mechanism:** Emits a fake TLS ClientHello with `TTL=6`. The packet arrives at the DPI middlebox with TTL=1, poisoning its connection state table, and expires at the boundary before reaching the real server.
* **Caveat:** Highly effective, but strictly tied to a fixed hop distance from the modem.

---

## 4. QUIC (HTTP/3) and UDP Desynchronization

Modern web browsers (Chrome, Edge, Firefox) increasingly negotiate **HTTP/3 over UDP Port 443 (QUIC)**.
* QUIC `Initial` packets also contain a plaintext TLS `ClientHello` with the SNI extension.
* To prevent leakage over UDP, Zapret inspects outbound UDP packets matching the IETF QUIC Initial header format (`windivert_part.quic_initial_ietf.txt`) and desynchronizes them using fake packets (`--filter-l7=quic --dpi-desync=fake`).
* Discord voice channels communicate using UDP media and STUN discovery packets. The rule `--filter-l7=discord,stun --dpi-desync=fake` ensures voice servers connect without getting trapped on "RTC Connecting".
