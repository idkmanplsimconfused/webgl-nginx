#!/bin/bash
set -e

echo "WebGL Nginx Docker Server Installer"
echo "========================================"

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "Error: Git is not installed. Please install Git first."
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    exit 1
fi

# Determine directories
CURRENT_DIR="$(pwd)"
TEMP_DIR="$(pwd)/webgl-nginx-temp"

# Create temporary directory for clone
echo "Creating temporary directory..."
mkdir -p "$TEMP_DIR"

# Clone the repository
echo "Cloning repository..."
git clone https://github.com/idkmanplsimconfused/webgl-nginx.git "$TEMP_DIR"

# Move files from temp directory to current directory
echo "Moving files to current directory..."
find "$TEMP_DIR" -maxdepth 1 -mindepth 1 -not -name ".git" -exec cp -r {} "$CURRENT_DIR" \;

# Remove temporary directory
echo "Cleaning up..."
rm -rf "$TEMP_DIR"

# Make setup script executable
chmod +x setup.sh

# Run the setup script
echo "Running setup script..."
./setup.sh

echo "========================================"
echo "Installation completed successfully!"
echo "Your WebGL server has been set up." 