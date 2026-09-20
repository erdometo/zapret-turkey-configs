@echo off
setlocal
title Stop Zapret
cd /d "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Requesting Administrator elevation...
    "%~dp0zapret-winws\elevator.exe" "%~f0" %*
    exit /b
)

echo Stopping winws processes...
taskkill /IM winws.exe /F >nul 2>&1
taskkill /IM winws2.exe /F >nul 2>&1

echo Stopping service if active...
net stop zapret >nul 2>&1

echo Unloading WinDivert driver...
sc stop windivert >nul 2>&1

echo.
echo [STATUS] Zapret has been stopped.
timeout /t 3 >nul
