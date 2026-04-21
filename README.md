# Codex Account Switcher

在多个 Codex 账户之间快速切换的命令行工具。

**GitHub**: https://github.com/yakumo2/codex-switch

## 功能

- 列出所有已保存的账户
- 一键切换账户
- 自动保存当前账户
- 显示当前活跃账户

## 支持的平台

| 平台 | 支持 |
|------|------|
| macOS | ✅ 原生支持 |
| Linux | ✅ 原生支持 |
| Windows (PowerShell) | ✅ 原生支持 |
| Windows (WSL) | ✅ 支持 |
| Windows (Git Bash) | ✅ 支持 |

## 安装

### macOS / Linux / WSL / Git Bash

一键安装：

```bash
curl -fsSL https://raw.githubusercontent.com/yakumo2/codex-switch/main/install.sh | bash
```

或手动安装：

```bash
mkdir -p ~/.local/bin ~/.codex/profiles
cp codex-switch ~/.local/bin/
chmod +x ~/.local/bin/codex-switch
```

### Windows (PowerShell)

一键安装：

```powershell
irm https://raw.githubusercontent.com/yakumo2/codex-switch/main/install.ps1 | iex
```

或手动安装：

```powershell
mkdir "$env:USERPROFILE\.local\bin" -Force
mkdir "$env:USERPROFILE\.codex\profiles" -Force
copy codex-switch.ps1 "$env:USERPROFILE\.local\bin\"
```

## 使用方法

### 查看所有账户

```bash
codex-switch
# 或
codex-switch list
```

输出示例：
```
Available Codex accounts:
=========================
  - bookgenesis (user1@example.com)
  - leemao (user2@example.com) (current)
```

### 保存当前账户

当你用 Codex 登录了一个新账户后，保存它：

```bash
codex-switch capture
```

输出：
```
✓ Captured current account: user@example.com
  Saved as: auth-user.json
```

### 切换账户

```bash
codex-switch bookgenesis
```

输出：
```
Saved current account as: leemao
✓ Switched to: user1@example.com
```

## 工作原理

```
~/.codex/                          (macOS/Linux)
%USERPROFILE%\.codex\              (Windows)
├── auth.json              ← Codex 当前使用的登录凭证
└── profiles/              ← 保存的账户配置文件
    ├── auth-bookgenesis.json
    └── auth-leemao.json
```

- **切换**: 复制 `profiles/auth-<name>.json` → `auth.json`
- **保存**: 复制 `auth.json` → `profiles/auth-<email用户名>.json`
- **识别账户**: 从 JWT `id_token` 中解码提取 email

## 前提条件

1. 已安装 [Codex CLI](https://github.com/openai/codex)：
   ```bash
   npm install -g @openai/codex
   ```

2. 至少登录过一次 Codex：
   ```bash
   codex
   # 首次运行会提示登录
   ```

## 常见问题

### Q: 切换后 Codex 还是显示旧账户？

尝试重新启动 Codex 或清除缓存：
```bash
# macOS/Linux
rm -rf ~/.codex/cache/*
# Windows PowerShell
Remove-Item "$env:USERPROFILE\.codex\cache\*" -Recurse -Force
```

### Q: 如何添加新账户？

1. 先切换到任意已保存的账户（或确保当前账户已保存）
2. 用 Codex 登录新账户
3. 运行 `codex-switch capture` 保存

### Q: Windows 提示执行策略错误？

```powershell
# 临时允许脚本执行
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
# 或者直接绕过策略运行
powershell -ExecutionPolicy Bypass -File codex-switch.ps1 list
```

## 文件结构

```
codex-switch/
├── codex-switch        # Bash 主脚本 (macOS/Linux/WSL)
├── codex-switch.ps1    # PowerShell 主脚本 (Windows)
├── install.sh          # 一键安装脚本 (macOS/Linux/WSL)
├── install.ps1         # 一键安装脚本 (Windows)
├── README.md           # 本文档（中文）
└── README_EN.md        # 英文文档
```

## License

MIT
