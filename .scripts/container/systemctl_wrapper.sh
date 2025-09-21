#!/bin/bash

# Wrapper script for systemctl replacement to handle dbus errors gracefully

# Function to handle dbus errors
handle_dbus_error() {
    echo "WARNING: systemctl encountered dbus error, attempting to continue..."
    # Try to start dbus if not running
    if ! pgrep -x "dbus-daemon" > /dev/null; then
        echo "Starting dbus daemon..."
        dbus-daemon --system --fork
        sleep 2
    fi
}

# Set up error handling
trap 'handle_dbus_error' ERR

# Export environment variables
export SYSTEMCTL_SKIP_SYSV=1
export SYSTEMCTL_SKIP_REDIRECT=1
export SYSTEMCTL_SKIP_DBUS=0

# Run systemctl with error handling
exec /usr/local/bin/systemctl 
#"$@" 2>&1 | while IFS= read -r line; do
#    if [[ "$line" == *"unsupported run type 'dbus'"* ]]; then
#        echo "WARNING: Skipping dbus service due to compatibility issue"
#        continue
#    else
#        echo "$line"
#    fi
#done
