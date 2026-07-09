# 龙虾管家（ClawX Fork）产品需求文档

> 版本: v1.0 | 日期: 2026-07-09 | 状态: 初版

---

## 1. 产品概述

### 1.1 产品定位

**龙虾管家**是基于 OpenClaw AI Agent 运行时的桌面图形客户端，为用户提供可视化界面来管理、交互和监控 AI Agent。

本质上是 [ClawX](https://github.com/ValueCell-ai/ClawX) 的深度品牌定制 fork。ClawX 是 OpenClaw 生态的官方 Electron 桌面客户端，支持 macOS / Windows / Linux 三平台。

### 1.2 目标用户

- 需要桌面级 AI Agent 管理界面的个人/企业用户
- 使用聚星逸聚合平台（默认 AI Provider）的用户
- 需要预配置、开箱即用的 OpenClaw 用户

### 1.3 核心竞争力

1. **预配置聚星逸**: 开箱即用，无需手动添加 AI Provider
2. **品牌统一**: 面向中国用户的完整本地化（i18n + 品牌）
3. **便携部署**: USB 分发，Windows 一键安装

---

## 2. 功能范围

### 2.1 MVP（v1.0 — 已完成）

| 功能 | 状态 | 说明 |
|------|------|------|
| 品牌重命名 | ✅ 已完成 | ClawX→龙虾管家，全链路品牌替换 |
| 中文 i18n | ✅ 已完成 | zh locale 全部 ClawX→龙虾管家 |
| 图标替换 | ✅ 已完成 | claw-butler 龙虾 logo（.svg/.png/.ico/.icns） |
| 聚星逸默认配置 | ✅ 已完成 | `deploy/juxingyi-openclaw.json` |
| Windows NSIS 安装包 | ✅ 已完成 | 配置 x64 + ia32 双目标 |
| 用户可见字符串 | ✅ 已完成 | tray、Sidebar、Setup、IDENTITY.md、启动项 |
| USB 便携部署包 | ✅ 已完成 | `deploy/clawbutler-usb/` + `build-on-windows.bat` |

### 2.2 后续迭代（待定）

| 功能 | 优先级 | 说明 |
|------|--------|------|
| 聚星逸 provider 深度集成 | 高 | 代码级 seed，而非 post-install 配置合并 |
| 自动更新通道 | 中 | 替换上游 GitHub Releases 为 OSS 国内加速 |
| 企业版功能 | 低 | AD/LDAP 集成、审计日志、策略管控 |

---

## 3. 技术架构

### 3.1 架构概览

```
┌─────────────────────────────────────┐
│        龙虾管家 (Electron)           │
│  ┌───────────┐  ┌────────────────┐  │
│  │ Renderer  │  │  Main Process  │  │
│  │ (React 19)│◄─┤ (Electron 40+) │  │
│  │ Vite + TS │  │  host-api      │  │
│  └─────┬─────┘  └───────┬────────┘  │
│        │ IPC            │            │
│        └────────────────┘            │
└─────────────────────────────────────┘
              │ WebSocket
              ▼
┌─────────────────────────────────────┐
│    OpenClaw Gateway (端口 18789)    │
│  ┌──────────┐  ┌──────────────────┐ │
│  │ Runtime  │  │  Provider Proxy  │ │
│  │ Agent    │  │  (聚星逸/其他)    │ │
│  └──────────┘  └──────────────────┘ │
└─────────────────────────────────────┘
```

### 3.2 技术栈

| 层 | 技术 |
|----|------|
| 桌面框架 | Electron 40+ |
| 前端框架 | React 19 + TypeScript |
| 构建工具 | Vite |
| 包管理 | pnpm（corepack 锁定版本） |
| 状态管理 | Zustand |
| i18n | react-i18next（en/zh/ja/ru） |
| 打包 | electron-builder (NSIS/DMG/AppImage) |
| 测试 | Vitest + Playwright |

### 3.3 关键路径

| 路径 | 说明 |
|------|------|
| `electron/main/` | Electron 主进程入口、IPC handler |
| `electron/utils/` | OpenClaw 上下文管理、配置同步、安全存储 |
| `electron/services/` | Provider 管理、Agent API、Secret 存储 |
| `electron/gateway/` | Gateway 通信（WS 客户端、配置同步） |
| `src/` | React 渲染进程（页面、组件、Store） |
| `shared/i18n/` | 四个语言的 i18n 资源文件 |

---

## 4. 设计原则

1. **增强不侵入**: 不修改 OpenClaw 核心代码，只在 ClawX 外壳层定制
2. **品牌统一**: 所有用户可见处保持龙虾管家品牌标识
3. **开箱即用**: 预配置默认 AI Provider，减少用户配置步骤
4. **非侵入配置**: 不自动修改用户已有配置，通过 deploy 脚本引导

---

## 5. 竞品对比

| 产品 | 定位 | 差异 |
|------|------|------|
| **ClawX（上游）** | OpenClaw 官方桌面 | 英文为主，需自配 Provider |
| **OpenClaw CLI** | 命令行界面 | 无需 GUI，功能完整 |
| **OpenCami** | OpenClaw Web 客户端 | 浏览器端，无需安装 |
| **龙虾管家（本产品）** | 中国用户定制桌面 | 中文品牌、聚星逸预装、USB 分发 |

---

## 6. 分发策略

- **GitHub 仓库**: `git@github.com:zhaobod1/openclaw-butler-jarvis.git`
- **USB 便携包**: `deploy/clawbutler-usb/` — 直接复制到 U 盘即用
- **Windows 安装包**: 在 Windows 上运行 `build-on-windows.bat` 构建

---

## 7. 产品路线图

### v1.0 (当前 — 2026-07-09)
- ✅ 品牌定制全部完成
- ✅ 中文 i18n 覆盖
- ✅ 聚星逸预配置模板
- ✅ USB 打包脚本

### v1.1 (计划)
- [ ] 聚星逸 provider 代码级 seed
- [ ] 自动更新 OSS 通道
- [ ] 用户反馈闭环
