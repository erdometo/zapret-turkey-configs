@echo off
setlocal
title Update Zapret Binaries from Upstream
cd /d "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Administrator elevation required. Requesting permission...
    "%~dp0zapret-winws\elevator.exe" "%~f0" %*
    exit /b
)

echo ================================================================
echo       ZAPRET BINARY UPDATER (OFFICIAL UPSTREAM RELEASES)
echo ================================================================
echo.

echo Checking latest release from github.com/bol-van/zapret...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$ProgressPreference = 'SilentlyContinue';" ^
    "try {" ^
    "    $release = Invoke-RestMethod -Uri 'https://api.github.com/repos/bol-van/zapret/releases/latest';" ^
    "    $tag = $release.tag_name;" ^
    "    Write-Host '[INFO] Latest upstream version available:' $tag;" ^
    "    $asset = $release.assets | Where-Object { $_.name -like 'zapret-*.zip' } | Select-Object -First 1;" ^
    "    if (-not $asset) { Write-Host '[ERROR] No zip asset found.'; exit 1 };" ^
    "    $tempZip = Join-Path $env:TEMP 'zapret_update.zip';" ^
    "    $tempExtract = Join-Path $env:TEMP 'zapret_extracted_update';" ^
    "    Write-Host '[INFO] Downloading' $asset.browser_download_url '...';" ^
    "    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $tempZip;" ^
    "    Write-Host '[INFO] Extracting binaries...';" ^
    "    if (Test-Path $tempExtract) { Remove-Item $tempExtract -Recurse -Force };" ^
    "    Expand-Archive -LiteralPath $tempZip -DestinationPath $tempExtract -Force;" ^
    "    $binSource = Get-ChildItem -Path $tempExtract -Recurse | Where-Object { $_.FullName -like '*binaries\windows-x86_64' } | Select-Object -First 1;" ^
    "    if (-not $binSource) { Write-Host '[ERROR] windows-x86_64 binaries not found in archive.'; exit 1 };" ^
    "    $targetDir = Join-Path (Get-Location) 'zapret-winws';" ^
    "    Write-Host '[INFO] Updating winws.exe, WinDivert, and libraries in' $targetDir '...';" ^
    "    Copy-Item -Path (Join-Path $binSource.FullName '*') -Destination $targetDir -Force;" ^
    "    Remove-Item $tempZip, $tempExtract -Recurse -Force -ErrorAction SilentlyContinue;" ^
    "    Write-Host '[SUCCESS] Zapret core binaries updated to' $tag 'successfully!';" ^
    "} catch {" ^
    "    Write-Host '[ERROR] Update failed:' $_.Exception.Message;" ^
    "    exit 1;" ^
    "}"

echo.
echo ================================================================
pause
