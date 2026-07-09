---
name: USB 做盘 SOP — 从开发仓库制作可一键构建的 U 盘
description: 将 openclaw-butler-jarvis 部署到 exFAT U 盘的完整步骤，包含源码同步、脚本部署、macOS 垃圾文件清理和验证；记录 Mac 交叉使用导致 902 个 ._ 文件污染的踩坑
type: feedback
---

## 背景

龙虾管家通过 U 盘分发给非技术用户：插入 Windows 电脑 → 双击 `build-on-windows.bat` → 自动安装依赖、构建、打包安装程序。

U 盘标准布局：

```
E:\                              ← U 盘根
├── README.md                    ← 用户说明
├── build-on-windows.bat         ← 一键构建脚本
├── deploy-juxingyi.bat          ← 一键部署 Provider
├── juxingyi-openclaw.json       ← 聚星逸 Provider 预置配置
└── source/                      ← 完整项目源码（含 .npmrc）
    ├── package.json
    ├── .npmrc                   ← 必须含 node-linker=hoisted
    ├── electron-builder.yml
    ├── src/ ...
    └── ...
```

## 踩坑：macOS 交叉使用污染 U 盘

本次做盘发现 U 盘上有 **902 个 `._*` 文件**，以及 `.Spotlight-V100`、`.fseventsd` 目录。

**根因**：U 盘曾插入 Mac 使用，macOS 会在 exFAT/FAT32 卷上为每个文件生成 AppleDouble 元数据文件（`._<原名>`），存储资源分叉和扩展属性。还会创建 Spotlight 索引目录（`.Spotlight-V100`）和文件系统事件目录（`.fseventsd`）。

**危害**：
- `._*` 文件在 Windows 上是垃圾，但会被文件搜索/构建工具扫描到，干扰构建
- 大量隐藏文件让 U 盘显得混乱
- 占用额外空间

**清理方法**（PowerShell）：

```powershell
# 删除所有 ._ 开头的文件
Get-ChildItem -Path "E:\" -Filter "._*" -Recurse -Force |
    Remove-Item -Force -Recurse

# 删除 macOS 索引目录（System Volume Information 是 Windows 的，勿删）
Remove-Item "E:\.Spotlight-V100" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "E:\.fseventsd" -Recurse -Force -ErrorAction SilentlyContinue
```

**预防**：做盘一律在 Windows 上进行，不要用 Mac 拷贝文件。如必须用 Mac，拷贝后立即在 Windows 上清理。

## 完整做盘步骤

### 步骤 1：同步项目源码到 U 盘

```powershell
# 用 robocopy 从开发仓库同步到 U 盘 source 目录
# 排除不需要的大目录
robocopy "D:\workspace\projects\ai\openclaw-butler-jarvis" "E:\source" /MIR /XD node_modules .git dist release out /XF *.log
```

参数说明：
- `/MIR` — 镜像同步（源没有的文件在目标删除）
- `/XD node_modules .git dist release out` — 排除大目录（构建时自动生成）
- `/XF *.log` — 排除日志文件

### 步骤 2：同步构建脚本和部署文件到 U 盘根目录

```powershell
# 构建脚本（来自 deploy/clawbutler-usb/）
Copy-Item "D:\workspace\projects\ai\openclaw-butler-jarvis\deploy\clawbutler-usb\build-on-windows.bat" "E:\" -Force

# 部署脚本和配置（来自 deploy/）
Copy-Item "D:\workspace\projects\ai\openclaw-butler-jarvis\deploy\deploy-juxingyi.bat" "E:\" -Force
Copy-Item "D:\workspace\projects\ai\openclaw-butler-jarvis\deploy\juxingyi-openclaw.json" "E:\" -Force

# 用户说明
Copy-Item "D:\workspace\projects\ai\openclaw-butler-jarvis\README.md" "E:\" -Force
```

### 步骤 3：清理 macOS 垃圾文件

见上文「清理方法」。**每次做盘都必须执行**，即使 U 盘看似干净。

### 步骤 4：验证

```powershell
# 1. 确认 .npmrc 含 node-linker=hoisted（exFAT 必需）
Get-Content "E:\source\.npmrc"
# 期望输出包含: node-linker=hoisted

# 2. 确认 build-on-windows.bat 含目录导航逻辑
Get-Content "E:\build-on-windows.bat" | Select-String "Change to project root"
# 期望输出匹配

# 3. 确认无 ._ 垃圾文件
(Get-ChildItem -Path "E:\" -Filter "._*" -Recurse -Force).Count
# 期望输出: 0

# 4. 确认关键文件齐全
Test-Path "E:\build-on-windows.bat"
Test-Path "E:\deploy-juxingyi.bat"
Test-Path "E:\juxingyi-openclaw.json"
Test-Path "E:\source\package.json"
Test-Path "E:\source\.npmrc"
Test-Path "E:\source\electron-builder.yml"
# 期望全部 True
```

### 步骤 5（可选）：预装依赖

提前在 U 盘上跑 `pnpm install`，用户拿到 U 盘可直接构建，省去 10-20 分钟下载时间：

```powershell
cd E:\source
pnpm install
```

> 注意：预装后 `node_modules` 约占 1-2 GB，确保 U 盘空间充足。

## 一键做盘脚本（PowerShell）

把以上步骤封装成可复用脚本：

```powershell
# make-usb.ps1 — 用法: .\make-usb.ps1 E:
param([string]$Drive = "E:")
$Repo = "D:\workspace\projects\ai\openclaw-butler-jarvis"

Write-Host "[1/5] Mirroring source to $Drive\source ..."
robocopy "$Repo" "$Drive\source" /MIR /XD node_modules .git dist release out /XF *.log /NFL /NDL

Write-Host "[2/5] Copying build/deploy scripts ..."
Copy-Item "$Repo\deploy\clawbutler-usb\build-on-windows.bat" "$Drive\" -Force
Copy-Item "$Repo\deploy\deploy-juxingyi.bat" "$Drive\" -Force
Copy-Item "$Repo\deploy\juxingyi-openclaw.json" "$Drive\" -Force
Copy-Item "$Repo\README.md" "$Drive\" -Force

Write-Host "[3/5] Cleaning macOS metadata ..."
Get-ChildItem -Path $Drive -Filter "._*" -Recurse -Force -ErrorAction SilentlyContinue |
    Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item "$Drive\.Spotlight-V100" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$Drive\.fseventsd" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "[4/5] Verifying ..."
$ok = $true
if (-not (Get-Content "$Drive\source\.npmrc" | Select-String "node-linker=hoisted")) { $ok = $false; Write-Host "  FAIL: .npmrc missing node-linker=hoisted" }
$trash = (Get-ChildItem -Path $Drive -Filter "._*" -Recurse -Force -ErrorAction SilentlyContinue).Count
if ($trash -gt 0) { $ok = $false; Write-Host "  FAIL: $trash ._ files remain" }

Write-Host "[5/5] Done. Result: $(if ($ok) {'PASS'} else {'FAIL'})"
```

## 关联

- 项目: `openclaw-butler-jarvis`
- 相关文件: `deploy/clawbutler-usb/build-on-windows.bat`, `.npmrc`
- 关联踩坑: `docs/lessons/2026-07-09-exfat-pnpm-node-linker.md`（exFAT 符号链接问题）
- 文档: `docs/developer-sop.md` §4.2 发布步骤
