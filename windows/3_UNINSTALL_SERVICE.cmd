@echo off
setlocal
title Uninstall Zapret Service
cd /d "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Requesting Administrator elevation...
    "%~dp0zapret-winws\elevator.exe" "%~f0" %*
    exit /b
)

echo Stopping zapret service...
net stop zapret >nul 2>&1
echo Deleting zapret service...
sc delete zapret >nul 2>&1

echo Stopping any leftover processes...
taskkill /IM winws.exe /F >nul 2>&1
taskkill /IM winws2.exe /F >nul 2>&1

echo Unloading WinDivert driver...
sc stop windivert >nul 2>&1
sc delete windivert >nul 2>&1

echo.
echo [SUCCESS] Zapret service has been completely removed.
echo.
pause
