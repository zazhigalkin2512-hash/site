@echo off
title PayZen - One Click Start
color 0A

echo.
echo ========================================
echo   PayZen - One Click Start
echo ========================================
echo.
echo This will:
echo   1. Setup .env file
echo   2. Check PostgreSQL
echo   3. Create database
echo   4. Start backend server (port 3001)
echo   5. Start frontend server (port 3000)
echo.
echo Then open: http://localhost:3000
echo.
echo Press any key to start...
pause >nul

powershell -ExecutionPolicy Bypass -File "%~dp0start.ps1"





