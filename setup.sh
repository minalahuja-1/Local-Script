#!/bin/bash

# Exit script on any error
set -e

# Check for required arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <path1> <path2>"
    exit 1
fi

# Variables
PATH1="$1"
PATH2="$2"

# Check if paths were read
if [ -z "$PATH1" ] || [ -z "$PATH2" ]; then
    echo "Some paths are missing in the path file."
    exit 1
fi

REPO_URL="https://git.soma.salesforce.com/$PATH2/ui-commerce-management-components.git"  # Replace with your repository URL
REPO_DIR="off-core-local-repo"  # Replace with your desired directory name
BRANCH="main"

# Check if Yarn is installed
if ! command -v yarn &> /dev/null; then
    echo "Yarn is not installed. Please install Yarn before running this script."
    echo "Yarn not found. Installing Yarn via Homebrew..."
    brew install yarn
fi

# Check if Maven (mvn) is installed
if ! command -v mvn &> /dev/null; then
    echo "Maven (mvn) is not installed. Please install Maven before running this script."
    echo "Maven not found. Installing Maven via Homebrew..."
    brew install maven
fi

# Clone or update the repository
if [ -d "$REPO_DIR" ]; then
    echo "Directory $REPO_DIR already exists. Pulling the latest changes."
    cd "$REPO_DIR/ui-commerce-management-components"
    git pull origin "$BRANCH"
else
    echo "Cloning the repository..."
    mkdir "$REPO_DIR"
    cd "$REPO_DIR"
    git clone "$REPO_URL"
    cd "ui-commerce-management-components"
fi

# Install dependencies with Yarn
echo "Installing dependencies..."
yarn install

# Configure VSCode 
echo "Configuring VSCode"
yarn setup:vscode
yarn setup:vscode-jest-debug-configuration

# Set Core 
echo "setting up core path"
yarn set-core $PATH1

# Yarn refresh
echo "Running Yarn build..."
yarn refresh 

yarn setup:add-to-core

# Define the file path
COMPONENT_PROPERTIES_FILE_PATH="$HOME/componentMonitoring.properties"

# Check if the file exists
if [ -f "$COMPONENT_PROPERTIES_FILE_PATH" ]; then
    echo "File exists. Clearing contents of $COMPONENT_PROPERTIES_FILE_PATH."
    > "$COMPONENT_PROPERTIES_FILE_PATH"  # Clear the file's contents
else
    echo "File does not exist. Creating $COMPONENT_PROPERTIES_FILE_PATH."
    touch "$COMPONENT_PROPERTIES_FILE_PATH"  # Create the file
fi
#
#COMPONENT_PROPERTIES_FILE_PATH = "$HOME/minalfinal.txt"
echo "$(pwd): true" >> "$COMPONENT_PROPERTIES_FILE_PATH"
echo "$(pwd)/core-dev-package: true" >> "$COMPONENT_PROPERTIES_FILE_PATH"


VAR1="DISABLE_BAZELPROJECT_FILE_MONITOR_PATH_ENABLER=true"
VAR2="COMPONENT_MONITORING_PROPERTIES=$HOME/componentMonitoring.properties"
COMMAND="export VAR1; export VAR2"

# Open a new terminal window and execute commands
osascript <<EOF
tell application "Terminal"
    do script "cd $PATH1/core; export $VAR1; export $VAR2; $COMMAND;"
end tell
EOF

echo "Setup complete! Just run the bazel build and bazel run !!!"
echo "HAPPY OFF-CORING !!!!!"