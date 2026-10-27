@echo off
setlocal
title Zapret DPI Bypass (Superonline TTL Fallback)
cd /d "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Requesting Administrator elevation...
    "%~dp0zapret-winws\elevator.exe" "%~f0" %*
    exit /b
)

echo ================================================================
echo       ZAPRET DPI BYPASS - SUPERONLINE TTL FALLBACK PRESET
echo ================================================================
echo.
echo [NOTE] TTL strategies require direct modem connection (Hop 6).
echo        If behind an extra router/extender, use the main MultiDisorder script.
echo.
echo Stopping any existing instances...
taskkill /IM winws.exe /F >nul 2>&1
taskkill /IM winws2.exe /F >nul 2>&1

echo Starting Zapret engine (TTL=6)...
echo.

"%~dp0zapret-winws\winws.exe" ^
--wf-tcp=80,443 ^
--wf-udp=443 ^
--wf-raw-part=@"%~dp0zapret-winws\windivert.filter\windivert_part.discord_media.txt" ^
--wf-raw-part=@"%~dp0zapret-winws\windivert.filter\windivert_part.stun.txt" ^
--wf-raw-part=@"%~dp0zapret-winws\windivert.filter\windivert_part.quic_initial_ietf.txt" ^
--filter-tcp=80 --dpi-desync=fake,fakedsplit --dpi-desync-ttl=6 --new ^
--filter-tcp=443 --dpi-desync=fake --dpi-desync-ttl=6 --dpi-desync-repeats=2 --new ^
--filter-l7=quic --dpi-desync=fake --dpi-desync-repeats=11 --new ^
--filter-l7=discord,stun --dpi-desync=fake
