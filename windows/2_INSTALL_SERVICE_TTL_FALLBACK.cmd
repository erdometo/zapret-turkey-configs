@echo off
setlocal
title Install Zapret Service (Superonline TTL Fallback)
cd /d "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Requesting Administrator elevation...
    "%~dp0zapret-winws\elevator.exe" "%~f0" %*
    exit /b
)

echo ================================================================
echo    INSTALLING ZAPRET SERVICE (SUPERONLINE TTL FALLBACK)
echo ================================================================
echo.

set "BIN_DIR=%~dp0zapret-winws"
set "ARGS=--wf-tcp=80,443 --wf-udp=443 --wf-raw-part=@\"%BIN_DIR%\windivert.filter\windivert_part.discord_media.txt\" --wf-raw-part=@\"%BIN_DIR%\windivert.filter\windivert_part.stun.txt\" --wf-raw-part=@\"%BIN_DIR%\windivert.filter\windivert_part.quic_initial_ietf.txt\" --filter-tcp=80 --dpi-desync=fake,fakedsplit --dpi-desync-ttl=6 --new --filter-tcp=443 --dpi-desync=fake --dpi-desync-ttl=6 --dpi-desync-repeats=2 --new --filter-l7=quic --dpi-desync=fake --dpi-desync-repeats=11 --new --filter-l7=discord,stun --dpi-desync=fake"

echo Stopping any existing service...
net stop zapret >nul 2>&1
sc delete zapret >nul 2>&1

echo Stopping any running winws processes...
taskkill /IM winws.exe /F >nul 2>&1
taskkill /IM winws2.exe /F >nul 2>&1

echo Registering Windows service...
sc create zapret binPath= "\"%BIN_DIR%\winws.exe\" %ARGS%" DisplayName= "Zapret DPI Bypass (Superonline TTL=6)" start= auto
sc description zapret "Zapret Deep Packet Inspection circumvention service for Superonline (TTL=6)"

echo Starting zapret service...
sc start zapret

echo.
echo ================================================================
echo [SUCCESS] Zapret is installed and running with TTL=6!
echo ================================================================
pause
