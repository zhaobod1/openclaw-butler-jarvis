@echo off
title Claw Butler - Windows Build
setlocal enabledelayedexpansion

REM ==================== Change to project root ====================
cd /d "%~dp0"
if exist "source\package.json" (
    cd source
) else if exist "..\..\package.json" (
    cd ..\..\
)
echo    Project root: %CD%
echo.

REM Set node-linker=hoisted for exFAT USB drives (pnpm symlinks not supported)
set "PNPM_CONFIG_NODE_LINKER=hoisted"

echo ========================================
echo    Claw Butler - Windows Build
echo    Huo15 Tech
echo ========================================
echo.

REM ==================== 0. Antivirus Warning ====================
echo [!] IMPORTANT: Please disable antivirus software before running this script.
echo     Windows Defender / 360 / other antivirus may block Node.js installation.
echo.
echo     To disable Windows Defender Real-time Protection:
echo       1. Open Windows Security
echo       2. Virus ^& threat protection
echo       3. Manage settings
echo       4. Turn off Real-time protection
echo.
echo     Press any key to continue, or Ctrl+C to exit...
pause >nul
echo.

REM ==================== 1. Check/Install Node.js ====================
echo [1/5] Checking Node.js...
where node >nul 2>&1
if %errorlevel% equ 0 (
    node -v
    goto :check_pnpm
)

echo    Node.js NOT found. Installing via nvm-windows...
echo.

REM Download nvm-windows (noinstall version)
set "NVM_VER=1.2.2"
set "NVM_DIR=%TEMP%\nvm"
set "NVM_ZIP=%TEMP%\nvm.zip"

if not exist "%NVM_DIR%" mkdir "%NVM_DIR%"

echo    Downloading nvm-windows %NVM_VER%...
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://github.com/coreybutler/nvm-windows/releases/download/%NVM_VER%/nvm-noinstall.zip' -OutFile '%NVM_ZIP%' -UseBasicParsing"
if %errorlevel% neq 0 (
    echo    [ERROR] Download failed. Check internet connection.
    pause
    exit /b 1
)

echo    Extracting...
powershell -Command "Expand-Archive -Path '%NVM_ZIP%' -DestinationPath '%NVM_DIR%' -Force"

REM Create settings.txt for nvm-windows noinstall (required before first use)
(
    echo root: %NVM_DIR%
    echo path: C:\Program Files\nodejs
    echo arch: 64
    echo proxy: none
) > "%NVM_DIR%\settings.txt"

REM Setup nvm env
set "NVM_HOME=%NVM_DIR%"
set "PATH=%NVM_DIR%;%PATH%"

echo    Installing Node.js LTS...
"%NVM_DIR%\nvm.exe" install lts
if %errorlevel% neq 0 (
    echo    [ERROR] Node.js install failed
    echo    Please disable antivirus and try again
    pause
    exit /b 1
)

"%NVM_DIR%\nvm.exe" use lts

REM Get nvm current node path and refresh PATH
for /f "tokens=*" %%i in ('"%NVM_DIR%\nvm.exe" current 2^>nul') do set "NODE_VER=%%i"
if exist "%NVM_DIR%\%NODE_VER%" set "PATH=%NVM_DIR%\%NODE_VER%;%PATH%"

where node >nul 2>&1
if %errorlevel% neq 0 (
    echo    [ERROR] Node.js not in PATH after install
    echo    Try reopening a new cmd window
    pause
    exit /b 1
)

echo    Node.js installed:
node -v
echo.

:check_pnpm
REM ==================== 2. Setup pnpm ====================
echo [2/5] Checking pnpm...
where pnpm >nul 2>&1
if %errorlevel% equ 0 (
    pnpm -v
    goto :set_mirror
)

echo    Installing pnpm via corepack...
corepack enable
corepack prepare pnpm@latest --activate
if %errorlevel% neq 0 (
    echo    corepack failed, trying npm install...
    npm install -g pnpm
)
pnpm -v
echo.

:set_mirror
REM ==================== 3. Set Taobao Mirror ====================
echo [3/5] Setting Taobao mirror...
npm config set registry https://registry.npmmirror.com
pnpm config set registry https://registry.npmmirror.com
set "ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/"
set "ELECTRON_BUILDER_BINARIES_MIRROR=https://npmmirror.com/mirrors/electron-builder-binaries/"
echo    npm:  https://registry.npmmirror.com
echo    electron: %ELECTRON_MIRROR%

REM Set node-linker=hoisted for exFAT USB drives (pnpm symlinks not supported)
echo    Setting node-linker=hoisted for exFAT compatibility...
pnpm config set node-linker hoisted --location=project
echo.

REM ==================== 4. Install + Build ====================
echo [4/5] Installing dependencies...
call pnpm install
if %errorlevel% neq 0 (
    echo    [ERROR] pnpm install failed
    pause
    exit /b 1
)

echo    Building frontend...
call pnpm run build:vite
if %errorlevel% neq 0 (
    echo    [ERROR] Build failed
    pause
    exit /b 1
)
echo.

REM ==================== 5. Package ====================
echo [5/5] Packaging installer...
echo    Target: Windows x64
set "ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/"
set "ELECTRON_BUILDER_BINARIES_MIRROR=https://npmmirror.com/mirrors/electron-builder-binaries/"

call pnpm exec electron-builder --win --x64
if %errorlevel% neq 0 (
    echo    [ERROR] Packaging failed
    pause
    exit /b 1
)

echo.
echo ========================================
echo    BUILD COMPLETE!
echo    Installer: release\*-x64-setup.exe
echo ========================================
echo.
echo    To install Juxingyi provider:
echo      deploy\deploy-juxingyi.bat
echo.
pause
