# AGENTS.md — 龙虾管家 (ClawX Fork)

## 概述

**龙虾管家**是 OpenClaw AI Agent 运行时的桌面图形界面，基于上游 [ValueCell-ai/ClawX](https://github.com/ValueCell-ai/ClawX) v0.4.15 fork。

技术栈：Electron 40+ / React 19 / Vite / TypeScript / pnpm（版本锁定在 `package.json#packageManager`）。

## 快速参考

| 任务 | 命令 |
|------|------|
| 初始化（装依赖 + 下载 uv） | `pnpm run init` |
| 开发服务器（Vite + Electron） | `pnpm dev` |
| Lint | `pnpm run lint` |
| Typecheck | `pnpm run typecheck` |
| 单元测试 | `pnpm test` |
| E2E 测试 | `pnpm run test:e2e` |
| 构建前端 | `pnpm run build:vite` |

## 品牌定制（本 fork 特有）

- **中文名**: 龙虾管家（productName）
- **英文名**: Claw Butler（en/ja/ru locale）
- **appId**: `com.huo15.clawbutler`
- **图标**: claw-butler 龙虾 logo（`resources/icons/`）
- **中文 i18n**: zh locale（龙虾管家）
- **英文 i18n**: en/ja/ru locale（Claw Butler → 已全量替换）
- **默认 AI Provider**: 聚星逸（首次启动自动 seed，代码在 `electron/utils/juxingyi-provider.ts`）
- **客服菜单**: 帮助 → 客服 → 逸寻智库二维码弹窗（`electron/utils/customer-service.ts`）

## 仓库

| 远端 | URL | 说明 |
|------|-----|------|
| origin | `git@github.com:zhaobod1/openclaw-butler-jarvis.git` | GitHub 主仓库 |
| 上游 | `https://github.com/ValueCell-ai/ClawX` | ClawX 官方（只读参考） |

## 目录结构

```
├── AGENTS.md              ← 本文件（Claude 自动加载）
├── .claude/               ← Claude 项目配置
├── docs/                  ← 文档
│   ├── PRD.md             ← 产品需求文档
│   ├── user-sop.md        ← 用户手册
│   ├── developer-sop.md   ← 开发者 SOP
│   └── decisions/         ← 架构决策记录 (ADR)
├── electron/              ← Electron 主进程
├── src/                   ← React 渲染进程
├── shared/                ← 主进程/渲染进程共享代码
├── resources/             ← 图标、CLI 二进制、预装技能
├── deploy/                ← 部署资产（聚星逸配置、构建脚本）
└── scripts/               ← 构建脚本
```

## 开发须知

- **不要推送到上游**：我们 fork ValueCell-ai/ClawX，只推 origin。
- **Gateway 端口**: 18789，开发时自动启动。
- **无数据库**: 使用 `electron-store`（JSON 文件）+ 系统钥匙串。
- **不要直接调用 Gateway HTTP**: 通过 Main 进程代理通道（`hostapi:fetch`, `gateway:httpProxy`）。
- **i18n**: 新增用户可见字符串必须覆盖 `en/zh/ja/ru` 四个 locale。
- **Windows 构建**: 只能在 Windows 上构建（macOS 交叉编译需 Wine，未验证）。

## 发布流程

参考 `docs/developer-sop.md` § 发布流程。
