# Codex Account Switcher - Windows Installer (PowerShell)
# https://github.com/yakumo2/codex-switch
# Usage: irm https://raw.githubusercontent.com/yakumo2/codex-switch/main/install.ps1 | iex

param(
    [switch]$NoPathUpdate
)

$ErrorActionPreference = "Stop"

$INSTALL_DIR = "$env:USERPROFILE\.local\bin"
$PROFILES_DIR = "$env:USERPROFILE\.codex\profiles"
$SCRIPT_NAME = "codex-switch.ps1"

Write-Host "=== Codex Account Switcher Installer ===" -ForegroundColor Cyan
Write-Host "https://github.com/yakumo2/codex-switch"
Write-Host ""

# Create directories
Write-Host "Creating directories..."
New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
New-Item -ItemType Directory -Path $PROFILES_DIR -Force | Out-Null

# Download script
$downloadUrl = "https://raw.githubusercontent.com/yakumo2/codex-switch/main/codex-switch.ps1"
$targetFile = Join-Path $INSTALL_DIR $SCRIPT_NAME

Write-Host "Downloading script..."
Invoke-WebRequest -Uri $downloadUrl -OutFile $targetFile -UseBasicParsing

# Create wrapper batch file for easy command-line use
$batchFile = Join-Path $INSTALL_DIR "codex-switch.bat"
$batchContent = @"
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "$targetFile" %*
"@
Set-Content -Path $batchFile -Value $batchContent -Encoding ASCII

# Update PATH if needed
if (-not $NoPathUpdate) {
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($userPath -notlike "*$INSTALL_DIR*") {
        Write-Host ""
        Write-Host "Adding $INSTALL_DIR to PATH..."
        [Environment]::SetEnvironmentVariable("Path", "$userPath;$INSTALL_DIR", "User")
        Write-Host "OK Added to user PATH" -ForegroundColor Green
        
        # Update current session
        $env:Path += ";$INSTALL_DIR"
    }
}

Write-Host ""
Write-Host "OK Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Installed to: $targetFile"
Write-Host "Profiles dir: $PROFILES_DIR"
Write-Host ""
Write-Host "Usage:"
Write-Host "  codex-switch          - List accounts"
Write-Host "  codex-switch capture  - Save current account"
Write-Host "  codex-switch <name>   - Switch to account"
Write-Host ""
Write-Host "Note: Restart your terminal to use codex-switch command"
