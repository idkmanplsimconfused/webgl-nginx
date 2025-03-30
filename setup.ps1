# Unity WebGL Nginx Docker Setup Script for Windows
# This script sets up a Docker container with Nginx to serve all HTML content in the current directory

# Check if Docker is installed
if (-not (Get-Command "docker" -ErrorAction SilentlyContinue)) {
    Write-Host "Docker is not installed. Please install Docker Desktop for Windows first." -ForegroundColor Red
    exit 1
}

# Check if Docker is running
try {
    $null = docker info
} catch {
    Write-Host "Docker is not running. Please start Docker Desktop and try again." -ForegroundColor Red
    exit 1
}

# Detect available HTML applications
Write-Host "Detecting HTML applications in current directory..." -ForegroundColor Cyan
$HTML_FILES = Get-ChildItem -Recurse -Depth 2 -Filter "index.html" | ForEach-Object { 
    $relativePath = $_.FullName.Replace("$PWD\", "").Replace("\index.html", "")
    if ($relativePath -eq "index.html") { 
        "ROOT" 
    } else { 
        $relativePath 
    }
}

if (-not $HTML_FILES) {
    Write-Host "No HTML applications found in the current directory." -ForegroundColor Red
    Write-Host "Make sure you have at least one directory with an index.html file." -ForegroundColor Red
    exit 1
}

Write-Host "Found the following applications:" -ForegroundColor Green
foreach ($app in $HTML_FILES) {
    if ($app -eq "ROOT") {
        Write-Host "- Root application (./)" -ForegroundColor Yellow
    } else {
        Write-Host "- $app" -ForegroundColor Yellow
    }
}

# Prompt for domain (optional)
$DOMAIN = Read-Host "Enter your domain name (optional, leave blank to use public IP)"
$EMAIL = ""
if ($DOMAIN) {
    $EMAIL = Read-Host "Enter email for SSL certificate notifications"
}

# Build the Docker image
Write-Host "Building Docker image..." -ForegroundColor Cyan
docker build -t unity-webgl-nginx .

# Run the container
if ($DOMAIN -and $EMAIL) {
    # Run with domain and prepare for Let's Encrypt SSL
    Write-Host "Starting Docker container with domain: $DOMAIN" -ForegroundColor Cyan
    
    # Run container with domain environment variable
    $CONTAINER_ID = docker run -d -p 80:80 -p 443:443 `
        -e DOMAIN="$DOMAIN" `
        --name unity-webgl-server `
        unity-webgl-nginx
    
    Write-Host "Container started. Waiting for initialization..." -ForegroundColor Cyan
    Start-Sleep -Seconds 5
    
    # Set up Let's Encrypt SSL certificates
    Write-Host "Setting up Let's Encrypt SSL..." -ForegroundColor Cyan
    docker exec -it unity-webgl-server /ssl-setup.sh "$DOMAIN" "$EMAIL"
} else {
    # Run with self-signed certificate using public IP
    Write-Host "Starting Docker container with self-signed SSL certificate..." -ForegroundColor Cyan
    docker run -d -p 80:80 -p 443:443 `
        --name unity-webgl-server `
        unity-webgl-nginx
}

# Display access information
Write-Host ""
Write-Host "===== SETUP COMPLETE =====" -ForegroundColor Green
$BASE_URL = ""
if ($DOMAIN) {
    $BASE_URL = "https://$DOMAIN"
} else {
    # Get the public IP address
    $PUBLIC_IP = (Invoke-WebRequest -Uri "https://ifconfig.me/ip" -UseBasicParsing).Content
    $BASE_URL = "https://$PUBLIC_IP"
    
    Write-Host "NOTE: Since you're using a self-signed certificate, your browser may show a security warning." -ForegroundColor Yellow
    Write-Host "You can bypass this by clicking 'Advanced' and then 'Proceed' in most browsers." -ForegroundColor Yellow
}

Write-Host "Your applications are now available at:" -ForegroundColor Green
foreach ($app in $HTML_FILES) {
    if ($app -eq "ROOT") {
        Write-Host "- Root application: $BASE_URL/" -ForegroundColor Yellow
    } else {
        Write-Host "- $app`: $BASE_URL/$app/" -ForegroundColor Yellow
    }
}
Write-Host "==========================" -ForegroundColor Green 