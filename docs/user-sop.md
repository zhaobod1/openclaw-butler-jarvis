# 龙虾管家 — 用户手册

> 版本: v1.0 | 适用平台: Windows / macOS / Linux

---

## 1. 安装

### 1.1 Windows 安装（推荐）

**前提**: 需要 Windows 10/11 x64，安装 Node.js 18+ 和 pnpm。

```batch
# 插入 CLAWBUTLER U 盘 → 运行
build-on-windows.bat

# 构建完成后，运行 release/ 下的安装包
# 龙虾管家-*-x64-setup.exe
```

### 1.2 从源码运行（开发用）

```bash
git clone git@github.com:zhaobod1/openclaw-butler-jarvis.git
cd openclaw-butler-jarvis
corepack enable && corepack prepare
pnpm run init    # 安装依赖 + 下载 uv
pnpm dev         # 启动开发服务器
```

### 1.3 macOS 安装

注意：ClawX 上游有 macOS 版，本 fork 的 macOS 构建需在 macOS 上运行 `pnpm exec electron-builder --mac`。但 macOS 版建议直接使用上游 ClawX。

---

## 2. 首次启动设置

### 2.1 配置 AI Provider

龙虾管家已预置聚星逸配置。如未自动加载，手动部署：

1. 运行 `deploy/deploy-juxingyi.bat`（Windows）
2. 或手动合并 `deploy/juxingyi-openclaw.json` 到 `~/.openclaw/openclaw.json`

### 2.2 验证安装

1. 启动龙虾管家
2. 打开 Settings → AI Providers，确认聚星逸 (juxingyi) 出现在列表中
3. 在聊天窗口发送消息，验证正常回复

---

## 3. 日常使用

### 3.1 界面概览

| 区域 | 说明 |
|------|------|
| 左侧边栏 | Agent 列表、会话管理 |
| 主聊天区 | 对话交互、思维链展示 |
| 右侧面板 | Agent 配置、工具调用记录 |
| 顶部菜单 | 文件、编辑、视图、帮助 |
| 系统托盘 | 龙虾管家图标（右键菜单） |

### 3.2 核心功能

- **多 Agent 管理**: 创建、配置、切换多个 AI Agent
- **会话管理**: 对话历史、删除、导出
- **文件预览**: 在聊天中查看图片、文档、代码
- **Token 用量统计**: Dashboard 查看历史用量
- **技能市场**: 安装和管理 OpenClaw Skills
- **插件管理**: 安装和管理 OpenClaw 插件（企业微信、钉钉等）

### 3.3 系统托盘

| 操作 | 说明 |
|------|------|
| 显示龙虾管家 | 打开主窗口 |
| Gateway 状态 | 显示运行/停止状态 |
| 隐藏/退出 | 最小化托盘或完全退出 |

---

## 4. 配置

### 4.1 聚星逸 Provider

| 配置项 | 值 |
|--------|-----|
| Provider ID | `juxingyi` |
| 类型 | OpenAI 兼容 |
| Base URL | `https://fireworks-simulator-api.huo15.com/v1` |
| 默认模型 | `deepseek-v4-flash-free` |

### 4.2 配置文件位置

| 平台 | 路径 |
|------|------|
| Windows | `%USERPROFILE%\.openclaw\openclaw.json` |
| macOS/Linux | `~/.openclaw/openclaw.json` |

---

## 5. 常见问题

### 5.1 无法连接 Gateway

**现象**: 界面显示"连接中"。
**解决**: 等待 10-30 秒让 Gateway 自动启动。如持续失败，在 Settings → Advanced → Developer 中运行 Doctor。

### 5.2 AI 不回复

**现象**: 发送消息后无响应。
**解决**:
1. Settings → AI Providers → 检查聚星逸 API key 是否有效
2. 检查网络是否能访问 `fireworks-simulator-api.huo15.com`
3. 运行 Doctor 修复配置

### 5.3 安装包构建失败

**参考**: `deploy/clawbutler-usb/README.md` 和 `docs/developer-sop.md`。

---

## 6. 卸载

| 平台 | 方法 |
|------|------|
| Windows | 控制面板 → 程序和功能 → 卸载龙虾管家 |
| macOS | 将龙虾管家.app 拖入废纸篓 |
| Linux | 对应包管理器卸载 |

---

## 7. 联系我们

- **公司**: 青岛火一五信息科技有限公司
- **邮箱**: support@huo15.com
- **QQ 群**: 1093992108
- **B站视频教程**: https://space.bilibili.com/400418085
