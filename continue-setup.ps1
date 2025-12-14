# PayZen - Continue Setup After Installation
# This script fixes vulnerabilities and continues project setup

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PayZen - Continue Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Fix npm vulnerabilities
Write-Host "[1/4] Fixing npm vulnerabilities..." -ForegroundColor Yellow
Write-Host ""

try {
    npm audit fix
    Write-Host "  Vulnerabilities fixed (if possible)" -ForegroundColor Green
} catch {
    Write-Host "  Warning: Some vulnerabilities may remain" -ForegroundColor Yellow
    Write-Host "  Run 'npm audit' for details" -ForegroundColor Gray
}
Write-Host ""

# Step 2: Create .env file
Write-Host "[2/4] Setting up environment file..." -ForegroundColor Yellow

if (-not (Test-Path ".env")) {
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
        Write-Host "  Created .env file from .env.example" -ForegroundColor Green
        Write-Host "  Please edit .env and configure your database settings" -ForegroundColor Yellow
    } else {
        Write-Host "  .env.example not found. Creating basic .env..." -ForegroundColor Yellow
        
        @"
# Database Configuration
DB_NAME=payzen
DB_USER=postgres
DB_PASSWORD=your_password_here
DB_HOST=localhost
DB_PORT=5432

# JWT Secret
JWT_SECRET=change-this-secret-key-in-production-min-32-characters-long

# API URLs
API_URL=http://localhost:3001
NEXT_PUBLIC_API_URL=http://localhost:3001

# Server Port
PORT=3001

# Node Environment
NODE_ENV=development
"@ | Out-File -FilePath ".env" -Encoding UTF8
        
        Write-Host "  Created basic .env file" -ForegroundColor Green
        Write-Host "  Please edit .env and configure your settings" -ForegroundColor Yellow
    }
} else {
    Write-Host "  .env file already exists" -ForegroundColor Green
}
Write-Host ""

# Step 3: Check PostgreSQL
Write-Host "[3/4] Checking PostgreSQL..." -ForegroundColor Yellow

$pgInstalled = $false
try {
    $pgVersion = psql --version 2>$null
    if ($pgVersion) {
        $pgInstalled = $true
        Write-Host "  PostgreSQL found: $pgVersion" -ForegroundColor Green
    }
} catch {
    # PostgreSQL not in PATH, check common locations
    $pgPaths = @(
        "C:\Program Files\PostgreSQL\*\bin\psql.exe",
        "C:\Program Files (x86)\PostgreSQL\*\bin\psql.exe"
    )
    
    foreach ($path in $pgPaths) {
        $found = Get-ChildItem -Path $path -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) {
            $pgInstalled = $true
            Write-Host "  PostgreSQL found at: $($found.FullName)" -ForegroundColor Green
            break
        }
    }
}

if (-not $pgInstalled) {
    Write-Host "  PostgreSQL not found" -ForegroundColor Yellow
    Write-Host "  Please install PostgreSQL from https://www.postgresql.org/download/" -ForegroundColor Yellow
    Write-Host "  Or use Docker: docker run --name postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres" -ForegroundColor Cyan
} else {
    Write-Host "  PostgreSQL is ready" -ForegroundColor Green
}
Write-Host ""

# Step 4: Database setup instructions
Write-Host "[4/4] Database setup instructions..." -ForegroundColor Yellow
Write-Host ""
Write-Host "To create the database, run in PostgreSQL:" -ForegroundColor Cyan
Write-Host "  CREATE DATABASE payzen;" -ForegroundColor White
Write-Host ""
Write-Host "Or use psql command line:" -ForegroundColor Cyan
Write-Host "  psql -U postgres -c 'CREATE DATABASE payzen;'" -ForegroundColor White
Write-Host ""

# Final message
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Setup continuation completed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Edit .env file with your database credentials" -ForegroundColor White
Write-Host "  2. Create PostgreSQL database: CREATE DATABASE payzen;" -ForegroundColor White
Write-Host "  3. Start server: npm run server:dev" -ForegroundColor White
Write-Host "  4. Start frontend: npm run dev" -ForegroundColor White
Write-Host ""
Write-Host "The database will be created automatically on first run." -ForegroundColor Gray
Write-Host ""





