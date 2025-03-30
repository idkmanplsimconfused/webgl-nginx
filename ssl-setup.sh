#!/bin/bash
set -e

# This script is used to set up Let's Encrypt certificates when a domain is provided
# Usage: ./ssl-setup.sh yourdomain.com your@email.com

if [ $# -lt 2 ]; then
    echo "Usage: $0 <domain> <email>"
    exit 1
fi

DOMAIN=$1
EMAIL=$2

echo "Setting up Let's Encrypt SSL certificate for domain: $DOMAIN"
echo "Email for certificate notifications: $EMAIL"

# Install certbot (already installed in the Dockerfile)
# Create temporary Nginx configuration to obtain the certificate
cat > /etc/nginx/conf.d/temp.conf << EOF
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN;
    
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    
    location / {
        return 301 https://\$host\$request_uri;
    }
}
EOF

# Create certbot webroot directory
mkdir -p /var/www/certbot

# Reload Nginx to apply temporary config
nginx -s reload

# Obtain SSL certificate
certbot certonly --webroot \
    --webroot-path=/var/www/certbot \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    --domain $DOMAIN

# Remove temporary config
rm /etc/nginx/conf.d/temp.conf

# Update Nginx configuration to use Let's Encrypt certificate
sed -i "s|ssl_certificate /etc/nginx/ssl/nginx.crt|ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem|g" /etc/nginx/conf.d/default.conf
sed -i "s|ssl_certificate_key /etc/nginx/ssl/nginx.key|ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem|g" /etc/nginx/conf.d/default.conf

# Reload Nginx to apply new SSL certificate
nginx -s reload

# Set up auto-renewal cron job
echo "0 12 * * * certbot renew --quiet --deploy-hook 'nginx -s reload'" > /etc/crontabs/root

# Find all web applications
APPS=$(find /usr/share/nginx/html -maxdepth 2 -name "index.html" | sed 's/\/usr\/share\/nginx\/html\///' | sed 's/\/index.html//')

echo "SSL setup complete! Your web applications are now available at:"
for app in $APPS; do
    if [ "$app" = "index.html" ]; then
        echo "- Root application: https://$DOMAIN/"
    else
        echo "- $app: https://$DOMAIN/$app/"
    fi
done