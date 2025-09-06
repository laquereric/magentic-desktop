#!/bin/bash

# Script to create desktop shortcuts for all applications
# This script should be run for each user to create their desktop shortcuts

set -e  # Exit on any error

USER_HOME="$1"
if [ -z "$USER_HOME" ]; then
    echo "Usage: $0 <user_home_directory>"
    echo "Example: $0 /home/username"
    exit 1
fi

echo "Setting up desktop shortcuts for user: $USER_HOME"

# Create Desktop directory if it doesn't exist
mkdir -p "$USER_HOME/Desktop"

# Git GUI shortcut
cat > "$USER_HOME/Desktop/Git-GUI.desktop" << 'EOF'
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
cat > "$USER_HOME/Desktop/GitK.desktop" << 'EOF'
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
cat > "$USER_HOME/Desktop/Meld.desktop" << 'EOF'
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
cat > "$USER_HOME/Desktop/Git-Tools.desktop" << 'EOF'
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
cat > "$USER_HOME/Desktop/VS-Code.desktop" << 'EOF'
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
cat > "$USER_HOME/Desktop/VS-Code-Web.desktop" << 'EOF'
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
cat > "$USER_HOME/Desktop/Firefox.desktop" << 'EOF'
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
chmod +x "$USER_HOME/Desktop"/*.desktop

echo "✓ Desktop shortcuts created:"
echo "  - Git GUI (git-gui)"
echo "  - GitK (gitk)"
echo "  - Meld (file comparison)"
echo "  - Git Tools (launcher script)"
echo "  - VS Code (code editor)"
echo "  - VS Code Web (serve-web)"
echo "  - Firefox (web browser)"
echo ""
echo "All shortcuts are now available on the desktop!"
