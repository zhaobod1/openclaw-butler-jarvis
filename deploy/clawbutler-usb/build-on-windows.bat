@echo off
chcp 65001 >nul
title 龙虾管家 - Windows 构建

echo ========================================
echo    龙虾管家 - Windows 安装包构建
echo    青岛火一五信息科技有限公司
echo ========================================
echo.

REM Check Node.js
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未找到 Node.js，请先安装 Node.js 18+
    echo 下载: https://nodejs.org/
    pause
    exit /b 1
)

echo [1/4] Node.js 版本: 
node -v

REM Check pnpm
where pnpm >nul 2>&1
if %errorlevel% neq 0 (
    echo [信息] 未找到 pnpm，正在安装...
    corepack enable
    call corepack prepare pnpm@latest --activate
)

echo [2/4] 安装依赖...
call pnpm install
if %errorlevel% neq 0 (
    echo [错误] 依赖安装失败
    pause
    exit /b 1
)

echo [3/4] 构建前端...
call pnpm run build:vite
if %errorlevel% neq 0 (
    echo [错误] 前端构建失败
    pause
    exit /b 1
)

echo [4/4] 打包安装程序...
echo 目标: Windows x64 + ia32 (NSIS)
set "ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/"
call pnpm exec electron-builder --win --x64
if %errorlevel% neq 0 (
    echo [错误] 打包失败
    pause
    exit /b 1
)

echo.
echo ========================================
echo    构建完成！
echo    安装包在: release\龙虾管家-*-setup.exe
echo ========================================
echo.
echo 部署聚星逸配置：运行 deploy\deploy-juxingyi.bat
echo.
pause
