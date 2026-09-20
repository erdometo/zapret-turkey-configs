# Technical Analysis: Superonline DPI & Evasion Mechanics

## 1. Network Topology & Traceroute Hop Analysis

A standard connection through Turkcell Superonline fiber traverses through a centralized CGNAT and regional aggregation boundary before hitting the international border gateway:

```text
Hop 1: 192.168.1.1       (Local LAN / Home Router)
Hop 2: 10.57.0.1         (Superonline BNG / CGNAT Gateway)
Hop 3: 10.36.7.110       (Regional Aggregation Router)
Hop 4: 172.16.51.10      (Superonline Core Backbone)
Hop 5: 172.16.244.17     (Superonline Transit / Traffic Shaping)
Hop 6: 172.17.225.158    (DPI Middlebox Interception Boundary)
Hop 7+: External Transit (Cloudflare / Destination Web Servers)
```

## 2. Why Conventional Bypass Methods Failed

### The Fall of GoodbyeDPI
GoodbyeDPI operates by splitting HTTP/HTTPS requests into two TCP chunks (e.g. at offset 2 or host position). Modern Huawei and Sandvine middleboxes deployed on Superonline's network now buffer and reconstruct incoming TCP streams across segments. As soon as the complete `ClientHello` is reconstructed and the SNI matches a blocked domain (e.g. `discord.com`), the middlebox injects a forged TCP RST packet with spoofed sequence numbers to both endpoints.

### Why `autottl=2` and `badseq` Failed
Existing community scripts (such as those configured in older repositories) commonly rely on:
```text
--dpi-desync=fake --dpi-desync-autottl=2 --dpi-desync-fooling=badseq
```
Live diagnostic testing revealed two fatal issues with this configuration on modern Superonline lines:
1. **DPI Sequence Immunity:** Superonline's DPI ignores invalid TCP sequence offsets and processes the handshake anyway.
2. **TTL Delta Inadequacy:** `autottl=2` calculates TTL dynamically based on estimated distance, but variable routing over Superonline's multi-hop core causes fake packets to either die prematurely (before reaching the DPI) or reach the destination server, triggering immediate connection resets (`curl error 35: Recv failure: Connection reset by peer`).

---

## 3. The Winning Strategies

### Strategy 1: Fixed Hop Evasion (`TTL=6`)
```text
--filter-tcp=443 --dpi-desync=fake --dpi-desync-ttl=6 --dpi-desync-repeats=2
```
* **Mechanism:** Setting the fake packet's TTL explicitly to **6** ensures that:
  - The packet survives through Hops 1, 2, 3, 4, and 5.
  - It hits the DPI middlebox at Hop 6 with TTL=1, poisoning the DPI state table and marking the TCP stream as "safe/processed".
  - At Hop 6, the TTL decrements to 0 and the fake packet is discarded.
  - The real TLS handshake packet (carrying standard TTL=64 or 128) passes through Hop 6 unimpeded.

### Strategy 2: Sequence Overlap (`multidisorder`)
```text
--filter-tcp=443 --dpi-desync=multidisorder --dpi-desync-split-pos=2,midsld --dpi-desync-split-seqovl=1
```
* **Mechanism:** Rather than generating fake packets, this method splits the real `ClientHello` into multiple overlapping pieces and transmits them out-of-order. The 1-byte sequence overlap (`split-seqovl=1`) corrupts the DPI stream-reassembly buffer while modern OS TCP stacks reassemble the payload without error.
