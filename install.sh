#!/bin/bash
# WebGL Nginx Docker Installer
# This script clones the repository and prepares the environment

set -e

echo "===== WebGL Nginx Docker Installer ====="
echo "This script will install the WebGL Nginx Docker setup on your system."

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "Error: Git is not installed. Please install Git first."
    exit 1
fi

# Set repository URL and branch
REPO_URL="https://github.com/idkmanplsimconfused/webgl-nginx.git"
BRANCH="master"

# Check if we're already in the repository directory
if [ -d "webgl-nginx/.git" ]; then
    echo "Repository already cloned. Updating..."
    cd webgl-nginx
    git fetch
    git checkout $BRANCH
    git pull origin $BRANCH
else
    # Clone the repository with specific branch
    echo "Cloning the repository (branch: $BRANCH)..."
    git clone -b $BRANCH $REPO_URL
    
    if [ ! -d "webgl-nginx" ]; then
        echo "Error: Failed to clone the repository."
        exit 1
    fi
    
    cd webgl-nginx
fi

# Make scripts executable using make-executable.sh
echo "Making scripts executable..."
chmod +x make-executable.sh
./make-executable.sh

echo ""
echo "===== Installation Complete ====="
echo "The webgl-nginx repository has been cloned to: $(pwd)"

# Automatically run setup.sh
echo "Running setup script now..."
./setup.sh

echo ""
echo "Next steps:"
echo "1. Place your web application content in the webgl-nginx directory"
echo "2. Run ./setup.sh to build and run the Docker container"
echo ""
echo "For more information, see the README.md file or visit:"
echo "https://github.com/idkmanplsimconfused/webgl-nginx" 