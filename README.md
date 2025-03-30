# WebGL Nginx Docker Server

This package provides an easy way to host any WebGL application (including Unity, PlayCanvas, Three.js, Babylon.js, and more) with Nginx and Docker, including proper MIME types and compression settings for optimal delivery.

## Features

- HTTPS support with automatic self-signed certificate generation
- Optional HTTP to HTTPS redirection (can be disabled)
- Support for domain names, public IP, or localhost access
- Configurable HTTP/HTTPS ports
- Optimized Nginx configuration for WebGL applications
- Support for compressed WebGL files (.gz and .br)
- Brotli compression enabled for better performance
- Works with both Linux/macOS and Windows

## Prerequisites

- Docker installed on your system
- Git installed on your system (for installation via install scripts)
- Your WebGL build files to host

## Quick Installation

### Linux/macOS

Download and run the installation script with a single command:
```bash
curl -sSL https://raw.githubusercontent.com/idkmanplsimconfused/webgl-nginx/main/install.sh | bash
```

Or download the script first and then run it:
```bash
curl -O https://raw.githubusercontent.com/idkmanplsimconfused/webgl-nginx/main/install.sh
chmod +x install.sh
./install.sh
```

### Windows

Download and run the installation script with PowerShell:
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/idkmanplsimconfused/webgl-nginx/main/install.ps1" -OutFile "install.ps1"
.\install.ps1
```

## Manual Setup

If you prefer to clone the repository manually:

### Linux/macOS

1. Clone the repository:
   ```
   git clone https://github.com/idkmanplsimconfused/webgl-nginx.git
   cd webgl-nginx
   ```

2. Make the setup script executable:
   ```
   chmod +x setup.sh
   ```

3. Run the setup script:
   ```
   ./setup.sh
   ```

4. Follow the prompts to enter optional domain name, ports, and HTTPS redirection preference.

### Windows

1. Clone the repository:
   ```
   git clone https://github.com/idkmanplsimconfused/webgl-nginx.git
   cd webgl-nginx
   ```

2. Right-click on `setup.ps1` and select "Run with PowerShell" 
   OR
   Open PowerShell and run:
   ```
   .\setup.ps1
   ```

3. Follow the prompts to enter optional domain name, ports, and HTTPS redirection preference.

## Directory Structure

Place your WebGL build files in this directory. For example:
```
./index.html        # Main application
./x/index.html      # Secondary application or component
```

## Compatibility

This server is optimized for all WebGL frameworks and engines, including:
- Unity WebGL builds
- PlayCanvas
- Three.js
- Babylon.js
- p5.js
- And any other WebGL-based application

## Configuration Options

During setup, you'll be asked to configure:

1. **Domain Name** (optional) - Your custom domain name or leave empty to use public IP/localhost
2. **HTTP Port** (default: 80) - The port for HTTP traffic
3. **HTTPS Port** (default: 443) - The port for HTTPS traffic
4. **Force HTTPS Redirection** (default: Yes) - Whether to automatically redirect HTTP traffic to HTTPS

## Accessing Your Application

If HTTPS redirection is enabled (default):
- **Local Access**: `https://localhost[:port]`
- **Public Access**: `https://your-public-ip[:port]`
- **Domain Access**: `https://your-domain[:port]` (if domain was provided)

If HTTPS redirection is disabled:
- **HTTP Local Access**: `http://localhost[:http-port]`
- **HTTPS Local Access**: `https://localhost[:https-port]`
- **HTTP Public Access**: `http://your-public-ip[:http-port]`
- **HTTPS Public Access**: `https://your-public-ip[:https-port]`
- **HTTP Domain Access**: `http://your-domain[:http-port]` (if domain was provided)
- **HTTPS Domain Access**: `https://your-domain[:https-port]` (if domain was provided)

For sub-applications:
- Main application: `https://localhost[:port]` or `https://your-domain[:port]`
- Sub-application: `https://localhost[:port]/x` or `https://your-domain[:port]/x`

## Custom Ports

If ports 80 and 443 are already in use on your machine, you can specify alternative ports during setup:
- HTTP port: The port to use for HTTP traffic (default: 80)
- HTTPS port: The port to use for HTTPS traffic (default: 443)

For example, if you specify 8080 for HTTP and 8443 for HTTPS, access your app at:
```
https://localhost:8443
```

## Managing the Docker Container

- Stop the server: `docker stop webgl-nginx`
- Start the server again: `docker start webgl-nginx`
- Remove the container: `docker rm webgl-nginx`

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

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

For questions, issues, or suggestions, please contact:
- Email: atqamz@gmail.com
- GitHub: [atqamz](https://github.com/atqamz)

## Notes

- The server uses self-signed SSL certificates, so browsers may show a security warning.
- To use with a real domain, set up proper DNS records pointing to your server's IP address.
- For production use, consider using a proper SSL certificate from Let's Encrypt or similar. 