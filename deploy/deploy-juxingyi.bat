@echo off
chcp 65001 >nul
title 聚星逸配置部署

set "OPENCLAW_DIR=%USERPROFILE%\.openclaw"
set "CONFIG_FILE=%OPENCLAW_DIR%\openclaw.json"
set "TEMPLATE=%~dp0juxingyi-openclaw.json"

if not exist "%OPENCLAW_DIR%" (
    mkdir "%OPENCLAW_DIR%"
)

if not exist "%CONFIG_FILE%" (
    echo 复制初始配置...
    copy "%TEMPLATE%" "%CONFIG_FILE%"
) else (
    echo 合并聚星逸配置到现有 openclaw.json...
    echo 请手动将 %TEMPLATE% 的 providers 和 agents.defaults 合并到 %CONFIG_FILE%
    echo.
    echo 或运行 Node.js 合并工具（需 Node 18+）：
    echo   node %~dp0merge-config.mjs
)

echo 完成！
pause
