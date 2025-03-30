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

# Check if current directory has git repo
if [ -d ".git" ]; then
    echo "Git repository already exists in current directory. Updating..."
    git remote add webgl-nginx $REPO_URL 2>/dev/null || true
    git fetch webgl-nginx
    git merge webgl-nginx/$BRANCH --allow-unrelated-histories -m "Merge webgl-nginx repository"
else
    # Clone the repository files directly into current directory
    echo "Cloning the repository (branch: $BRANCH) into current directory..."
    
    # Initialize git and pull files
    git init
    git remote add origin $REPO_URL
    git fetch origin $BRANCH
    git checkout -b $BRANCH --track origin/$BRANCH
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to clone the repository."
        exit 1
    fi
fi

# Make scripts executable
echo "Making scripts executable..."
chmod +x setup.sh
chmod +x ssl-setup.sh
chmod +x entrypoint.sh
chmod +x make-executable.sh

echo ""
echo "===== Installation Complete ====="
echo "The webgl-nginx repository has been cloned to the current directory: $(pwd)"

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