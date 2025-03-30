Write-Host "Unity WebGL Nginx Docker Setup" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan

# Check if Docker is installed
try {
    docker --version | Out-Null
} catch {
    Write-Host "Error: Docker is not installed or not running. Please install Docker Desktop for Windows first." -ForegroundColor Red
    exit 1
}

# Create entrypoint script with proper Unix line endings
Write-Host "Creating entrypoint script with proper line endings..." -ForegroundColor Yellow
$entrypointContent = @'
#!/bin/sh
set -e

# Get the server's public IP if domain is not provided
if [ -z "${DOMAIN}" ]; then
    echo "No domain provided, using public IP address"
    PUBLIC_IP=$(wget -qO- https://ipinfo.io/ip || echo "localhost")
    DOMAIN=$PUBLIC_IP
    echo "Using IP: $DOMAIN"
else
    echo "Using domain: $DOMAIN"
fi

# Generate SSL certificate if not already present
if [ ! -f "/etc/nginx/ssl/nginx.crt" ] || [ ! -f "/etc/nginx/ssl/nginx.key" ]; then
    echo "Generating self-signed SSL certificate for $DOMAIN"
    
    # Create a config file for OpenSSL (for Alpine compatibility)
    cat > /tmp/openssl.cnf << EOC
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
CN = $DOMAIN

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = $DOMAIN
IP.1 = $PUBLIC_IP
EOC

    # Generate the certificate using the config file
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -config /tmp/openssl.cnf
        
    # Clean up
    rm -f /tmp/openssl.cnf
fi

# Replace server_name in the Nginx configuration
sed -i "s/server_name _;/server_name $DOMAIN;/g" /etc/nginx/conf.d/default.conf

# Execute the original command
exec "$@"
'@

# Write content with Unix line endings
$utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText("$pwd\docker-entrypoint.sh", $entrypointContent, $utf8NoBomEncoding)

# Ask for domain (optional)
$DOMAIN = Read-Host "Enter your domain name (leave empty to use public IP or localhost)"

# Ask for port configuration (optional)
$HTTP_PORT = Read-Host "Enter HTTP port (leave empty to use 80)"
$HTTPS_PORT = Read-Host "Enter HTTPS port (leave empty to use 443)"

# Set default ports if not specified
if ([string]::IsNullOrEmpty($HTTP_PORT)) { $HTTP_PORT = "80" }
if ([string]::IsNullOrEmpty($HTTPS_PORT)) { $HTTPS_PORT = "443" }

# Build Docker image
Write-Host "Building Docker image..." -ForegroundColor Yellow
docker build -t unity-webgl-nginx .

# Run Docker container
Write-Host "Starting container..." -ForegroundColor Yellow
if ([string]::IsNullOrEmpty($DOMAIN)) {
    docker run -d --name unity-webgl-nginx -p ${HTTP_PORT}:80 -p ${HTTPS_PORT}:443 unity-webgl-nginx
} else {
    docker run -d --name unity-webgl-nginx -p ${HTTP_PORT}:80 -p ${HTTPS_PORT}:443 -e DOMAIN="$DOMAIN" unity-webgl-nginx
}

# Get container IP
$CONTAINER_IP = docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' unity-webgl-nginx

Write-Host "=============================" -ForegroundColor Cyan
Write-Host "Unity WebGL server is running!" -ForegroundColor Green
if ([string]::IsNullOrEmpty($DOMAIN)) {
    Write-Host "Access your application at:" -ForegroundColor Green
    $portSuffix = if ($HTTPS_PORT -ne "443") { ":$HTTPS_PORT" } else { "" }
    Write-Host "- Locally: https://localhost$portSuffix" -ForegroundColor Green
    try {
        $PUBLIC_IP = Invoke-RestMethod -Uri "https://ipinfo.io/ip"
        Write-Host "- Public: https://$PUBLIC_IP$portSuffix" -ForegroundColor Green
    } catch {
        Write-Host "Could not determine public IP." -ForegroundColor Yellow
    }
} else {
    $portSuffix = if ($HTTPS_PORT -ne "443") { ":$HTTPS_PORT" } else { "" }
    Write-Host "Access your application at: https://$DOMAIN$portSuffix" -ForegroundColor Green
    Write-Host "Make sure your DNS points to your server's IP address." -ForegroundColor Yellow
}
Write-Host "Container IP: $CONTAINER_IP" -ForegroundColor Yellow
Write-Host "=============================" -ForegroundColor Cyan
Write-Host "To stop the server: docker stop unity-webgl-nginx" -ForegroundColor Gray
Write-Host "To start the server again: docker start unity-webgl-nginx" -ForegroundColor Gray
Write-Host "To remove the container: docker rm unity-webgl-nginx" -ForegroundColor Gray 