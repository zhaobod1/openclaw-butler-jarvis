---
name: nvm-windows noinstall 首次使用需手动创建 settings.txt
description: nvm-windows noinstall 版本不会自动创建 settings.txt，导致 nvm install lts 失败报 "The system cannot find the file specified"
type: feedback
---

## 报错原文

```
ERROR open C:\Users\Administrator\AppData\Local\Temp\nvm\settings.txt: The system cannot find the file specified.
[ERROR] Node.js install failed
```

## 根因

nvm-windows noinstall 版本（`nvm-noinstall.zip`）解压后不会自动生成 `settings.txt`。`nvm install lts` 首次运行时需要读取该文件获取 root/path/arch/proxy 配置，找不到就报错。

## 修法模板（可复制）

```batch
REM 在 nvm install lts 之前插入
(
    echo root: %NVM_DIR%
    echo path: C:\Program Files\nodejs
    echo arch: 64
    echo proxy: none
) > "%NVM_DIR%\settings.txt"
```

## 诊断 SOP

1. 检查 `%TEMP%\nvm\` 目录是否存在
2. 确认 `settings.txt` 是否缺失
3. 若缺失，手动创建并写入四行配置
4. 重新运行 `nvm install lts`

## 关联

- 项目: `openclaw-butler-jarvis`
- 文件: `deploy/clawbutler-usb/build-on-windows.bat:40-45`
- 文档: `docs/developer-sop.md` §5.2
