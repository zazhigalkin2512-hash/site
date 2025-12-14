@echo off
chcp 65001 >nul
title PayZen - Starting...
color 0A

echo.
echo ========================================
echo   PayZen - One-Click Start
echo ========================================
echo.
echo This will automatically:
echo   1. Create .env file (if needed)
echo   2. Check PostgreSQL
echo   3. Create database (if needed)
echo   4. Start backend server
echo   5. Start frontend server
echo.
echo Then open: http://localhost:3000
echo.
echo Starting in 3 seconds...
timeout /t 3 /nobreak >nul

powershell -ExecutionPolicy Bypass -File "%~dp0start.ps1"

pause





