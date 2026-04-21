# Codex Account Switcher

A command-line tool to quickly switch between multiple Codex accounts.

**GitHub**: https://github.com/yakumo2/codex-switch

## Features

- List all saved accounts
- One-click account switching
- Auto-save current account
- Show current active account

## Supported Platforms

| Platform | Support |
|----------|----------|
| macOS | ✅ Native |
| Linux | ✅ Native |
| Windows (PowerShell) | ✅ Native |
| Windows (WSL) | ✅ Supported |
| Windows (Git Bash) | ✅ Supported |

## Installation

### macOS / Linux / WSL / Git Bash

One-liner:

```bash
curl -fsSL https://raw.githubusercontent.com/yakumo2/codex-switch/main/install.sh | bash
```

Or manual:

```bash
mkdir -p ~/.local/bin ~/.codex/profiles
cp codex-switch ~/.local/bin/
chmod +x ~/.local/bin/codex-switch
```

### Windows (PowerShell)

One-liner:

```powershell
irm https://raw.githubusercontent.com/yakumo2/codex-switch/main/install.ps1 | iex
```

Or manual:

```powershell
mkdir "$env:USERPROFILE\.local\bin" -Force
mkdir "$env:USERPROFILE\.codex\profiles" -Force
copy codex-switch.ps1 "$env:USERPROFILE\.local\bin\"
```

## Usage

### List all accounts

```bash
codex-switch
# or
codex-switch list
```

Example output:
```
Available Codex accounts:
=========================
  - bookgenesis (user1@example.com)
  - leemao (user2@example.com) (current)
```

### Save current account

After logging into a new Codex account, save it:

```bash
codex-switch capture
```

Output:
```
✓ Captured current account: user@example.com
  Saved as: auth-user.json
```

### Switch account

```bash
codex-switch bookgenesis
```

Output:
```
Saved current account as: leemao
✓ Switched to: user1@example.com
```

## How it works

```
~/.codex/                          (macOS/Linux)
%USERPROFILE%\.codex\              (Windows)
├── auth.json              ← Current Codex credentials
└── profiles/              ← Saved account profiles
    ├── auth-bookgenesis.json
    └── auth-leemao.json
```

- **Switch**: Copy `profiles/auth-<name>.json` → `auth.json`
- **Save**: Copy `auth.json` → `profiles/auth-<email_username>.json`
- **Identify account**: Decode JWT `id_token` to extract email

## Prerequisites

1. [Codex CLI](https://github.com/openai/codex) installed:
   ```bash
   npm install -g @openai/codex
   ```

2. Logged into Codex at least once:
   ```bash
   codex
   # First run will prompt for login
   ```

## FAQ

### Q: Codex still shows old account after switching?

Try restarting Codex or clearing the cache:
```bash
# macOS/Linux
rm -rf ~/.codex/cache/*
# Windows PowerShell
Remove-Item "$env:USERPROFILE\.codex\cache\*" -Recurse -Force
```

### Q: How to add a new account?

1. Switch to any saved account (or ensure current is saved)
2. Login to Codex with new account
3. Run `codex-switch capture` to save

### Q: Windows shows execution policy error?

```powershell
# Temporarily allow script execution
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
# Or bypass policy directly
powershell -ExecutionPolicy Bypass -File codex-switch.ps1 list
```

## File Structure

```
codex-switch/
├── codex-switch        # Bash script (macOS/Linux/WSL)
├── codex-switch.ps1    # PowerShell script (Windows)
├── install.sh          # One-liner installer (macOS/Linux/WSL)
├── install.ps1         # One-liner installer (Windows)
├── README.md           # Documentation (Chinese)
└── README_EN.md        # Documentation (English)
```

## License

MIT
