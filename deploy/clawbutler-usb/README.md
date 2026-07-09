# 龙虾管家 — Win11 x64 USB 部署包

青岛火一五信息科技有限公司

## 使用方法

1. 将 CLAWBUTLER U 盘插入 **Windows 11 x64** 电脑
2. 运行 `build-on-windows.bat` 构建安装包（需 Node.js 18+ + pnpm）
3. 运行生成的 `release\龙虾管家-*-setup.exe` 安装

## 包含

- 龙虾管家 (fork of ClawX v0.4.15) 完整源码
- 聚星逸 AI provider 默认配置（含 API key，开箱即用）
- Windows 构建脚本

## 构建后

构建完成后，运行 `deploy/deploy-juxingyi.bat` 部署聚星逸配置。

> 联系人：support@huo15.com | QQ 群：1093992108
