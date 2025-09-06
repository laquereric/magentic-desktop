#!/bin/bash

# ENTRYPOINT script for magentic-desktop container
# This script handles container initialization and user creation

set -e  # Exit on any error

echo "Starting magentic-desktop container initialization..."

# Function to show usage
show_usage() {
    echo "Usage: docker run [OPTIONS] magentic-desktop [COMMAND]"
    echo ""
    echo "Environment Variables:"
    echo "  CODER_USERNAME    Username for coder user (default: coder)"
    echo "  CODER_PASSWORD    Password for coder user (default: coder123)"
    echo "  VSCODE_PORT       VS Code port (default: 8080)"
    echo "  VSCODE_HOST       VS Code host (default: 0.0.0.0)"
    echo "  AUTO_LAUNCH       Enable auto-launch (default: true)"
    echo "  SKIP_CODER_USER   Skip creating coder user (default: false)"
    echo "  TEST_USERNAME     Username for test user (default: testuser)"
    echo "  TEST_PASSWORD     Password for test user (default: 1234)"
    echo "  TEST_SUDO         Grant sudo to test user (default: true)"
    echo "  SKIP_TEST_USER    Skip creating test user (default: false)"
    echo ""
    echo "Examples:"
    echo "  docker run -e CODER_USERNAME=dev -e CODER_PASSWORD=dev123 magentic-desktop"
    echo "  docker run -e VSCODE_PORT=9000 -e AUTO_LAUNCH=false magentic-desktop"
    echo "  docker run -e SKIP_CODER_USER=true magentic-desktop"
    echo "  docker run -e TEST_USERNAME=admin -e TEST_PASSWORD=admin123 magentic-desktop"
}

# Parse environment variables with defaults
CODER_USERNAME="${CODER_USERNAME:-coder}"
CODER_PASSWORD="${CODER_PASSWORD:-coder123}"
VSCODE_PORT="${VSCODE_PORT:-8080}"
VSCODE_HOST="${VSCODE_HOST:-0.0.0.0}"
AUTO_LAUNCH="${AUTO_LAUNCH:-true}"
SKIP_CODER_USER="${SKIP_CODER_USER:-false}"

# Test user configuration
TEST_USERNAME="${TEST_USERNAME:-testuser}"
TEST_PASSWORD="${TEST_PASSWORD:-1234}"
TEST_SUDO="${TEST_SUDO:-true}"
SKIP_TEST_USER="${SKIP_TEST_USER:-false}"

echo "Configuration:"
echo "  Coder Username: $CODER_USERNAME"
echo "  VS Code Port: $VSCODE_PORT"
echo "  VS Code Host: $VSCODE_HOST"
echo "  Auto-launch: $AUTO_LAUNCH"
echo "  Skip Coder User: $SKIP_CODER_USER"
echo "  Test Username: $TEST_USERNAME"
echo "  Test Sudo: $TEST_SUDO"
echo "  Skip Test User: $SKIP_TEST_USER"
echo ""

# Configure Firefox persistent profiles
echo "Configuring Firefox persistent profiles..."
if [ -f "/usr/local/bin/configure-firefox-profile.sh" ]; then
    /usr/local/bin/configure-firefox-profile.sh
fi

# Start XRDP service
echo "Starting XRDP service..."
service xrdp start

# Set Firefox as default browser
echo "Setting Firefox as default browser..."
if [ -f "/usr/local/bin/set-default-browser.sh" ]; then
    /usr/local/bin/set-default-browser.sh
fi

# Create test user if not skipped
if [ "$SKIP_TEST_USER" != "true" ]; then
    echo "Creating test user..."
    
    # Create the test user with specified parameters
    add_user \
        --username "$TEST_USERNAME" \
        --password "$TEST_PASSWORD" \
        $([ "$TEST_SUDO" = "true" ] && echo "--sudo")
    
    echo "Test user created successfully!"
else
    echo "Skipping test user creation as requested."
fi

# Create coder user if not skipped
if [ "$SKIP_CODER_USER" != "true" ]; then
    echo "Creating coder user..."
    
    # Check if user already exists
    if id "$CODER_USERNAME" &>/dev/null; then
        echo "User $CODER_USERNAME already exists, skipping creation."
    else
        # Create the coder user with specified parameters
        add_coder \
            --username "$CODER_USERNAME" \
            --password "$CODER_PASSWORD" \
            --port "$VSCODE_PORT" \
            --host "$VSCODE_HOST" \
            $([ "$AUTO_LAUNCH" = "false" ] && echo "--no-auto-launch")
        
        echo "Coder user created successfully!"
    fi
else
    echo "Skipping coder user creation as requested."
fi

echo ""
echo "Container initialization completed!"
echo "XRDP is running on port 3389"
echo "VS Code will be available on port $VSCODE_PORT"
echo ""

# If a command was provided, execute it
if [ $# -gt 0 ]; then
    echo "Executing command: $*"
    exec "$@"
else
    # Default: keep container running with bash
    echo "Starting interactive shell..."
    exec /bin/bash
fi
