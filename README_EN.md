# Codex Account Switcher

A command-line tool to quickly switch between multiple Codex accounts.

**GitHub**: https://github.com/yakumo2/codex-switch

## Features

- List all saved accounts
- One-click account switching
- Auto-save current account before switching
- Show current active account

## Installation

### Option 1: Manual Install

```bash
mkdir -p ~/.local/bin ~/.codex/profiles
cp codex-switch ~/.local/bin/
chmod +x ~/.local/bin/codex-switch
```

### Option 2: One-liner (from GitHub)

```bash
curl -fsSL https://raw.githubusercontent.com/yakumo2/codex-switch/main/install.sh | bash
```

### Option 2: One-liner Install Script

Or download and run directly from GitHub:

```bash
curl -fsSL https://raw.githubusercontent.com/yakumo2/codex-switch/main/install.sh | bash
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
~/.codex/
├── auth.json              ← Current Codex credentials
└── profiles/              ← Saved account profiles
    ├── auth-bookgenesis.json
    └── auth-leemao.json
```

- **Switch**: Copy `profiles/auth-<name>.json` → `~/.codex/auth.json`
- **Save**: Copy `~/.codex/auth.json` → `profiles/auth-<email_username>.json`
- **Identify account**: Decode JWT `id_token` to extract email

## Supported Platforms

| Platform | Support |
|----------|----------|
| macOS | ✅ Native |
| Linux | ✅ Native |
| Windows (WSL) | ✅ Supported |
| Windows (Git Bash) | ✅ Supported |
| Windows (Native) | ❌ Requires WSL or Git Bash |

## Prerequisites

1. [Codex CLI](https://github.com/openi/codex) installed:
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
rm -rf ~/.codex/cache/*
```

### Q: How to add a new account?

1. Switch to any saved account (or ensure current is saved)
2. Login to Codex with new account
3. Run `codex-switch capture` to save

### Q: Which systems are supported?

macOS, Linux, WSL. Windows native requires Git Bash or WSL.

## File Structure

```
codex-switch/
├── codex-switch    # Main script
├── install.sh      # One-liner install script
├── README.md       # Documentation (Chinese)
└── README_EN.md    # Documentation (English)
```

## License

MIT
