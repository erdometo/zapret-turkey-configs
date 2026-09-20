@echo off
setlocal
title Zapret DPI Bypass (Superonline MultiDisorder)
cd /d "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Requesting Administrator elevation...
    "%~dp0zapret-winws\elevator.exe" "%~f0" %*
    exit /b
)

echo ================================================================
echo      ZAPRET DPI BYPASS - SUPERONLINE MULTI-DISORDER (SEQ-OVL)
echo ================================================================
echo.
echo Stopping any existing instances...
taskkill /IM winws.exe /F >nul 2>&1
taskkill /IM winws2.exe /F >nul 2>&1

echo Starting Zapret with sequence-overlapping desync...
echo [STATUS] Running. Keep this window open while browsing.
echo.

"%~dp0zapret-winws\winws.exe" ^
--wf-tcp=80,443 ^
--wf-raw-part=@"%~dp0zapret-winws\windivert.filter\windivert_part.discord_media.txt" ^
--wf-raw-part=@"%~dp0zapret-winws\windivert.filter\windivert_part.stun.txt" ^
--filter-tcp=80 --dpi-desync=fake,fakedsplit --dpi-desync-ttl=6 --new ^
--filter-tcp=443 --dpi-desync=multidisorder --dpi-desync-split-pos=2,midsld --dpi-desync-split-seqovl=1 --new ^
--filter-l7=discord,stun --dpi-desync=fake
