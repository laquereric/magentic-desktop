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

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --user)
            TARGET_USER="$2"
            shift 2
            ;;
        --system)
            TARGET_SYSTEM="true"
            shift
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

# Validation: If TARGET_USER is not set and CREATE_SYSTEM is not set, abort
if [ -z "$TARGET_USER" ] && [ "$TARGET_SYSTEM" != "true" ]; then
    echo "Error: Either --user USERNAME or --system must be specified"
    echo ""
    show_usage
    exit 1
fi

# Function to create system-wide autostart entries
create_for_system() {
    echo "image/scripts/setup-desktop-shortcuts.sh - system"
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

}



# Function to create desktop shortcuts for a user
create_for_user() {
    echo "image/scripts/setup-desktop-shortcuts.sh - $TARGET_USER"

    local user_home="/home/$TARGET_USER"
    
    if [ -z "TARGET_USER" ]; then
        echo "Error: Username required for desktop shortcuts"
        return 1
    fi
    
    if [ ! -d "$user_home" ]; then
        echo "Warning: User home directory $user_home does not exist"
        return 1
    fi
    
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
    chown -R "$TARGET_USER:$TARGET_USER" "$user_home/Desktop"
    
    # Create user autostart directory
    mkdir -p "$user_home/.config/autostart"
    chown -R "$TARGET_USER:$TARGET_USER" "$user_home/.config/autostart"

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

}

# Main execution
main() {
    # Create system-wide autostart entries
    if [ "$TARGET_SYSTEM" = "true" ]; then
        create_for_system
    fi
    
    # Create user-specific shortcuts and autostart
    if [ -n "$TARGET_USER" ]; then
        create_for_user
    fi

}

# Run main function
main