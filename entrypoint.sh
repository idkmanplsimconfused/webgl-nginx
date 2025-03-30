#!/bin/bash
set -e

# Check if SSL certificates exist
if [ ! -f /etc/nginx/ssl/nginx.crt ] || [ ! -f /etc/nginx/ssl/nginx.key ]; then
    # Create directory for SSL certificates
    mkdir -p /etc/nginx/ssl
    
    # Generate self-signed certificate
    echo "Generating self-signed SSL certificate..."
    
    # Generate SSL certificate with the domain name or IP address
    if [ -n "$DOMAIN" ]; then
        echo "Using domain: $DOMAIN"
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout /etc/nginx/ssl/nginx.key \
            -out /etc/nginx/ssl/nginx.crt \
            -subj "/CN=$DOMAIN" \
            -addext "subjectAltName = DNS:$DOMAIN"
    else
        # Get server's public IP address
        PUBLIC_IP=$(wget -qO- https://ifconfig.me || echo "localhost")
        echo "No domain provided. Using public IP: $PUBLIC_IP"
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout /etc/nginx/ssl/nginx.key \
            -out /etc/nginx/ssl/nginx.crt \
            -subj "/CN=$PUBLIC_IP" \
            -addext "subjectAltName = IP:$PUBLIC_IP"
    fi
    
    chmod 600 /etc/nginx/ssl/nginx.key
fi

# Update server_name in Nginx config if domain is provided
if [ -n "$DOMAIN" ]; then
    sed -i "s/server_name _;/server_name $DOMAIN;/g" /etc/nginx/conf.d/default.conf
fi

# Find all web applications
echo "Detecting available web applications:"
APPS=$(find /usr/share/nginx/html -maxdepth 2 -name "index.html" | sed 's/\/usr\/share\/nginx\/html\///' | sed 's/\/index.html//')

for app in $APPS; do
    if [ "$app" = "index.html" ]; then
        echo "- Root application (/) detected"
    else
        echo "- Application /$app/ detected"
    fi
done

# Start Nginx
echo "Starting Nginx..."
exec nginx -g "daemon off;" 