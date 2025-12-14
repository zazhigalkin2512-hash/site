# PayZen - Automatic Start Script
# This script sets up everything and starts the application

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PayZen - Starting Application" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check and create .env file
Write-Host "[1/4] Checking .env file..." -ForegroundColor Yellow

if (-not (Test-Path ".env")) {
    Write-Host "  Creating .env file..." -ForegroundColor Yellow
    
    $envContent = @"
DB_NAME=payzen
DB_USER=postgres
DB_PASSWORD=postgres
DB_HOST=localhost
DB_PORT=5432

JWT_SECRET=payzen-development-secret-key-change-in-production-32chars

API_URL=http://localhost:3001
NEXT_PUBLIC_API_URL=http://localhost:3001

PORT=3001
NODE_ENV=development
"@
    
    $envContent | Out-File -FilePath ".env" -Encoding UTF8 -NoNewline
    Write-Host "  .env file created with default settings" -ForegroundColor Green
    Write-Host "  Default PostgreSQL password: postgres" -ForegroundColor Yellow
} else {
    Write-Host "  .env file exists" -ForegroundColor Green
}
Write-Host ""

# Step 2: Check PostgreSQL
Write-Host "[2/4] Checking PostgreSQL..." -ForegroundColor Yellow

$pgRunning = $false
$pgInstalled = $false

# Check if PostgreSQL service is running
try {
    $pgService = Get-Service -Name "postgresql*" -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Running' }
    if ($pgService) {
        $pgRunning = $true
        $pgInstalled = $true
        Write-Host "  PostgreSQL service is running" -ForegroundColor Green
    }
} catch {
    # Service check failed
}

# Check if PostgreSQL is installed but not running
if (-not $pgInstalled) {
    $pgPaths = @(
        "C:\Program Files\PostgreSQL\*\bin\psql.exe",
        "C:\Program Files (x86)\PostgreSQL\*\bin\psql.exe"
    )
    
    foreach ($path in $pgPaths) {
        $found = Get-ChildItem -Path $path -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) {
            $pgInstalled = $true
            Write-Host "  PostgreSQL is installed" -ForegroundColor Green
            Write-Host "  Attempting to start PostgreSQL service..." -ForegroundColor Yellow
            
            try {
                $service = Get-Service -Name "postgresql*" -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($service) {
                    Start-Service -Name $service.Name -ErrorAction SilentlyContinue
                    Start-Sleep -Seconds 3
                    if ((Get-Service -Name $service.Name).Status -eq 'Running') {
                        $pgRunning = $true
                        Write-Host "  PostgreSQL service started" -ForegroundColor Green
                    } else {
                        Write-Host "  Please start PostgreSQL service manually" -ForegroundColor Yellow
                    }
                }
            } catch {
                Write-Host "  Could not start PostgreSQL automatically" -ForegroundColor Yellow
            }
            break
        }
    }
}

if (-not $pgInstalled) {
    Write-Host "  PostgreSQL not found" -ForegroundColor Yellow
    Write-Host "  Install from: https://www.postgresql.org/download/" -ForegroundColor Cyan
    Write-Host "  Or use Docker: docker run --name postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres" -ForegroundColor Cyan
} elseif (-not $pgRunning) {
    Write-Host "  PostgreSQL is not running" -ForegroundColor Yellow
    Write-Host "  Please start PostgreSQL service manually" -ForegroundColor Yellow
}
Write-Host ""

# Step 3: Create database
Write-Host "[3/4] Checking database..." -ForegroundColor Yellow

if ($pgInstalled) {
    $psqlPath = $null
    $pgPaths = @(
        "C:\Program Files\PostgreSQL\*\bin\psql.exe",
        "C:\Program Files (x86)\PostgreSQL\*\bin\psql.exe"
    )
    
    foreach ($path in $pgPaths) {
        $found = Get-ChildItem -Path $path -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) {
            $psqlPath = $found.FullName
            break
        }
    }
    
    if ($psqlPath -and $pgRunning) {
        Write-Host "  Checking if database exists..." -ForegroundColor Yellow
        
        $env:PGPASSWORD = "postgres"
        $checkDb = & $psqlPath -U postgres -h localhost -tAc "SELECT 1 FROM pg_database WHERE datname='payzen'" 2>$null
        
        if ($checkDb -ne "1") {
            Write-Host "  Creating database 'payzen'..." -ForegroundColor Yellow
            & $psqlPath -U postgres -h localhost -c "CREATE DATABASE payzen;" 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  Database 'payzen' created" -ForegroundColor Green
            } else {
                Write-Host "  Could not create database. Please create manually:" -ForegroundColor Yellow
                Write-Host "    psql -U postgres -c 'CREATE DATABASE payzen;'" -ForegroundColor Cyan
            }
        } else {
            Write-Host "  Database 'payzen' exists" -ForegroundColor Green
        }
        
        $env:PGPASSWORD = $null
    } else {
        Write-Host "  Skipping database check (PostgreSQL not accessible)" -ForegroundColor Yellow
    }
} else {
    Write-Host "  Skipping database check (PostgreSQL not found)" -ForegroundColor Yellow
}
Write-Host ""

# Step 4: Start servers
Write-Host "[4/4] Starting servers..." -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Starting PayZen Servers" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Backend:  http://localhost:3001" -ForegroundColor Cyan
Write-Host "Frontend: http://localhost:3000" -ForegroundColor Cyan
Write-Host ""
Write-Host "Opening servers in new windows..." -ForegroundColor Yellow
Write-Host ""

# Get current directory
$currentDir = Get-Location

# Start backend in new window
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$currentDir'; Write-Host 'PayZen Backend Server' -ForegroundColor Cyan; Write-Host '====================' -ForegroundColor Cyan; Write-Host ''; npm run server:dev"

# Wait a bit
Start-Sleep -Seconds 2

# Start frontend in new window
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$currentDir'; Write-Host 'PayZen Frontend Server' -ForegroundColor Cyan; Write-Host '=====================' -ForegroundColor Cyan; Write-Host ''; npm run dev"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Servers are starting!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Two new windows have opened:" -ForegroundColor Yellow
Write-Host "  1. Backend server (port 3001)" -ForegroundColor White
Write-Host "  2. Frontend server (port 3000)" -ForegroundColor White
Write-Host ""
Write-Host "Wait for both servers to start, then open:" -ForegroundColor Cyan
Write-Host "  http://localhost:3000" -ForegroundColor Green
Write-Host ""
Write-Host "Press any key to exit this window..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
