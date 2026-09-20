# Windows Usage Guide

## Quick Start
1. **Interactive Run:** Double-click `1_START_SUPERONLINE_TTL6.cmd` and approve the UAC elevation prompt. Keep the console window open while browsing.
2. **Background Service (Recommended):** Double-click `2_INSTALL_SERVICE.cmd`. This installs and starts Zapret as a native Windows service running invisibly on boot.
3. **Uninstall:** Run `3_UNINSTALL_SERVICE.cmd` anytime to cleanly remove the service.

## Fallback Profile
If specific servers behave inconsistently with TTL=6, use `1_START_SUPERONLINE_DISORDER.cmd`, which uses TCP sequence overlapping (`multidisorder`) instead of fake packets.
