# Windows Usage Guide

## Recommended Setup (Hop-Immune MultiDisorder)
1. **Interactive Run (Test First):**
   * Double-click `1_START_SUPERONLINE.cmd` and click **Yes** on the UAC prompt.
   * This uses the **MultiDisorder sequence-overlap desync** with QUIC (HTTP/3) and Discord voice support.
   * Because it does not rely on TTL counting, it will **never break** if you switch between your main modem and a secondary Wi-Fi router/extender.
2. **Permanent Background Service (Set & Forget):**
   * Double-click `2_INSTALL_SERVICE.cmd`.
   * Zapret will run silently as a Windows background service every time your PC boots.
3. **Uninstalling:**
   * Double-click `3_UNINSTALL_SERVICE.cmd` to cleanly remove the service and unload the driver.

## Fallback Profiles
* `1_START_SUPERONLINE_TTL_FALLBACK.cmd`: Uses the calibrated `TTL=6` fake packet strategy. (Note: Only use if you are directly connected to the main Superonline fiber modem without intermediate routers).
* `2_INSTALL_SERVICE_TTL_FALLBACK.cmd`: Installs the TTL=6 strategy as a Windows service.

## Upstream Updates
* Double-click `update_zapret.cmd` to check for and download new releases of `winws.exe` and `WinDivert` drivers from the official `bol-van/zapret` repository.
