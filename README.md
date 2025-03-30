# Unity WebGL Nginx Docker Server

This package provides an easy way to host your Unity WebGL application with Nginx and Docker, including proper MIME types and compression settings for optimal delivery.

## Features

- HTTPS support with automatic self-signed certificate generation
- Support for domain names or public IP access
- Optimized Nginx configuration for Unity WebGL applications
- Support for compressed WebGL files (.gz and .br)
- Brotli compression enabled for better performance
- Works with both Linux/macOS and Windows

## Prerequisites

- Docker installed on your system
- Your Unity WebGL build files in this directory

## Directory Structure

Place your Unity WebGL build files in this directory. For example:
```
./index.html        # Main application
./x/index.html      # Secondary application or component
```

## Quick Start

### Linux/macOS

1. Make the setup script executable:
   ```
   chmod +x setup.sh
   ```

2. Run the setup script:
   ```
   ./setup.sh
   ```

3. Follow the prompts to enter an optional domain name.

### Windows

1. Right-click on `setup.ps1` and select "Run with PowerShell" 
   OR
   Open PowerShell and run:
   ```
   .\setup.ps1
   ```

2. Follow the prompts to enter an optional domain name.

## Accessing Your Application

- If you provided a domain name, access your app at `https://your-domain.com`
- If you didn't provide a domain, access your app at `https://your-public-ip`

For sub-applications:
- Main application: `https://your-domain.com` or `https://your-public-ip`
- Sub-application: `https://your-domain.com/x` or `https://your-public-ip/x`

## Managing the Docker Container

- Stop the server: `docker stop unity-webgl-nginx`
- Start the server again: `docker start unity-webgl-nginx`
- Remove the container: `docker rm unity-webgl-nginx`

## Troubleshooting

### Docker Container Won't Start

If you see an error like `exec /docker-entrypoint.sh: no such file or directory` in the Docker logs, this is typically caused by incorrect line endings in the entrypoint script. The setup scripts (`setup.sh` and `setup.ps1`) have been designed to handle this automatically by:

1. Creating the entrypoint script with the correct line endings
2. Installing `dos2unix` in the Docker image to convert line endings

If you're still having issues:
- On Windows, ensure you're using the provided `setup.ps1` script
- On Linux/macOS, ensure you're using the provided `setup.sh` script
- Manually check line endings with `file docker-entrypoint.sh`

## Image & Compression Information

This server uses:
- `fholzer/nginx-brotli` Docker image that includes Nginx with Brotli compression support
- Brotli compression provides 20-26% better compression than gzip for text-based files like JavaScript
- Both Brotli and gzip compression are enabled by default for optimal delivery

## Notes

- The server uses self-signed SSL certificates, so browsers may show a security warning.
- To use with a real domain, set up proper DNS records pointing to your server's IP address.
- For production use, consider using a proper SSL certificate from Let's Encrypt or similar. 