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

# Set the repository URL, branch
$repoUrl = "https://github.com/idkmanplsimconfused/webgl-nginx.git"
$branch = "master"

# Check if current directory has git repo
if (Test-Path -Path ".git") {
    Write-Host "Git repository already exists in current directory. Updating..." -ForegroundColor Yellow
    git remote add webgl-nginx $repoUrl 2>$null
    git fetch webgl-nginx
    git merge webgl-nginx/$branch --allow-unrelated-histories -m "Merge webgl-nginx repository"
} else {
    # Clone the repository files directly into current directory
    Write-Host "Cloning the repository (branch: $branch) into current directory..." -ForegroundColor Green
    
    # Initialize git and pull files
    git init
    git remote add origin $repoUrl
    git fetch origin $branch
    git checkout -b $branch --track origin/$branch
    
    if (-not $?) {
        Write-Host "Error: Failed to clone the repository." -ForegroundColor Red
        exit 1
    }
}

# Make scripts executable (PowerShell doesn't need this, but keeping for consistency)
Write-Host "Preparing scripts..." -ForegroundColor Cyan

# Print completion message
Write-Host ""
Write-Host "===== Installation Complete =====" -ForegroundColor Green
Write-Host "The webgl-nginx repository has been cloned to the current directory: $(Get-Location)" -ForegroundColor White
Write-Host ""

# Automatically run setup.ps1
Write-Host "Running setup script now..." -ForegroundColor Green
& .\setup.ps1