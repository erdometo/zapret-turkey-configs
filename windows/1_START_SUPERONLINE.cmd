@echo off
setlocal
title Zapret DPI Bypass (Superonline Hop-Immune)
cd /d "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Requesting Administrator elevation...
    "%~dp0zapret-winws\elevator.exe" "%~f0" %*
    exit /b
)

echo ================================================================
echo    ZAPRET DPI BYPASS - SUPERONLINE HOP-IMMUNE (MULTIDISORDER)
echo ================================================================
echo.
echo Stopping any existing instances...
taskkill /IM winws.exe /F >nul 2>&1
taskkill /IM winws2.exe /F >nul 2>&1

echo Starting Zapret engine (winws.exe)...
echo.
echo Active Features:
echo  - HTTPS (TCP 443): MultiDisorder Sequence Overlap (Immune to router hops)
echo  - HTTP  (TCP 80):  Fake Request + Fakedsplit Desync
echo  - QUIC  (UDP 443): Fake Initial Handshakes (HTTP/3 protection)
echo  - Discord / STUN:  UDP Voice and Media Packet Desync
echo.
echo [STATUS] Running. Keep this window open while browsing.
echo          To stop, close this window or run 4_STOP_ZAPRET.cmd.
echo ================================================================
echo.

"%~dp0zapret-winws\winws.exe" ^
--wf-tcp=80,443 ^
--wf-udp=443 ^
--wf-raw-part=@"%~dp0zapret-winws\windivert.filter\windivert_part.discord_media.txt" ^
--wf-raw-part=@"%~dp0zapret-winws\windivert.filter\windivert_part.stun.txt" ^
--wf-raw-part=@"%~dp0zapret-winws\windivert.filter\windivert_part.quic_initial_ietf.txt" ^
--filter-tcp=80 --dpi-desync=fake,fakedsplit --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --new ^
--filter-tcp=443 --dpi-desync=multidisorder --dpi-desync-split-pos=2,midsld --dpi-desync-split-seqovl=1 --new ^
--filter-l7=quic --dpi-desync=fake --dpi-desync-repeats=11 --new ^
--filter-l7=discord,stun --dpi-desync=fake
