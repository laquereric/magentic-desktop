#!/bin/bash

# ENTRYPOINT script for magentic-desktop container
# This script handles container initialization and user creation

set -e  # Exit on any error

# Function to show usage
show_usage() {
    echo "Usage: docker run [OPTIONS] magentic-desktop [COMMAND]"
    echo ""
    echo "Environment Variables:"
    echo "  CODER_USERNAME    Username for coder user (default: coder)"
    echo "  CODER_PASSWORD    Password for coder user (default: coder123)"
    echo "  TEST_USERNAME     Username for test user (default: testuser)"
    echo "  TEST_PASSWORD     Password for test user (default: 1234)"
    echo "  VSCODE_PORT       VS Code port (default: 8080)"
    echo "  VSCODE_HOST       VS Code host (default: 0.0.0.0)"
    echo ""
    echo "Examples:"
    echo "  docker run -e CODER_USERNAME=dev -e CODER_PASSWORD=dev123 magentic-desktop"
    echo "  docker run -e VSCODE_PORT=9000 -e AUTO_LAUNCH_VSCODE=false magentic-desktop"
    echo "  docker run -e TEST_USERNAME=admin -e TEST_PASSWORD=admin123 magentic-desktop"
}

main() {
    echo "scripts/entrypoint.sh - Starting magentic-desktop container initialization..."

    echo "Prep Python with pipx..."
    #pipx_bootstrap.sh
    pipx_config.sh

    # Start Docker service
    echo "Starting Docker service..."
    service docker start || echo "Docker service already running or failed to start"
    
    # Create system-wide desktop shortcuts and autostart entries
    setup-desktop-shortcuts.sh --system

    # Parse environment variables with defaults
    CODER_USERNAME="${CODER_USERNAME:-coder}"
    CODER_PASSWORD="${CODER_PASSWORD:-coder123}"
    # Test user configuration
    TEST_USERNAME="${TEST_USERNAME:-testuser}"
    TEST_PASSWORD="${TEST_PASSWORD:-1234}"

    VSCODE_PORT="${VSCODE_PORT:-8080}"
    VSCODE_HOST="${VSCODE_HOST:-0.0.0.0}"
    echo " "
    echo "Configuration:"
    echo "  VS Code Port: $VSCODE_PORT"
    echo "  VS Code Host: $VSCODE_HOST"
    echo " "
    # Create the test user with specified parameters
    add_a_user \
        --username "$TEST_USERNAME" \
        --password "$TEST_PASSWORD" \
        --port "$VSCODE_PORT" \
        --host "$VSCODE_HOST"
    
    echo " "
    # Create the test user with specified parameters
    add_a_user \
        --username "$CODER_USERNAME" \
        --password "$CODER_PASSWORD" \
        --port "$VSCODE_PORT" \
        --host "$VSCODE_HOST"

    echo " "
    # Check and start XRDP service
    echo "Checking XRDP service status..."
     
    if service xrdp status >/dev/null 2>&1; then
        echo "XRDP service is already running."
    else
        echo "XRDP service is not running. Starting XRDP service..."
        service xrdp start
        echo "XRDP service started successfully."
    fi

    echo " "
    echo "Container initialization completed!"
    echo "XRDP is running on port 3389"
    echo "VS Code will be available on port $VSCODE_PORT"
    echo " "

    # If a command was provided, execute it
    if [ $# -gt 0 ]; then
        echo "Executing command: $*"
        exec "$@"
    else
        # Default: keep container running with bash
        echo "Starting interactive shell..."
        exec /bin/bash
    fi
}

main "$@"
