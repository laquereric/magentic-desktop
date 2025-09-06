#!/bin/bash

# Script to create all desktop shortcuts and autostart entries
# This script consolidates all desktop shortcut and autostart logic
# including user desktop shortcuts, system autostart, and user autostart

set -e  # Exit on any error
# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --user USERNAME     Create shortcuts for specific user"
    echo "  --system            Create system-wide autostart entries"
    echo "  --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --user testuser  # Create shortcuts for testuser"
    echo "  $0 --system         # Create system-wide autostart"
}

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
        --system)
            CREATE_SYSTEM="true"
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

# Function to create desktop shortcuts for a user
create_desktop_shortcuts() {
    local username="$1"
    local user_home="/home/$username"
    
    if [ -z "$username" ]; then
        echo "Error: Username required for desktop shortcuts"
        return 1
    fi
    
    if [ ! -d "$user_home" ]; then
        echo "Warning: User home directory $user_home does not exist"
        return 1
    fi
    
    echo "Creating desktop shortcuts for user: $username"
    
    # Create Desktop directory if it doesn't exist
    mkdir -p "$user_home/Desktop"
    
    # Git GUI shortcut
    cat > "$user_home/Desktop/Git-GUI.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Git GUI
Comment=Git repository browser and commit tool
Exec=git-gui
Icon=git
Terminal=false
StartupNotify=true
Categories=Development;VersionControl;
EOF

    # GitK shortcut
    cat > "$user_home/Desktop/GitK.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=GitK
Comment=Git repository history viewer
Exec=gitk --all
Icon=git
Terminal=false
StartupNotify=true
Categories=Development;VersionControl;
EOF

    # Meld shortcut
    cat > "$user_home/Desktop/Meld.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Meld
Comment=File and directory comparison tool
Exec=meld
Icon=meld
Terminal=false
StartupNotify=true
Categories=Development;FileManager;
EOF

    # Git GUI Launcher shortcut
    cat > "$user_home/Desktop/Git-Tools.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Git Tools
Comment=Launch Git GUI tools
Exec=/usr/local/bin/launch-git-gui.sh
Icon=git
Terminal=false
StartupNotify=true
Categories=Development;VersionControl;
EOF

    # VS Code shortcut
    cat > "$user_home/Desktop/VS-Code.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=VS Code
Comment=Visual Studio Code - Code Editor
Exec=code
Icon=code
Terminal=false
StartupNotify=true
Categories=Development;TextEditor;
EOF

    # VS Code Web shortcut
    cat > "$user_home/Desktop/VS-Code-Web.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=VS Code Web
Comment=Launch VS Code serve-web
Exec=/usr/local/bin/launch-vscode.sh
Icon=code
Terminal=false
StartupNotify=true
Categories=Development;TextEditor;
EOF

    # Firefox shortcut
    cat > "$user_home/Desktop/Firefox.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Firefox
Comment=Firefox Web Browser
Exec=firefox
Icon=firefox
Terminal=false
StartupNotify=true
Categories=Network;WebBrowser;
EOF

    # Make all shortcuts executable
    chmod +x "$user_home/Desktop"/*.desktop
    
    # Set proper ownership
    chown -R "$username:$username" "$user_home/Desktop"
    
    echo "✓ Desktop shortcuts created for $username:"
    echo "  - Git GUI (git-gui)"
    echo "  - GitK (gitk)"
    echo "  - Meld (file comparison)"
    echo "  - Git Tools (launcher script)"
    echo "  - VS Code (code editor)"
    echo "  - VS Code Web (serve-web)"
    echo "  - Firefox (web browser)"
}

# Function to create system-wide autostart entries
create_system_autostart() {
    echo "image/scripts/setup-desktop-shortcuts.sh - Creating system-wide autostart entries..."
    
    # Create system autostart directory
    mkdir -p /etc/xdg/autostart
    
    # Firefox autostart entry
    cat > /etc/xdg/autostart/firefox.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Firefox Auto Launch
Comment=Automatically launch Firefox with magenticmarket.ai
Exec=/usr/local/bin/start-firefox-magentic.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
    
    echo "✓ System-wide autostart entries created:"
    echo "  - Firefox auto-launch"
}

# Function to create user-specific autostart entries
create_user_autostart() {
 
    local username="$1"
    local user_home="/home/$username"
   
    if [ -z "$username" ]; then
        echo "Error: Username required for user autostart"
        return 1
    fi
    
    if [ ! -d "$user_home" ]; then
        echo "Warning: User home directory $user_home does not exist"
        return 1
    fi
    
    echo "image/scripts/setup-desktop-shortcuts.sh - create_user_autostart() for $username"

    # Create user autostart directory
    mkdir -p "$user_home/.config/autostart"
    
    # VS Code autostart entry
    cat > "$user_home/.config/autostart/vscode.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=VS Code Auto Launch
Comment=Automatically launch VS Code serve-web
Exec=/usr/local/bin/launch-vscode.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
    
    # Firefox autostart entry (user-specific)
    cat > "$user_home/.config/autostart/firefox.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=Firefox Auto Launch
Comment=Automatically launch Firefox with magenticmarket.ai
Exec=/usr/local/bin/start-firefox-magentic.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
    
    # Set proper ownership
    chown -R "$username:$username" "$user_home/.config/autostart"
    
    echo "✓ User autostart entries created for $username:"
    echo "  - VS Code auto-launch"
    echo "  - Firefox auto-launch"
}

# Main execution
main() {
    echo "image/scripts/setup-desktop-shortcuts.sh - Setting up desktop shortcuts and autostart entries..."
    
    # Create system-wide autostart entries
    if [ "$CREATE_SYSTEM" = "true" ]; then
        create_system_autostart
    fi
    
    # Create user-specific shortcuts and autostart
    if [ -n "$TARGET_USER" ]; then
        create_desktop_shortcuts "$TARGET_USER"
    fi

    echo ""
    echo "Desktop shortcuts and autostart configuration completed!"
    echo ""
    echo "Summary:"
    echo "  - Desktop shortcuts: Created for easy application access"
    echo "  - System autostart: Firefox auto-launches on desktop startup"
    echo "  - User autostart: VS Code and Firefox auto-launch per user"
    echo ""
    echo "Users can now:"
    echo "  - Double-click desktop shortcuts to launch applications"
    echo "  - Have applications auto-start when they log in"
    echo "  - Access all development tools from the desktop"
}

# Run main function
main