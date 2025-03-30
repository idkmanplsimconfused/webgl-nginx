# WebGL Docker Setup with Nginx

This project provides a Docker setup for hosting WebGL applications and other web content using Nginx with HTTPS support. The configuration is designed to serve any HTML content in the directory where you run the setup scripts.

## Features

- Modular design that automatically detects and serves all web applications in the current directory
- Nginx server optimized for WebGL content, particularly Unity WebGL applications
- HTTPS support with either:
  - Self-signed certificates (when using IP address)
  - Let's Encrypt certificates (when using a domain name)
- Proper MIME type handling for compressed WebGL files (.gz and .br)
- Automatic handling of gzip and Brotli compression
- Support for both domain names and public IP addresses

## Prerequisites

- Docker installed on your system
- Open ports 80 and 443 on your firewall/network
- (Optional) A domain name pointing to your server's IP address

## Quick Installation

### For Windows (PowerShell):

Run this command in PowerShell from the directory containing your web applications:

```powershell
irm https://raw.githubusercontent.com/idkmanplsimconfused/webgl-nginx/master/install-direct.ps1 | iex
```

### For Linux/macOS:

Run this command in your terminal from the directory containing your web applications:

```bash
curl -fsSL https://raw.githubusercontent.com/idkmanplsimconfused/webgl-nginx/master/install-direct.sh | bash
```

**Note:** The installation scripts will clone the repository files directly into your current directory. Make sure you run these commands in a directory that contains your web applications or where you want the server to be installed.

## Manual Installation

If you prefer to install manually:

```bash
# Navigate to the directory containing your web applications
cd /path/to/your/webapps

# Initialize git repository and pull webgl-nginx files
git init
git remote add origin https://github.com/idkmanplsimconfused/webgl-nginx.git
git fetch origin master
git checkout -b master --track origin/master

# Make scripts executable (Linux/macOS only)
chmod +x setup.sh ssl-setup.sh entrypoint.sh
```

## Directory Structure

The setup expects the following structure:
```
your-project-directory/  (where you run the installation)
├── setup.sh                # Linux/macOS setup script
├── setup.ps1               # Windows setup script
├── Dockerfile              # Docker configuration
├── nginx.conf              # Nginx main configuration
├── default.conf            # Nginx server configuration
├── entrypoint.sh           # Docker container entrypoint
├── ssl-setup.sh            # Let's Encrypt SSL setup script
├── app1/                   # Your first web application
│   └── index.html          # Entry point for app1
├── app2/                   # Your second web application
│   └── index.html          # Entry point for app2
└── index.html              # (Optional) Root web application
```

Any directory containing an index.html file (up to 2 levels deep) will be detected and served.

## Setup Instructions

### For Linux/macOS:

1. Run the setup script:
   ```bash
   ./setup.sh
   ```

2. Follow the prompts to enter your domain name (optional) and email address (for Let's Encrypt).

### For Windows:

1. Run the PowerShell script:
   ```powershell
   .\setup.ps1
   ```

2. Follow the prompts to enter your domain name (optional) and email address (for Let's Encrypt).

## Manual Setup

If you prefer to set up manually after installation:

1. Build the Docker image:
   ```bash
   docker build -t webgl-nginx .
   ```

2. Run with a domain name:
   ```bash
   docker run -d -p 80:80 -p 443:443 -e DOMAIN="yourdomain.com" --name webgl-server webgl-nginx
   docker exec -it webgl-server /ssl-setup.sh "yourdomain.com" "your@email.com"
   ```

   Or run with public IP (self-signed certificate):
   ```bash
   docker run -d -p 80:80 -p 443:443 --name webgl-server webgl-nginx
   ```

## Accessing Your Applications

After setup, your web applications will be available at:

- If using a domain:
  - Root application: `https://yourdomain.com/`
  - Other apps: `https://yourdomain.com/app-directory/`

- If using IP:
  - Root application: `https://your.public.ip/`
  - Other apps: `https://your.public.ip/app-directory/`

**Note:** When using a self-signed certificate with IP, your browser will show a security warning. You can bypass this by clicking "Advanced" and then "Proceed" in most browsers.

## Management Commands

- Stop the container:
  ```bash
  docker stop webgl-server
  ```

- Start the container:
  ```bash
  docker start webgl-server
  ```

- Remove the container:
  ```bash
  docker rm -f webgl-server
  ```

## Customization

If you want to customize the setup, you can modify:

- `nginx.conf` - Main Nginx configuration
- `default.conf` - Server block configuration
- `entrypoint.sh` - Container startup script
- `ssl-setup.sh` - Let's Encrypt SSL setup script