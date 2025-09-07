#!/bin/bash

# Configure Firefox to use persistent profile directory
# This script sets up Firefox to store its profile data in user-specific directories
set -e  # Exit on any error
# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --user USERNAME     Create shortcuts for specific user"
    echo "  --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --user testuser  # Create shortcuts for testuser"
}
# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --user)
            USERNAME="$2"
            shift 2
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo ""
            show_usage
            exit 1
            ;;
    esac
done
# Default values
TARGET_USER=""
CREATE_SYSTEM="false"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --user)
            TARGET_USER="$2"
            shift 2
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

USER_HOME="/home/$USERNAME"

user_firefox_state="/home/$USERNAME/firefox-state"

echo "Configuring Firefox profile for user: $USERNAME"

# Create user's Firefox state directory if it doesn't exist
mkdir -p "$user_firefox_state"

# Set proper permissions
chmod 755 "$user_firefox_state"

# Create basic profile structure
mkdir -p "$user_firefox_state/chrome"
mkdir -p "$user_firefox_state/extensions"

# Set permissions
chmod -R 755 "$user_firefox_state"

# Set ownership to the user
chown -R "$USERNAME:$USERNAME" "$user_firefox_state" 2>/dev/null || true
