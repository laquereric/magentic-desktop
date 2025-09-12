#!/bin/bash

# Script to launch VS Code serve-web and open in Firefox
# This script starts VS Code in web mode, captures the URL, and opens it in Firefox

set -e  # Exit on any error

echo "Starting VS Code serve-web..."

# Function to cleanup background processes on exit
cleanup() {
    echo "Cleaning up..."
    if [ ! -z "$VSCODE_PID" ]; then
        kill $VSCODE_PID 2>/dev/null || true
    fi
    if [ ! -z "$FIREFOX_PID" ]; then
        kill $FIREFOX_PID 2>/dev/null || true
    fi
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Start VS Code serve-web in background
echo "Launching VS Code serve-web..."
code serve-web --port 8080 --host 0.0.0.0 --without-connection-token &
VSCODE_PID=$!

# Wait for VS Code to start up
echo "Waiting for VS Code to start..."
sleep 5

# Try to get the URL from VS Code output
echo "Attempting to capture VS Code URL..."

# Wait a bit more for the server to fully start
sleep 3

# The URL should be available at localhost:8080
VSCODE_URL="http://localhost:8080"

echo "VS Code URL: $VSCODE_URL"

# Start Firefox and open the URL
echo "Opening VS Code in Firefox..."
export DISPLAY=:0
firefox "$VSCODE_URL" &
FIREFOX_PID=$!

echo "VS Code is now running at: $VSCODE_URL"
echo "Firefox has been launched to open the URL"
echo ""
echo "Press Ctrl+C to stop both VS Code and Firefox"

# Wait for user to stop the script
wait $VSCODE_PID
