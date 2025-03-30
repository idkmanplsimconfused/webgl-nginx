FROM nginx:alpine

# Install required packages
RUN apk add --no-cache bash openssl certbot certbot-nginx

# Copy Nginx config
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

# Create directory for applications
RUN mkdir -p /usr/share/nginx/html

# Copy all web content to nginx html directory
COPY . /usr/share/nginx/html/

# Remove configuration files from the HTML directory
RUN cd /usr/share/nginx/html && \
    rm -f Dockerfile nginx.conf default.conf entrypoint.sh ssl-setup.sh setup.sh setup.ps1 .dockerignore

# Copy SSL setup scripts
COPY ssl-setup.sh /ssl-setup.sh
RUN chmod +x /ssl-setup.sh

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"] 