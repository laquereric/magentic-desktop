#!/bin/bash

# Configure Firefox to use persistent profile directory
# This script sets up Firefox to store its profile data in user-specific directories

echo "Configuring Firefox persistent profiles..."

# Create user-specific profile directories
for user_home in /home/*; do
    if [ -d "$user_home" ] && [ "$(basename "$user_home")" != "firefox-state" ]; then
        username=$(basename "$user_home")
        user_firefox_state="/home/$username/firefox-state"
        
        echo "Configuring Firefox profile for user: $username"
        
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
        chown -R "$username:$username" "$user_firefox_state" 2>/dev/null || true
        
        echo "Firefox profile configured for $username in: $user_firefox_state"
    fi
done

echo "Firefox profile configuration completed."
echo "Each user has their own Firefox state directory in /home/\$USER/firefox-state"
