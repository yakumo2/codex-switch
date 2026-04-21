#!/bin/bash
# Codex Account Switcher - Installer
# Usage: curl -fsSL https://your-server/install.sh | bash

set -e

INSTALL_DIR="$HOME/.local/bin"
PROFILES_DIR="$HOME/.codex/profiles"
SCRIPT_NAME="codex-switch"

echo "=== Codex Account Switcher Installer ==="
echo "https://github.com/yakumo2/codex-switch"
echo ""
echo ""

# Create directories
echo "Creating directories..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$PROFILES_DIR"

# Detect script location (same directory as install.sh, or download from URL)
SCRIPT_SOURCE=""
if [ -f "$(dirname "$0")/$SCRIPT_NAME" ]; then
    # Running from extracted archive
    SCRIPT_SOURCE="$(cd "$(dirname "$0")" && pwd)/$SCRIPT_NAME"
elif [ -f "./$SCRIPT_NAME" ]; then
    # Running from current directory
    SCRIPT_SOURCE="$(pwd)/$SCRIPT_NAME"
else
    # Download from GitHub
    DOWNLOAD_URL="${CODEX_SWITCH_URL:-https://raw.githubusercontent.com/yakumo2/codex-switch/main/codex-switch/codex-switch}"
    echo "Downloading from: $DOWNLOAD_URL"
    curl -fsSL "$DOWNLOAD_URL" -o "$INSTALL_DIR/$SCRIPT_NAME"
    chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    
    # Update PATH if needed
    if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
        echo ""
        echo "Adding $INSTALL_DIR to PATH..."
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        echo "✓ Added to ~/.bashrc"
        echo ""
        echo "Run this to update current session:"
        echo "  source ~/.bashrc"
    fi
    
    echo ""
    echo "✓ Installation complete!"
    echo ""
    echo "Usage:"
    echo "  codex-switch          - List accounts"
    echo "  codex-switch capture  - Save current account"
    echo "  codex-switch <name>   - Switch to account"
    exit 0
fi

# Copy script
echo "Installing script..."
cp "$SCRIPT_SOURCE" "$INSTALL_DIR/$SCRIPT_NAME"
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# Update PATH if needed
if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
    echo ""
    echo "Adding $INSTALL_DIR to PATH..."
    SHELL_RC=""
    if [ -n "$ZSH_VERSION" ]; then
        SHELL_RC="$HOME/.zshrc"
    else
        SHELL_RC="$HOME/.bashrc"
    fi
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
    echo "✓ Added to $SHELL_RC"
fi

echo ""
echo "✓ Installation complete!"
echo ""
echo "Installed to: $INSTALL_DIR/$SCRIPT_NAME"
echo "Profiles dir: $PROFILES_DIR"
echo ""
echo "Usage:"
echo "  codex-switch          - List accounts"
echo "  codex-switch capture  - Save current account"
echo "  codex-switch <name>   - Switch to account"
echo ""

# Check if PATH needs refresh
if ! command -v codex-switch &> /dev/null; then
    echo "Note: Run 'source ~/.bashrc' (or restart terminal) to use codex-switch"
fi
