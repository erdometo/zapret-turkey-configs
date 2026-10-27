@echo off
setlocal
title Install Zapret Service (Superonline MultiDisorder - Hop-Immune)
cd /d "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Administrator rights required. Requesting elevation...
    "%~dp0zapret-winws\elevator.exe" "%~f0" %*
    exit /b
)

echo ================================================================
echo    INSTALLING ZAPRET SERVICE (SUPERONLINE MULTI-DISORDER)
echo ================================================================
echo.

set "BIN_DIR=%~dp0zapret-winws"
set "ARGS=--wf-tcp=80,443 --wf-raw-part=@\"%BIN_DIR%\windivert.filter\windivert_part.discord_media.txt\" --wf-raw-part=@\"%BIN_DIR%\windivert.filter\windivert_part.stun.txt\" --filter-tcp=80 --dpi-desync=fake,fakedsplit --dpi-desync-ttl=7 --new --filter-tcp=443 --dpi-desync=multidisorder --dpi-desync-split-pos=2,midsld --dpi-desync-split-seqovl=1 --new --filter-l7=discord,stun --dpi-desync=fake"

echo Stopping any existing service...
net stop zapret >nul 2>&1
sc delete zapret >nul 2>&1

echo Stopping any running winws processes...
taskkill /IM winws.exe /F >nul 2>&1
taskkill /IM winws2.exe /F >nul 2>&1

echo Registering Windows service...
sc create zapret binPath= ""%BIN_DIR%\winws.exe" %ARGS%" DisplayName= "Zapret DPI Bypass (Superonline MultiDisorder)" start= auto
sc description zapret "Zapret Deep Packet Inspection circumvention service for Superonline (Hop-Immune)"

echo Starting zapret service...
sc start zapret

echo.
echo ================================================================
echo [SUCCESS] Zapret is now installed and running with MultiDisorder!
echo This mode is immune to local router / Wi-Fi hop count changes.
echo ================================================================
pause
