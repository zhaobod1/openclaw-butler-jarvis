@echo off
title Deploy Juxingyi Provider

set "OPENCLAW_DIR=%USERPROFILE%\.openclaw"
set "CONFIG_FILE=%OPENCLAW_DIR%\openclaw.json"
set "TEMPLATE=%~dp0juxingyi-openclaw.json"

if not exist "%OPENCLAW_DIR%" (
    mkdir "%OPENCLAW_DIR%"
)

if not exist "%CONFIG_FILE%" (
    echo Copying initial config...
    copy "%TEMPLATE%" "%CONFIG_FILE%"
) else (
    echo Merging Juxingyi config into existing openclaw.json...
    echo Please manually merge providers and agents.defaults from:
    echo   %TEMPLATE%
    echo to:
    echo   %CONFIG_FILE%
    echo.
    echo Or run the Node.js merge tool (requires Node 18+):
    echo   node %~dp0merge-config.mjs
)

echo Done!
pause
