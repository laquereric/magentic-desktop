#!/bin/bash

# ENTRYPOINT script for magentic-desktop container
# This script handles container initialization and user creation

set -e  # Exit on any error

echo "script/compose - Starting magentic-desktop container initialization..."

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

echo "Configuration:"
echo "  Coder Username: $CODER_USERNAME"
echo "  Coder Password: $CODER_PASSWORD"
echo "  Test Username: $TEST_USERNAME"
echo "  Test Password: $TEST_PASSWORD"
echo "  VS Code Port: $VSCODE_PORT"
echo "  VS Code Host: $VSCODE_HOST"
echo ""


# Start XRDP service
echo "Starting XRDP service..."
service xrdp start

# Create test user if not skipped

    echo "Creating test user..."
    
    # Create the test user with specified parameters
    add_user \
        --username "$TEST_USERNAME" \
        --password "$TEST_PASSWORD" \
        $([ "$TEST_SUDO" = "true" ] && echo "--sudo")
    
    # Create directories and set up Firefox profile, bashrc, keyboard, and shortcuts for test user
    add_user_dirs --user "$TEST_USERNAME"
    set_firefox_profile --user "$TEST_USERNAME"
    setup_firefox_bashrc --user "$TEST_USERNAME"
    set_keyboard --user "$TEST_USERNAME"
    setup-desktop-shortcuts.sh --user "$TEST_USERNAME"
    set_firefox_profile --user testuser

    echo "Test user created successfully!"

# Create coder user if not skipped

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
            $([ "$AUTO_LAUNCH_VSCODE" = "false" ] && echo "--no-auto-launch")
        
        # Create directories and set up Firefox profile, bashrc, keyboard, and shortcuts for coder user
        add_user_dirs --user "$CODER_USERNAME"
        set_firefox_profile --user "$CODER_USERNAME"
        setup_firefox_bashrc --user "$CODER_USERNAME"
        set_keyboard --user "$CODER_USERNAME"
        setup-desktop-shortcuts.sh --user "$CODER_USERNAME"
        set_firefox_profile --user coder
        echo "Coder user created successfully!"
    fi


# Set Firefox as default browser (after users are created)
echo "Setting Firefox as default browser..."
if [ -f "/usr/local/bin/set-default-browser.sh" ]; then
    /usr/local/bin/set-default-browser.sh
fi

# Configure Firefox persistent profiles
echo "Configuring Firefox persistent profiles..."
if [ -f "/usr/local/bin/configure-firefox-profile.sh" ]; then
    /usr/local/bin/configure-firefox-profile.sh
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
