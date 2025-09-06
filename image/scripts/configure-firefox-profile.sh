#!/bin/bash

# Configure Firefox to use persistent profile directory
# This script sets up Firefox to store its profile data in the mounted volume

FIREFOX_STATE_DIR="/home/firefox-state"
FIREFOX_PROFILE_DIR="$FIREFOX_STATE_DIR/firefox-profiles"

echo "Configuring Firefox persistent profile..."

# Create Firefox profile directory if it doesn't exist
mkdir -p "$FIREFOX_PROFILE_DIR"

# Set proper permissions
chmod 755 "$FIREFOX_PROFILE_DIR"

# Create a default profile for all users
DEFAULT_PROFILE="$FIREFOX_PROFILE_DIR/default"
if [ ! -d "$DEFAULT_PROFILE" ]; then
    echo "Creating default Firefox profile..."
    mkdir -p "$DEFAULT_PROFILE"
    
    # Create basic profile structure
    mkdir -p "$DEFAULT_PROFILE/chrome"
    mkdir -p "$DEFAULT_PROFILE/extensions"
    
    # Set permissions
    chmod -R 755 "$DEFAULT_PROFILE"
fi

# Create user-specific profile directories
for user_home in /home/*; do
    if [ -d "$user_home" ] && [ "$(basename "$user_home")" != "firefox-state" ]; then
        username=$(basename "$user_home")
        user_profile="$FIREFOX_PROFILE_DIR/$username"
        
        if [ ! -d "$user_profile" ]; then
            echo "Creating Firefox profile for user: $username"
            mkdir -p "$user_profile"
            mkdir -p "$user_profile/chrome"
            mkdir -p "$user_profile/extensions"
            chmod -R 755 "$user_profile"
        fi
        
        # Set ownership to the user
        chown -R "$username:$username" "$user_profile" 2>/dev/null || true
    fi
done

echo "Firefox profile configuration completed."
echo "Profiles stored in: $FIREFOX_PROFILE_DIR"
