@echo off
setlocal
title Restart Zapret Service
cd /d "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    "%~dp0zapret-winws\elevator.exe" "%~f0" %*
    exit /b
)

echo Restarting Zapret Service...
net stop zapret
taskkill /IM winws.exe /F >nul 2>&1
net start zapret
echo [SUCCESS] Zapret restarted.
timeout /t 3 >nul
