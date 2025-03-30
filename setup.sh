#!/bin/bash
set -e

# Unity WebGL Nginx Docker Setup Script
# This script sets up a Docker container with Nginx to serve all HTML content in the current directory

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker first."
    exit 1
fi

# Detect available HTML applications
echo "Detecting HTML applications in current directory..."
HTML_FILES=$(find . -maxdepth 2 -name "index.html" | sed 's/.\///' | sed 's/\/index.html//')
if [ -z "$HTML_FILES" ]; then
    echo "No HTML applications found in the current directory."
    echo "Make sure you have at least one directory with an index.html file."
    exit 1
fi

echo "Found the following applications:"
for app in $HTML_FILES; do
    if [ "$app" = "index.html" ]; then
        echo "- Root application (./)"
    else
        echo "- $app"
    fi
done

# Prompt for domain (optional)
read -p "Enter your domain name (optional, leave blank to use public IP): " DOMAIN
read -p "Enter email for SSL certificate notifications (only needed if domain is provided): " EMAIL

# Build the Docker image
echo "Building Docker image..."
docker build -t unity-webgl-nginx .

# Run the container
if [ -n "$DOMAIN" ] && [ -n "$EMAIL" ]; then
    # Run with domain and prepare for Let's Encrypt SSL
    echo "Starting Docker container with domain: $DOMAIN"
    
    # Run container with domain environment variable
    CONTAINER_ID=$(docker run -d -p 80:80 -p 443:443 \
        -e DOMAIN="$DOMAIN" \
        --name unity-webgl-server \
        unity-webgl-nginx)
    
    echo "Container started. Waiting for initialization..."
    sleep 5
    
    # Set up Let's Encrypt SSL certificates
    echo "Setting up Let's Encrypt SSL..."
    docker exec -it unity-webgl-server /ssl-setup.sh "$DOMAIN" "$EMAIL"
else
    # Run with self-signed certificate using public IP
    echo "Starting Docker container with self-signed SSL certificate..."
    docker run -d -p 80:80 -p 443:443 \
        --name unity-webgl-server \
        unity-webgl-nginx
    
    # Get the container's public IP
    PUBLIC_IP=$(wget -qO- https://ifconfig.me || echo "localhost")
    echo "Container started with self-signed certificate."
fi

# Display access information
echo ""
echo "===== SETUP COMPLETE ====="
BASE_URL=""
if [ -n "$DOMAIN" ]; then
    BASE_URL="https://$DOMAIN"
else
    PUBLIC_IP=$(wget -qO- https://ifconfig.me || echo "localhost")
    BASE_URL="https://$PUBLIC_IP"
    echo "NOTE: Since you're using a self-signed certificate, your browser may show a security warning."
    echo "You can bypass this by clicking 'Advanced' and then 'Proceed' in most browsers."
fi

echo "Your applications are now available at:"
for app in $HTML_FILES; do
    if [ "$app" = "index.html" ]; then
        echo "- Root application: $BASE_URL/"
    else
        echo "- $app: $BASE_URL/$app/"
    fi
done
echo "==========================="