# Codex Account Switcher - PowerShell Version
# https://github.com/yakumo2/codex-switch
# Usage: codex-switch.ps1 <account>

param(
    [Parameter(Position=0)]
    [string]$Command
)

$ErrorActionPreference = "Stop"
$VERSION = "1.1.0"

$CODEX_AUTH = "$env:USERPROFILE\.codex\auth.json"
$PROFILES_DIR = "$env:USERPROFILE\.codex\profiles"

# Ensure profiles directory exists
if (-not (Test-Path $PROFILES_DIR)) {
    New-Item -ItemType Directory -Path $PROFILES_DIR -Force | Out-Null
}

# Extract email from JWT id_token
function Get-EmailFromJwt {
    param([string]$Jwt)
    
    if ([string]::IsNullOrWhiteSpace($Jwt)) { return $null }
    
    try {
        $parts = $Jwt.Split('.')
        if ($parts.Length -lt 2) { return $null }
        
        $payload = $parts[1]
        # Add padding if needed
        $padding = 4 - ($payload.Length % 4)
        if ($padding -lt 4) {
            $payload += "=" * $padding
        }
        
        # Base64 decode
        $bytes = [System.Convert]::FromBase64String($payload)
        $json = [System.Text.Encoding]::UTF8.GetString($bytes)
        
        # Extract email directly with regex (more reliable)
        if ($json -match '"email"\s*:\s*"([^"]+)"') {
            return $matches[1]
        }
    } catch {
        # Silently fail
    }
    return $null
}

function Get-EmailFromFile {
    param([string]$File)
    
    if (-not (Test-Path $File)) { return $null }
    
    try {
        $raw = Get-Content $File -Raw
        
        # Find id_token value using regex (handles nested structure)
        if ($raw -match '"id_token"\s*:\s*"([a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+)"') {
            return Get-EmailFromJwt -Jwt $matches[1]
        }
    } catch {
        # Silently fail
    }
    return $null
}

function List-Accounts {
    Write-Host "Available Codex accounts:"
    Write-Host "========================="
    
    $currentEmail = if (Test-Path $CODEX_AUTH) { Get-EmailFromFile $CODEX_AUTH } else { $null }
    
    $profiles = Get-ChildItem -Path $PROFILES_DIR -Filter "auth-*.json" -ErrorAction SilentlyContinue
    if ($profiles) {
        foreach ($file in $profiles) {
            $name = $file.Name -replace '^auth-', '' -replace '\.json$', ''
            $email = Get-EmailFromFile $file.FullName
            $current = if ($email -eq $currentEmail) { " (current)" } else { "" }
            Write-Host "  - $name ($email)$current"
        }
    } else {
        Write-Host "  (no saved accounts)"
    }
}

function Switch-Account {
    param([string]$Target)
    
    $profileFile = Join-Path $PROFILES_DIR "auth-$Target.json"
    
    if (-not (Test-Path $profileFile)) {
        Write-Host "Error: Account '$Target' not found" -ForegroundColor Red
        Write-Host ""
        Write-Host "Available profiles:"
        $profiles = Get-ChildItem -Path $PROFILES_DIR -Filter "auth-*.json" -ErrorAction SilentlyContinue
        if ($profiles) {
            foreach ($file in $profiles) {
                $name = $file.Name -replace '^auth-', '' -replace '\.json$', ''
                Write-Host "  - $name"
            }
        }
        exit 1
    }
    
    # Backup current auth
    if (Test-Path $CODEX_AUTH) {
        $currEmail = Get-EmailFromFile $CODEX_AUTH
        if ($currEmail) {
            $currName = $currEmail -replace '@.*', ''
            $currProfile = Join-Path $PROFILES_DIR "auth-$currName.json"
            if (-not (Test-Path $currProfile)) {
                Copy-Item $CODEX_AUTH $currProfile
                Write-Host "Saved current account as: $currName"
            }
        }
    }
    
    # Switch to target
    Copy-Item $profileFile $CODEX_AUTH -Force
    $email = Get-EmailFromFile $profileFile
    Write-Host "OK Switched to: $email" -ForegroundColor Green
}

function Capture-Current {
    if (-not (Test-Path $CODEX_AUTH)) {
        Write-Host "Error: No current auth.json found" -ForegroundColor Red
        Write-Host "Path checked: $CODEX_AUTH"
        exit 1
    }
    
    $email = Get-EmailFromFile $CODEX_AUTH
    if (-not $email) {
        Write-Host "Error: Could not extract email from auth.json" -ForegroundColor Red
        Write-Host "Path: $CODEX_AUTH"
        # Debug: show first 200 chars
        $raw = Get-Content $CODEX_AUTH -Raw
        Write-Host "File content preview:"
        Write-Host $raw.Substring(0, [Math]::Min(200, $raw.Length))
        exit 1
    }
    
    $name = $email -replace '@.*', ''
    Copy-Item $CODEX_AUTH (Join-Path $PROFILES_DIR "auth-$name.json") -Force
    Write-Host "OK Captured current account: $email" -ForegroundColor Green
    Write-Host "  Saved as: auth-$name.json"
}

# Main logic
switch ($Command) {
    { $_ -in "list", "ls", "-l" } { List-Accounts }
    { $_ -in "capture", "save" } { Capture-Current }
    { $_ -in "version", "-v", "--version" } {
        Write-Host "codex-switch version $VERSION"
        Write-Host "https://github.com/yakumo2/codex-switch"
    }
    "" {
        List-Accounts
        Write-Host ""
        Write-Host "Commands:"
        Write-Host "  codex-switch <name>   - Switch to saved account"
        Write-Host "  codex-switch list     - List all saved accounts"
        Write-Host "  codex-switch capture  - Save current account"
        Write-Host "  codex-switch version  - Show version"
    }
    Default { Switch-Account $Command }
}
