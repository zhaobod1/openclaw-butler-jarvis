---
name: exFAT U 盘不支持 pnpm 符号链接 + 构建脚本工作目录错误
description: U 盘（exFAT）上运行 build-on-windows.bat 闪退：一是脚本未切换到项目根目录导致找不到 package.json；二是 exFAT 不支持符号链接导致 pnpm install 报 ERR_PNPM_EISDIR
type: feedback
---

## 报错原文

闪退现象：双击 `build-on-windows.bat`，窗口一闪而过，看不到任何错误。

手动复现错误 1（工作目录）：

```
[ERR_PNPM_NO_PKG_MANIFEST] No package.json found in E:\
```

手动复现错误 2（exFAT 符号链接）：

```
ERR_PNPM_EISDIR [symlinkAllModules] EISDIR: illegal operation on a directory,
symlink 'E:\source\node_modules\.pnpm\conf@15.1.0\node_modules\conf'
-> 'E:\source\node_modules\.pnpm\electron-store@11.0.2\node_modules\conf'

The "E:" drive is exFAT, which does not support symlinks.
This will cause installation to fail. You can set the node-linker to "hoisted"
to avoid this issue.
```

## 根因

### 问题 1：脚本未切换工作目录

`build-on-windows.bat` 在 USB 部署包中位于 `E:\build-on-windows.bat`，但 `package.json` 在 `E:\source\package.json`。脚本原版直接在当前目录运行 `pnpm install`，找不到 `package.json` 立即退出，配合 `@echo off` 导致窗口闪退、用户看不到错误。

### 问题 2：exFAT 不支持符号链接

U 盘默认格式化为 exFAT（跨平台兼容）。pnpm 默认使用 `isolated` node-linker，在 `node_modules/.pnpm/` 下大量创建符号链接（symlink）来节省磁盘空间。exFAT 文件系统不支持 symlink 操作，pnpm install 在链接阶段报 `ERR_PNPM_EISDIR` 失败。

> 对比：开发机 NTFS 盘符上 symlink 正常工作，所以该问题只在 U 盘部署场景暴露。

## 修法模板（可复制）

### 修复 1：脚本开头自动定位项目根目录

```batch
REM ==================== Change to project root ====================
cd /d "%~dp0"
if exist "source\package.json" (
    cd source
) else if exist "..\..\package.json" (
    cd ..\..\
)
echo    Project root: %CD%
```

逻辑说明：
- `%~dp0` 是脚本所在目录
- USB 部署（`E:\build-on-windows.bat`）→ 检测到 `source\package.json` → `cd source`
- 开发仓库（`deploy\clawbutler-usb\build-on-windows.bat`）→ 检测到 `..\..\package.json` → `cd ..\..\`

### 修复 2：设置 node-linker=hoisted

三种方式任选其一（推荐方式 A，最可靠）：

**方式 A — 写入项目 `.npmrc`（最可靠）：**

```ini
# .npmrc
package-import-method=copy
shamefully-hoist=true
strict-peer-dependencies=false
node-linker=hoisted
```

**方式 B — 脚本内 pnpm config set：**

```batch
pnpm config set node-linker hoisted --location=project
```

**方式 C — 环境变量（实测对 node-linker 不生效，仅作冗余保险）：**

```batch
set "PNPM_CONFIG_NODE_LINKER=hoisted"
```

> `node-linker=hoisted` 让 pnpm 使用扁平化 node_modules（类似 npm），完全不创建符号链接，代价是丧失 pnpm 的依赖隔离能力。对本项目（单体 Electron 应用）无影响。

## 诊断 SOP

1. 双击 bat 闪退 → 用 `cmd /c` 手动运行看错误：`"" | cmd /c "E:\build-on-windows.bat"`
2. 若报 `ERR_PNPM_NO_PKG_MANIFEST` → 工作目录问题，检查脚本是否 `cd` 到项目根
3. 若报 `ERR_PNPM_EISDIR` 或提示 exFAT → 符号链接问题，检查 `.npmrc` 是否有 `node-linker=hoisted`
4. 确认修复后重新运行：`pnpm install --frozen-lockfile` 验证不再报错

## 关联

- 项目: `openclaw-butler-jarvis`
- 文件: `deploy/clawbutler-usb/build-on-windows.bat:5-16`（工作目录修复）
- 文件: `deploy/clawbutler-usb/build-on-windows.bat:135-138`（node-linker 修复）
- 文件: `.npmrc:4`（node-linker=hoisted）
- 文档: `docs/developer-sop.md` §5.3
