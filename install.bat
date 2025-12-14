@echo off
chcp 65001 >nul
REM PayZen - Simple installer for Windows
REM This file runs the PowerShell setup script

echo.
echo ========================================
echo   PayZen - Installation
echo ========================================
echo.
echo This will automatically:
echo   1. Install Node.js (if needed)
echo   2. Install all dependencies
echo   3. Verify project structure
echo.
echo Starting...
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0auto-setup.ps1"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Setup completed with warnings.
    echo If Node.js was just installed, please:
    echo   1. Close this window
    echo   2. Open a new PowerShell window
    echo   3. Run: .\setup.ps1
    echo.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo Installation completed successfully!
echo.
pause
