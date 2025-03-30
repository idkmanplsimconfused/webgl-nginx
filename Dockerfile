FROM fholzer/nginx-brotli:latest

# Install dependencies
RUN apk add --no-cache openssl dos2unix

# Set working directory
WORKDIR /app

# Copy web application files
COPY . /usr/share/nginx/html/

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Create self-signed SSL directory
RUN mkdir -p /etc/nginx/ssl

# Set up entrypoint script with correct line endings
COPY docker-entrypoint.sh /
RUN dos2unix /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh

# Expose ports
EXPOSE 80 443

# Set entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"] 