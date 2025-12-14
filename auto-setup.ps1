# PayZen - Fully Automated Setup
# This script handles everything automatically, including PowerShell restart if needed

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$setupScript = Join-Path $scriptPath "setup.ps1"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PayZen - Automated Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will:" -ForegroundColor Yellow
Write-Host "  1. Install Node.js (if needed)" -ForegroundColor White
Write-Host "  2. Install all dependencies" -ForegroundColor White
Write-Host "  3. Verify project structure" -ForegroundColor White
Write-Host ""
Write-Host "Starting in 3 seconds..." -ForegroundColor Gray
Start-Sleep -Seconds 3
Write-Host ""

# Run setup
& $setupScript

$setupResult = $LASTEXITCODE

if ($setupResult -ne 0) {
    Write-Host ""
    Write-Host "Setup encountered an issue." -ForegroundColor Yellow
    Write-Host "If Node.js was just installed, you may need to:" -ForegroundColor Yellow
    Write-Host "  1. Close this PowerShell window" -ForegroundColor White
    Write-Host "  2. Open a new PowerShell window" -ForegroundColor White
    Write-Host "  3. Run: .\setup.ps1" -ForegroundColor White
    Write-Host ""
    exit $setupResult
}

Write-Host ""
Write-Host "All done! You can now start developing." -ForegroundColor Green
Write-Host ""





