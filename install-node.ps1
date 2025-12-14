# PayZen - Automatic Node.js Installation
# This script checks for Node.js and installs it if necessary

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PayZen - Node.js Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to find Node.js in common locations
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
    
    # Check PATH
    $nodeInPath = Get-Command node -ErrorAction SilentlyContinue
    if ($nodeInPath) {
        return $nodeInPath.Source
    }
    
    return $null
}

# Check for Node.js
$nodeExe = Find-NodeJS
$nodeVersion = $null

if ($nodeExe) {
    try {
        $nodeVersion = & $nodeExe --version 2>$null
        if ($nodeVersion) {
            Write-Host "Node.js already installed: $nodeVersion" -ForegroundColor Green
            Write-Host ""
            
            # Add to PATH if not already there
            $nodeDir = Split-Path $nodeExe -Parent
            if ($env:Path -notlike "*$nodeDir*") {
                $env:Path = "$nodeDir;$env:Path"
            }
            
            # Check npm
            $npmExe = Join-Path $nodeDir "npm.cmd"
            if (Test-Path $npmExe) {
                $npmVersion = & $npmExe --version 2>$null
                if ($npmVersion) {
                    Write-Host "npm already installed: v$npmVersion" -ForegroundColor Green
                    Write-Host ""
                    Write-Host "Node.js is ready to use!" -ForegroundColor Green
                    exit 0
                }
            }
        }
    } catch {
        # Node.js not working properly
    }
}

Write-Host "Node.js not found. Starting installation..." -ForegroundColor Yellow
Write-Host ""

# Check for administrator rights
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "Administrator rights required for Node.js installation" -ForegroundColor Yellow
    Write-Host "Starting as administrator..." -ForegroundColor Yellow
    Write-Host ""
    
    # Restart script with administrator rights
    $scriptPath = $MyInvocation.MyCommand.Path
    $result = Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Wait -PassThru
    
    if ($result.ExitCode -eq 0) {
        # After installation, refresh PATH and check again
        Start-Sleep -Seconds 3
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        
        $nodeExe = Find-NodeJS
        if ($nodeExe) {
            $nodeVersion = & $nodeExe --version 2>$null
            if ($nodeVersion) {
                Write-Host "Node.js installed successfully: $nodeVersion" -ForegroundColor Green
                $nodeDir = Split-Path $nodeExe -Parent
                $env:Path = "$nodeDir;$env:Path"
                exit 0
            }
        }
    }
    
    Write-Host "Please restart PowerShell after Node.js installation" -ForegroundColor Yellow
    exit $result.ExitCode
}

# Detect system architecture
$arch = "x64"
if ([Environment]::Is64BitOperatingSystem -eq $false) {
    $arch = "x86"
}

# URL for downloading Node.js LTS
$nodeVersion = "20.11.0"
$nodeUrl = "https://nodejs.org/dist/v$nodeVersion/node-v$nodeVersion-x64.msi"

if ($arch -eq "x86") {
    $nodeUrl = "https://nodejs.org/dist/v$nodeVersion/node-v$nodeVersion-x86.msi"
}

$installerPath = "$env:TEMP\nodejs-installer.msi"

Write-Host "Downloading Node.js v$nodeVersion..." -ForegroundColor Cyan
Write-Host "URL: $nodeUrl" -ForegroundColor Gray
Write-Host ""

try {
    # Download installer
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $nodeUrl -OutFile $installerPath -UseBasicParsing
    
    if (Test-Path $installerPath) {
        Write-Host "Installer downloaded successfully" -ForegroundColor Green
        Write-Host ""
        Write-Host "Starting Node.js installation (silent mode)..." -ForegroundColor Cyan
        Write-Host "This may take a few minutes..." -ForegroundColor Yellow
        Write-Host ""
        
        # Run installer silently
        $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$installerPath`" /quiet /norestart" -Wait -PassThru
        
        if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
            Write-Host "Waiting for installation to complete..." -ForegroundColor Yellow
            Start-Sleep -Seconds 5
            
            # Refresh PATH
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
            
            # Find Node.js after installation
            $nodeExe = Find-NodeJS
            
            if ($nodeExe) {
                $nodeDir = Split-Path $nodeExe -Parent
                $env:Path = "$nodeDir;$env:Path"
                
                $newNodeVersion = & $nodeExe --version 2>$null
                $npmExe = Join-Path $nodeDir "npm.cmd"
                $newNpmVersion = $null
                
                if (Test-Path $npmExe) {
                    $newNpmVersion = & $npmExe --version 2>$null
                }
                
                if ($newNodeVersion -and $newNpmVersion) {
                    Write-Host ""
                    Write-Host "Installation verification:" -ForegroundColor Green
                    Write-Host "  Node.js: $newNodeVersion" -ForegroundColor Green
                    Write-Host "  npm: v$newNpmVersion" -ForegroundColor Green
                    Write-Host ""
                    Write-Host "========================================" -ForegroundColor Cyan
                    Write-Host "Installation completed successfully!" -ForegroundColor Green
                    Write-Host "========================================" -ForegroundColor Cyan
                    Write-Host ""
                    exit 0
                }
            }
            
            Write-Host ""
            Write-Host "Node.js installed, but PATH needs refresh" -ForegroundColor Yellow
            Write-Host "The installation completed. Please run setup.ps1 again." -ForegroundColor Yellow
            Write-Host ""
        } else {
            Write-Host "Error installing Node.js (code: $($process.ExitCode))" -ForegroundColor Red
            Write-Host "Try installing Node.js manually from https://nodejs.org/" -ForegroundColor Yellow
            exit 1
        }
        
        # Remove installer
        if (Test-Path $installerPath) {
            Remove-Item $installerPath -Force
        }
    } else {
        Write-Host "Failed to download installer" -ForegroundColor Red
        Write-Host "Check your internet connection and try again" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "Error downloading/installing Node.js" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Try installing Node.js manually:" -ForegroundColor Yellow
    Write-Host "1. Open https://nodejs.org/" -ForegroundColor Cyan
    Write-Host "2. Download LTS version" -ForegroundColor Cyan
    Write-Host "3. Run the installer" -ForegroundColor Cyan
    exit 1
}
