#!/bin/bash

# Auto-launch Firefox with magenticmarket.ai using persistent profile
echo "Opening Firefox to magenticmarket.ai..."

# Wait for desktop session to be fully loaded
sleep 10

# Get current user
CURRENT_USER=$(whoami)

# Use centralized display detection script
DETECTED_DISPLAY=$(get_display --verbose)
if [ -z "$DETECTED_DISPLAY" ]; then
    echo "Failed to detect display, using fallback :0"
    DETECTED_DISPLAY=":0"
fi

# Extract display number and detect active user
DISPLAY_NUM=$(echo "$DETECTED_DISPLAY" | sed "s/://")
XORG_INFO=$(ps aux | grep "Xorg.*:" | grep -v grep | head -1)
if [ -n "$XORG_INFO" ]; then
    ACTIVE_USER=$(echo "$XORG_INFO" | awk "{print \$1}")
    echo "Found active session: user=$ACTIVE_USER, display=$DETECTED_DISPLAY"
else
    ACTIVE_USER="$CURRENT_USER"
    echo "Using fallback: user=$ACTIVE_USER, display=$DETECTED_DISPLAY"
fi

export DISPLAY="$DETECTED_DISPLAY"

FIREFOX_PROFILE_DIR="/home/$ACTIVE_USER/firefox-state"
mkdir -p "$FIREFOX_PROFILE_DIR"

# Start Firefox with persistent profile and magenticmarket.ai
if [ "$CURRENT_USER" = "root" ] && [ "$ACTIVE_USER" != "root" ]; then
    # Running as root but need to run Firefox as the active user
    echo "Running Firefox as user: $ACTIVE_USER"
    sudo -u "$ACTIVE_USER" bash -c "export DISPLAY=$DETECTED_DISPLAY && firefox -profile $FIREFOX_PROFILE_DIR http://magenticmarket.ai &"
else
    # Running as the correct user
    firefox -profile "$FIREFOX_PROFILE_DIR" http://magenticmarket.ai &
fi

echo "Firefox opened to magenticmarket.ai with persistent profile for user: $ACTIVE_USER on display: $DISPLAY"
