# PayZen - Initial Setup Script
# This script checks all dependencies and sets up the project

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PayZen - Project Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to find Node.js
function Find-NodeJS {
    $commonPaths = @(
        "$env:ProgramFiles\nodejs\node.exe",
        "${env:ProgramFiles(x86)}\nodejs\node.exe",
        "$env:LOCALAPPDATA\Programs\nodejs\node.exe"
    )
    
    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            return $path
        }
    }
    
    $nodeInPath = Get-Command node -ErrorAction SilentlyContinue
    if ($nodeInPath) {
        return $nodeInPath.Source
    }
    
    return $null
}

# Step 1: Check Node.js
Write-Host "[1/3] Checking Node.js..." -ForegroundColor Yellow

# Refresh PATH first
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

$nodeExe = Find-NodeJS
$nodeVersion = $null

if ($nodeExe) {
    try {
        $nodeVersion = & $nodeExe --version 2>$null
        if ($nodeVersion) {
            $nodeDir = Split-Path $nodeExe -Parent
            $env:Path = "$nodeDir;$env:Path"
        }
    } catch {
        $nodeExe = $null
    }
}

if (-not $nodeVersion) {
    Write-Host "  Node.js not found. Starting installation..." -ForegroundColor Yellow
    Write-Host ""
    
    & "$PSScriptRoot\install-node.ps1"
    $installExitCode = $LASTEXITCODE
    
    # Refresh PATH after installation
    Start-Sleep -Seconds 2
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    
    # Check again
    $nodeExe = Find-NodeJS
    if ($nodeExe) {
        $nodeDir = Split-Path $nodeExe -Parent
        $env:Path = "$nodeDir;$env:Path"
        $nodeVersion = & $nodeExe --version 2>$null
    }
    
    if (-not $nodeVersion) {
        Write-Host ""
        Write-Host "Node.js installation may require PowerShell restart" -ForegroundColor Yellow
        Write-Host "Please:" -ForegroundColor Yellow
        Write-Host "  1. Close this PowerShell window" -ForegroundColor White
        Write-Host "  2. Open a new PowerShell window" -ForegroundColor White
        Write-Host "  3. Run .\setup.ps1 again" -ForegroundColor White
        Write-Host ""
        Write-Host "Or install Node.js manually from https://nodejs.org/" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host "  Node.js: $nodeVersion" -ForegroundColor Green

# Ensure node is in PATH
if ($nodeExe) {
    $nodeDir = Split-Path $nodeExe -Parent
    if ($env:Path -notlike "*$nodeDir*") {
        $env:Path = "$nodeDir;$env:Path"
    }
}

try {
    $npmExe = Join-Path (Split-Path $nodeExe -Parent) "npm.cmd"
    if (Test-Path $npmExe) {
        $npmVersion = & $npmExe --version 2>$null
        Write-Host "  npm: v$npmVersion" -ForegroundColor Green
    } else {
        Write-Host "  npm: not found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  npm: not found" -ForegroundColor Yellow
}
Write-Host ""

# Step 2: Install dependencies
Write-Host "[2/3] Installing project dependencies..." -ForegroundColor Yellow
Write-Host ""

try {
    if ($nodeExe) {
        $nodeDir = Split-Path $nodeExe -Parent
        $npmExe = Join-Path $nodeDir "npm.cmd"
        
        if (Test-Path $npmExe) {
            & $npmExe install
            if ($LASTEXITCODE -eq 0) {
                Write-Host ""
                Write-Host "  Dependencies installed successfully" -ForegroundColor Green
            } else {
                Write-Host ""
                Write-Host "  Error installing dependencies" -ForegroundColor Red
                exit 1
            }
        } else {
            Write-Host "  npm not found. Cannot install dependencies." -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "  Node.js not found. Cannot install dependencies." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host ""
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 3: Check project structure
Write-Host "[3/3] Checking project structure..." -ForegroundColor Yellow

$requiredDirs = @("app", "components", "server")
$missingDirs = @()

foreach ($dir in $requiredDirs) {
    if (-not (Test-Path $dir)) {
        $missingDirs += $dir
    }
}

if ($missingDirs.Count -eq 0) {
    Write-Host "  Project structure is OK" -ForegroundColor Green
} else {
    Write-Host "  Missing directories: $($missingDirs -join ', ')" -ForegroundColor Yellow
}

Write-Host ""

# Final message
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Setup completed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Create .env file (see .env.example)" -ForegroundColor White
Write-Host "  2. Setup PostgreSQL database" -ForegroundColor White
Write-Host "  3. Start server: npm run server:dev" -ForegroundColor White
Write-Host "  4. Start frontend: npm run dev" -ForegroundColor White
Write-Host ""
Write-Host "Documentation: README.md" -ForegroundColor Gray
Write-Host ""
