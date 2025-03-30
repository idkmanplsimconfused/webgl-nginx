Write-Host "WebGL Nginx Docker Server Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Check if git is installed
try {
    git --version | Out-Null
} catch {
    Write-Host "Error: Git is not installed. Please install Git for Windows first." -ForegroundColor Red
    exit 1
}

# Check if Docker is installed
try {
    docker --version | Out-Null
} catch {
    Write-Host "Error: Docker is not installed or not running. Please install Docker Desktop for Windows first." -ForegroundColor Red
    exit 1
}

# Determine directories
$CURRENT_DIR = Get-Location
$TEMP_DIR = Join-Path -Path (Get-Location) -ChildPath "webgl-nginx-temp"

# Create temporary directory for clone
Write-Host "Creating temporary directory..." -ForegroundColor Yellow
if (Test-Path -Path $TEMP_DIR) {
    Write-Host "Removing existing temporary directory..." -ForegroundColor Yellow
    Remove-Item -Path $TEMP_DIR -Recurse -Force
}
New-Item -ItemType Directory -Path $TEMP_DIR | Out-Null

# Clone the repository
Write-Host "Cloning repository..." -ForegroundColor Yellow
git clone https://github.com/idkmanplsimconfused/webgl-nginx.git $TEMP_DIR

# Move files from temp directory to current directory
Write-Host "Moving files to current directory..." -ForegroundColor Yellow
Get-ChildItem -Path $TEMP_DIR -Exclude ".git" | Copy-Item -Destination $CURRENT_DIR -Recurse -Force

# Remove temporary directory
Write-Host "Cleaning up..." -ForegroundColor Yellow
Remove-Item -Path $TEMP_DIR -Recurse -Force

# Run the setup script
Write-Host "Running setup script..." -ForegroundColor Yellow
& "$CURRENT_DIR\setup.ps1"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installation completed successfully!" -ForegroundColor Green
Write-Host "Your WebGL server has been set up." -ForegroundColor Green 