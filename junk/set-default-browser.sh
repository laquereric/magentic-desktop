#!/bin/bash

# Script to set Firefox as the default browser
# This script configures the desktop environment to use Firefox as default

set -e  # Exit on any error

echo "Setting Firefox as default browser..."

# Function to set default browser for a user
set_user_default_browser() {
    local USER_HOME="$1"
    local USERNAME="$2"
    
    if [ -z "$USER_HOME" ] || [ -z "$USERNAME" ]; then
        echo "Error: USER_HOME and USERNAME are required"
        return 1
    fi
    
    echo "Setting default browser for user: $USERNAME"
    
    # Create .local/share/applications directory
    mkdir -p "$USER_HOME/.local/share/applications"
    
    # Create mimeapps.list to set Firefox as default for web protocols
    cat > "$USER_HOME/.local/share/applications/mimeapps.list" << EOF
[Default Applications]
text/html=firefox.desktop
text/xml=firefox.desktop
application/xhtml+xml=firefox.desktop
application/xml=firefox.desktop
application/rss+xml=firefox.desktop
application/rdf+xml=firefox.desktop
image/gif=firefox.desktop
image/jpeg=firefox.desktop
image/png=firefox.desktop
image/svg+xml=firefox.desktop
image/webp=firefox.desktop
application/x-extension-htm=firefox.desktop
application/x-extension-html=firefox.desktop
application/x-extension-shtml=firefox.desktop
application/x-extension-xht=firefox.desktop
application/x-extension-xhtml=firefox.desktop
application/x-extension-xml=firefox.desktop
application/x-extension-xsl=firefox.desktop
x-scheme-handler/http=firefox.desktop
x-scheme-handler/https=firefox.desktop
x-scheme-handler/ftp=firefox.desktop
x-scheme-handler/chrome=firefox.desktop
x-scheme-handler/about=firefox.desktop
x-scheme-handler/unknown=firefox.desktop

[Added Associations]
text/html=firefox.desktop;
text/xml=firefox.desktop;
application/xhtml+xml=firefox.desktop;
application/xml=firefox.desktop;
application/rss+xml=firefox.desktop;
application/rdf+xml=firefox.desktop;
image/gif=firefox.desktop;
image/jpeg=firefox.desktop;
image/png=firefox.desktop;
image/svg+xml=firefox.desktop;
image/webp=firefox.desktop;
application/x-extension-htm=firefox.desktop;
application/x-extension-html=firefox.desktop;
application/x-extension-shtml=firefox.desktop;
application/x-extension-xht=firefox.desktop;
application/x-extension-xhtml=firefox.desktop;
application/x-extension-xml=firefox.desktop;
application/x-extension-xsl=firefox.desktop;
x-scheme-handler/http=firefox.desktop;
x-scheme-handler/https=firefox.desktop;
x-scheme-handler/ftp=firefox.desktop;
x-scheme-handler/chrome=firefox.desktop;
x-scheme-handler/about=firefox.desktop;
x-scheme-handler/unknown=firefox.desktop;
EOF

    # Create .config directory for additional configuration
    mkdir -p "$USER_HOME/.config"
    
    # Create mimeapps.list in .config as well (some systems use this location)
    cp "$USER_HOME/.local/share/applications/mimeapps.list" "$USER_HOME/.config/mimeapps.list"
    
    # Set proper ownership (only if user exists)
    if id "$USERNAME" &>/dev/null; then
        chown -R "$USERNAME:$USERNAME" "$USER_HOME/.local" "$USER_HOME/.config"
    else
        echo "Warning: User $USERNAME does not exist, skipping ownership setup"
    fi
    
    echo "✓ Default browser set to Firefox for user: $USERNAME"
}

# Function to set system-wide default browser
set_system_default_browser() {
    echo "Setting system-wide default browser..."
    
    # Update alternatives system (if available)
    if command -v update-alternatives >/dev/null 2>&1; then
        # Create Firefox alternative for x-www-browser
        update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/firefox 200 || true
        
        # Set Firefox as the default
        update-alternatives --set x-www-browser /usr/bin/firefox || true
        
        echo "✓ System-wide default browser set to Firefox"
    else
        echo "⚠️  update-alternatives not available, skipping system-wide configuration"
    fi
    
    # Create system-wide mimeapps.list
    mkdir -p /usr/share/applications
    
    cat > /usr/share/applications/mimeapps.list << EOF
[Default Applications]
text/html=firefox.desktop
text/xml=firefox.desktop
application/xhtml+xml=firefox.desktop
application/xml=firefox.desktop
application/rss+xml=firefox.desktop
application/rdf+xml=firefox.desktop
image/gif=firefox.desktop
image/jpeg=firefox.desktop
image/png=firefox.desktop
image/svg+xml=firefox.desktop
image/webp=firefox.desktop
application/x-extension-htm=firefox.desktop
application/x-extension-html=firefox.desktop
application/x-extension-shtml=firefox.desktop
application/x-extension-xht=firefox.desktop
application/x-extension-xhtml=firefox.desktop
application/x-extension-xml=firefox.desktop
application/x-extension-xsl=firefox.desktop
x-scheme-handler/http=firefox.desktop
x-scheme-handler/https=firefox.desktop
x-scheme-handler/ftp=firefox.desktop
x-scheme-handler/chrome=firefox.desktop
x-scheme-handler/about=firefox.desktop
x-scheme-handler/unknown=firefox.desktop
EOF

    echo "✓ System-wide mimeapps.list created"
}

# Main execution
echo "Configuring Firefox as default browser..."

# Set system-wide defaults
set_system_default_browser

# Set defaults for existing users
if [ -d "/home" ]; then
    for USER_DIR in /home/*; do
        if [ -d "$USER_DIR" ] && [ "$(basename "$USER_DIR")" != "lost+found" ]; then
            USERNAME=$(basename "$USER_DIR")
            set_user_default_browser "$USER_DIR" "$USERNAME"
        fi
    done
fi

# Set default for root user if needed
if [ -d "/root" ]; then
    set_user_default_browser "/root" "root"
fi

echo ""
echo "✓ Firefox has been set as the default browser!"
echo "✓ All web links will now open in Firefox"
echo "✓ Configuration applied to all users"
