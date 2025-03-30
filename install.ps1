# WebGL Nginx Docker Installer for Windows
# This script clones the repository and prepares the environment

Write-Host "===== WebGL Nginx Docker Installer =====" -ForegroundColor Cyan
Write-Host "This script will install the WebGL Nginx Docker setup on your system." -ForegroundColor Cyan
Write-Host ""

# Check if git is installed
if (-not (Get-Command "git" -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Git is not installed. Please install Git first." -ForegroundColor Red
    Write-Host "You can download Git from: https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}

# Set the repository URL, branch and directory name
$repoUrl = "https://github.com/idkmanplsimconfused/webgl-nginx.git"
$branch = "master"
$repoDir = "webgl-nginx"

# Check if we're already in the repository directory
if (Test-Path -Path "$repoDir\.git") {
    Write-Host "Repository already cloned. Updating..." -ForegroundColor Yellow
    Push-Location $repoDir
    git fetch
    git checkout $branch
    git pull origin $branch
    Pop-Location
} else {
    # Clone the repository with specific branch
    Write-Host "Cloning the repository (branch: $branch)..." -ForegroundColor Green
    git clone -b $branch $repoUrl
    
    if (-not (Test-Path -Path $repoDir)) {
        Write-Host "Error: Failed to clone the repository." -ForegroundColor Red
        exit 1
    }
}

# Change to the repository directory
Set-Location $repoDir

# Print completion message
Write-Host ""
Write-Host "===== Installation Complete =====" -ForegroundColor Green
Write-Host "The webgl-nginx repository has been cloned to: $(Get-Location)" -ForegroundColor White
Write-Host ""

# Automatically run setup.ps1
Write-Host "Running setup script now..." -ForegroundColor Green
& .\setup.ps1

# We don't return to the original directory since setup.ps1 is running