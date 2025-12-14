@echo off
chcp 65001 >nul
REM PayZen - Simple Start Script
REM This file starts the application automatically

echo.
echo ========================================
echo   PayZen - Starting Application
echo ========================================
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0start.ps1"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Error starting application.
    echo.
    pause
    exit /b %ERRORLEVEL%
)

pause





