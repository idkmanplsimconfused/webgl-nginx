#!/bin/bash
set -e

echo "Unity WebGL Nginx Docker Setup"
echo "============================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    exit 1
fi

# Ensure entrypoint script has proper Unix line endings
echo "Ensuring entrypoint script has proper line endings..."
cat > docker-entrypoint.sh << 'EOF'
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

# Set default for FORCE_HTTPS if not provided
if [ -z "${FORCE_HTTPS}" ]; then
    echo "FORCE_HTTPS not provided, defaulting to 1 (enabled)"
    FORCE_HTTPS=1
else
    if [ "${FORCE_HTTPS}" = "1" ]; then
        echo "HTTPS redirection is enabled"
    else
        echo "HTTPS redirection is disabled"
    fi
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

# Set FORCE_HTTPS environment variable for Nginx
sed -i "s/\${FORCE_HTTPS}/$FORCE_HTTPS/g" /etc/nginx/conf.d/default.conf

# Execute the original command
exec "$@"
EOF
chmod +x docker-entrypoint.sh

# Ask for domain (optional)
read -p "Enter your domain name (leave empty to use public IP or localhost): " DOMAIN

# Ask for port configuration (optional)
read -p "Enter HTTP port (leave empty to use 80): " HTTP_PORT
read -p "Enter HTTPS port (leave empty to use 443): " HTTPS_PORT

# Ask for HTTPS redirection preference
read -p "Force HTTPS redirection? (Y/n): " FORCE_HTTPS_RESPONSE
if [[ $FORCE_HTTPS_RESPONSE =~ ^[Nn]$ ]]; then
    FORCE_HTTPS=0
else
    FORCE_HTTPS=1
fi

# Set default ports if not specified
HTTP_PORT=${HTTP_PORT:-80}
HTTPS_PORT=${HTTPS_PORT:-443}

# Build Docker image
echo "Building Docker image..."
docker build -t unity-webgl-nginx .

# Run Docker container
echo "Starting container..."
if [ -z "$DOMAIN" ]; then
    docker run -d --name unity-webgl-nginx -p $HTTP_PORT:80 -p $HTTPS_PORT:443 -e FORCE_HTTPS=$FORCE_HTTPS unity-webgl-nginx
else
    docker run -d --name unity-webgl-nginx -p $HTTP_PORT:80 -p $HTTPS_PORT:443 -e DOMAIN="$DOMAIN" -e FORCE_HTTPS=$FORCE_HTTPS unity-webgl-nginx
fi

# Get container IP
CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' unity-webgl-nginx)

echo "============================="
echo "Unity WebGL server is running!"
if [ -z "$DOMAIN" ]; then
    echo "Access your application at:"
    if [ "$FORCE_HTTPS" = "1" ]; then
        echo "- Locally: https://localhost${HTTPS_PORT:+:$HTTPS_PORT}"
        PUBLIC_IP=$(wget -qO- https://ipinfo.io/ip || echo "Not available")
        if [ "$PUBLIC_IP" != "Not available" ]; then
            echo "- Public: https://$PUBLIC_IP${HTTPS_PORT:+:$HTTPS_PORT}"
        fi
    else
        echo "- HTTP Locally: http://localhost${HTTP_PORT:+:$HTTP_PORT}"
        echo "- HTTPS Locally: https://localhost${HTTPS_PORT:+:$HTTPS_PORT}"
        PUBLIC_IP=$(wget -qO- https://ipinfo.io/ip || echo "Not available")
        if [ "$PUBLIC_IP" != "Not available" ]; then
            echo "- HTTP Public: http://$PUBLIC_IP${HTTP_PORT:+:$HTTP_PORT}"
            echo "- HTTPS Public: https://$PUBLIC_IP${HTTPS_PORT:+:$HTTPS_PORT}"
        fi
    fi
else
    if [ "$FORCE_HTTPS" = "1" ]; then
        echo "Access your application at: https://$DOMAIN${HTTPS_PORT:+:$HTTPS_PORT}"
    else
        echo "Access your application at:"
        echo "- HTTP: http://$DOMAIN${HTTP_PORT:+:$HTTP_PORT}"
        echo "- HTTPS: https://$DOMAIN${HTTPS_PORT:+:$HTTPS_PORT}"
    fi
    echo "Make sure your DNS points to your server's IP address."
fi
echo "Container IP: $CONTAINER_IP"
echo "============================="
echo "To stop the server: docker stop unity-webgl-nginx"
echo "To start the server again: docker start unity-webgl-nginx"
echo "To remove the container: docker rm unity-webgl-nginx" 