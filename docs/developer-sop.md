# 龙虾管家 — 开发者 SOP

> 版本: v1.0 | 最后更新: 2026-07-09

---

## 1. 环境搭建

### 1.1 系统依赖

| 依赖 | 版本要求 | 安装方式 |
|------|---------|---------|
| Node.js | >= 18 | [nodejs.org](https://nodejs.org/) |
| pnpm | latest (corepack) | `corepack enable && corepack prepare` |
| Git | latest | 系统包管理器 |
| Electron | 40+ | pnpm 自动安装 |

### 1.2 国内镜像加速

```bash
# npm 镜像
npm config set registry https://registry.npmmirror.com

# Electron 镜像
export ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/

# Git 代理（如需）
export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890
```

### 1.3 首次运行

```bash
git clone git@github.com:zhaobod1/openclaw-butler-jarvis.git
cd openclaw-butler-jarvis
corepack enable && corepack prepare pnpm@latest --activate
pnpm run init      # = pnpm install + pnpm run uv:download
pnpm dev           # 启动 Vite + Electron 开发服务器
```

---

## 2. 开发流程

### 2.1 代码约定

| 约定 | 规则 |
|------|------|
| TypeScript | 严格模式 |
| i18n | 新字符串须覆盖 en/zh/ja/ru 四个 locale |
| React | 函数组件 + Hooks |
| 状态管理 | Zustand store |
| CSS | Tailwind CSS + 设计 token（`src/styles/globals.css`） |
| Git 提交 | 语义化提交（`feat:` / `fix:` / `chore:`） |

### 2.2 新增页面/组件

```typescript
// 1. i18n 资源 (shared/i18n/locales/<lang>/<ns>.json)
// 2. 组件 (src/components/ 或 src/pages/)
// 3. E2E 测试 (tests/e2e/)
// 4. 更新 README 和相关文档
```

### 2.3 IPC 通信约定

```
Renderer --[host-api]--> Main Process --[WS]--> Gateway --[HTTP]--> OpenClaw Runtime
```

**铁律**：
- Renderer 必须通过 `src/lib/host-api.ts` 调用后端
- 不直接 `window.electron.ipcRenderer.invoke()`
- 不直接 `fetch('http://127.0.0.1:18789/...')`
- 不直接调用 Gateway HTTP 端点

### 2.4 构建命令

| 命令 | 说明 |
|------|------|
| `pnpm dev` | 开发模式（热更新） |
| `pnpm run build:vite` | 仅构建前端 |
| `pnpm exec electron-builder --win --x64` | Windows x64 安装包 |
| `pnpm exec electron-builder --mac` | macOS DMG |
| `pnpm exec electron-builder --linux` | Linux AppImage/deb/rpm |

---

## 3. 品牌定制指南（本 fork 特有）

### 3.1 品牌字符串替换清单

| 文件/位置 | 替换内容 |
|-----------|---------|
| `electron-builder.yml` | `productName`, `appId`, `copyright`, `artifactName`, NSIS 名 |
| `package.json` | `name`, `description`, `author` |
| `electron/main/tray.ts` | Tooltip, Context menu labels |
| `electron/main/launch-at-startup.ts` | Linux desktop entry |
| `electron/utils/openclaw-workspace.ts` | IDENTITY.md 内容 |
| `electron/utils/openclaw-cli.ts` | `OPENCLAW_EMBEDDED_IN` |
| `electron/gateway/ws-client.ts` | `displayName` |
| `electron/shared/providers/registry.ts` | `X-OpenRouter-Title` |
| `electron/gateway/process-launcher.ts` | `X-OpenRouter-Title` |
| `index.html` | `<title>` |
| `src/components/layout/Sidebar.tsx` | Logo alt + 品牌名 |
| `src/pages/Setup/index.tsx` | Logo alt |
| `shared/i18n/locales/zh/*.json` | ClawX→龙虾管家 |
| `resources/icons/*` | 全部图标替换为龙虾 logo |

### 3.2 图标生成

```bash
# 前提: 安装依赖
pnpm install    # 安装 sharp + png2icons

# 在 resources/icons/ 下准备 icon.svg（龙虾 logo SVG）
node scripts/generate-icons.mjs
```

生成产物:
- `icon.png` (512x512) — Electron 根图标
- `icon.ico` — Windows 图标（安装程序 + 可执行文件）
- `icon.icns` — macOS 图标
- `256x256.png` / `128x128.png` / `64x64.png` / `48x48.png` / `32x32.png` / `16x16.png`

### 3.3 聚星逸 Provider 配置

| 配置 | 值 |
|------|-----|
| Provider ID | `juxingyi` |
| Base URL | `https://fireworks-simulator-api.huo15.com/v1` |
| API Key | `fsk-3Ycmtx_ZXCLSuKFHB-KePCChLPLRvBll` |
| 默认模型 | `deepseek-v4-flash-free` |

配置模板: `deploy/juxingyi-openclaw.json`

部署方式: 合并到 `~/.openclaw/openclaw.json` 的 `providers[]` 和 `agents.defaults`。

---

## 4. 发布流程

### 4.1 版本号管理

| 位置 | 说明 |
|------|------|
| `package.json` | `version` — npm 发布版本（遵循 semver） |
| `electron-builder.yml` | `artifactName` 包含版本号 |

版本规则：
- 上游 ClawX 版本号保持跟踪（当前 base: 0.4.15）
- 本 fork 定制叠加补丁版本（0.4.15 → 0.4.16 等）

### 4.2 发布步骤

```bash
# 1. 更新版本号
# package.json version 字段

# 2. 更新 CHANGELOG
# AGENTS.md 或 docs/CHANGELOG.md

# 3. 构建
pnpm run build:vite
pnpm exec electron-builder --win --x64

# 4. 发布
git add -A
git commit -m "chore: bump to vX.Y.Z"
git push origin main

# 5. USB 同步
# 将 release/ 复制到 CLAWBUTLER U 盘
```

### 4.3 提交流程

```
分支策略：main 单主干（本 fork 不复杂分支）
提交格式：<type>: <description>
  feat:   新功能
  fix:    修复
  chore:  构建/工具/文档
  docs:   文档变更
```

---

## 5. 运维与排错

### 5.1 Gateway 启动失败

| 症状 | 可能原因 | 处理 |
|------|---------|------|
| 端口占用 | 18789 被其他进程占用 | `lsof -i :18789` 查杀 |
| uv 未安装 | `pnpm run uv:download` 未跑 | 运行 `pnpm run init` |
| 配置损坏 | openclaw.json 格式错误 | 备份后运行 Doctor |

### 5.2 nvm-windows 安装 Node.js 失败

**症状**: `ERROR open C:\...\nvm\settings.txt: The system cannot find the file specified` 或脚本闪退

**根因**: 
1. nvm-windows noinstall 版本不会自动创建 `settings.txt`，首次运行前需手动创建。
2. 杀毒软件（Windows Defender / 360 等）可能阻拦 Node.js/pnpm 安装。

**修法**: `build-on-windows.bat` 已内置修复：
- 开头添加杀毒软件警告提示
- 在 `nvm install lts` 前自动写入 `settings.txt`

**手动修复**（如脚本外使用 nvm）：
1. 关闭杀毒软件实时防护
2. 打开 `%TEMP%\nvm\` 目录
3. 新建 `settings.txt`，写入：
   ```
   root: %TEMP%\nvm
   path: C:\Program Files\nodejs
   arch: 64
   proxy: none
   ```
4. 重新运行 `nvm install lts`

### 5.2 数据库/存储

无传统数据库。配置存储：
- `electron-store` JSON 文件（`~/.openclaw/`）
- 系统钥匙串（macOS Keychain / Windows Credential Manager）

### 5.3 日志

| 位置 | 内容 |
|------|------|
| Console (dev) | 开发时终端输出 |
| `~/.openclaw/logs/` | OpenClaw Gateway 日志 |
| Electron 日志 | `app.getPath('logs')` |

---

## 6. 仓库策略

### 6.1 远端

| 远端 | URL | 操作 |
|------|-----|------|
| origin | `git@github.com:zhaobod1/openclaw-butler-jarvis.git` | push/pull |
| upstream | `https://github.com/ValueCell-ai/ClawX.git` | 只读拉上游更新 |

### 6.2 同步上游

```bash
git remote add upstream https://github.com/ValueCell-ai/ClawX.git
git fetch upstream
git merge upstream/main
# 解决冲突（主要是 AGENTS.md 和 i18n 文件）
```

### 6.3 禁止推送到

- `ValueCell-ai/ClawX` 上游仓库（只读参考）

---

## 7. 文件变迁清单

| 文件 | 修改类型 | 说明 |
|------|---------|------|
| `electron-builder.yml` | ✅ 修改 | productName/appId/artifactName/NSIS |
| `package.json` | ✅ 修改 | name/description/author/version |
| `AGENTS.md` | ✅ 重写 | fork 专用接手入口 |
| `README.md` | ✅ 重写 | 按火一五品牌模板 |
| `index.html` | ✅ 修改 | title→龙虾管家 |
| `resources/icons/*` | ✅ 替换 | 全部龙虾 logo |
| `shared/i18n/locales/zh/*.json` | ✅ 修改 | ClawX→龙虾管家 |
| `src/assets/logo.svg` | ✅ 替换 | 龙虾 logo |
| `src/components/layout/Sidebar.tsx` | ✅ 修改 | logo alt + 品牌名 |
| `src/pages/Setup/index.tsx` | ✅ 修改 | logo alt |
| `electron/main/tray.ts` | ✅ 修改 | tooltip + 菜单 |
| `electron/main/launch-at-startup.ts` | ✅ 修改 | Linux 启动项 |
| `electron/utils/openclaw-workspace.ts` | ✅ 修改 | IDENTITY.md |
| `electron/utils/openclaw-cli.ts` | ✅ 修改 | OPENCLAW_EMBEDDED_IN |
| `electron/gateway/ws-client.ts` | ✅ 修改 | displayName |
| `electron/gateway/process-launcher.ts` | ✅ 修改 | OpenRouter-Title |
| `electron/shared/providers/registry.ts` | ✅ 修改 | OpenRouter-Title |
| `electron/main/menu.ts` | ✅ 修改 | 增加客服菜单项 |
| `electron/main/index.ts` | ✅ 修改 | 启动时 seed 聚星逸 provider |
| `shared/i18n/locales/en/*.json` | ✅ 修改 | ClawX→Claw Butler |
| `shared/i18n/locales/ja/*.json` | ✅ 修改 | ClawX→Claw Butler |
| `shared/i18n/locales/ru/*.json` | ✅ 修改 | ClawX→Claw Butler |
| `shared/i18n/locales/{zh,en,ja,ru}/menu.json` | ✅ 修改 | 增加 customerService 键 |
| `electron/utils/juxingyi-provider.ts` | ➕ 新增 | 聚星逸 provider 首次启动自动 seed |
| `electron/utils/customer-service.ts` | ➕ 新增 | 客服菜单 → 逸寻智库二维码弹窗 |
| `resources/images/qrcode_yxzk.jpg` | ➕ 新增 | 逸寻智库公众号二维码 |
| `deploy/*` | ➕ 新增 | 聚星逸配置、部署脚本、USB 包 |
| `docs/*` | ➕ 新增 | PRD、用户手册、开发者 SOP、ADR |
| `.claude/settings.json` | ➕ 新增 | Claude 项目配置 |
