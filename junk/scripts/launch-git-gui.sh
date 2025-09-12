#!/bin/bash

# Script to launch Git GUI tools
# Provides a menu to choose between different Git GUI applications

set -e  # Exit on any error

echo "Git GUI Tools Launcher"
echo "======================"
echo ""
echo "Available Git GUI tools:"
echo "1. Git GUI (git-gui) - Simple Git repository browser"
echo "2. GitK (gitk) - Git repository browser and history viewer"
echo "3. Meld - File and directory comparison tool"
echo "4. All tools (launch all three)"
echo ""

# Function to launch git-gui
launch_git_gui() {
    echo "Launching Git GUI..."
    export DISPLAY=:0
    git-gui &
    echo "Git GUI launched!"
}

# Function to launch gitk
launch_gitk() {
    echo "Launching GitK..."
    export DISPLAY=:0
    gitk --all &
    echo "GitK launched!"
}

# Function to launch meld
launch_meld() {
    echo "Launching Meld..."
    export DISPLAY=:0
    meld &
    echo "Meld launched!"
}

# Function to launch all tools
launch_all() {
    echo "Launching all Git GUI tools..."
    launch_git_gui
    sleep 1
    launch_gitk
    sleep 1
    launch_meld
    echo "All Git GUI tools launched!"
}

# Check if we're in a Git repository
if [ -d ".git" ]; then
    echo "✓ Git repository detected"
    echo ""
    
    # If running in interactive mode, show menu
    if [ -t 0 ]; then
        read -p "Choose an option (1-4): " choice
        case $choice in
            1)
                launch_git_gui
                ;;
            2)
                launch_gitk
                ;;
            3)
                launch_meld
                ;;
            4)
                launch_all
                ;;
            *)
                echo "Invalid option. Launching Git GUI by default..."
                launch_git_gui
                ;;
        esac
    else
        # Non-interactive mode, launch Git GUI by default
        echo "Non-interactive mode detected. Launching Git GUI..."
        launch_git_gui
    fi
else
    echo "⚠️  No Git repository found in current directory"
    echo "Available options:"
    echo "1. Launch Meld (file comparison tool)"
    echo "2. Launch Git GUI (will prompt for repository)"
    echo ""
    
    if [ -t 0 ]; then
        read -p "Choose an option (1-2): " choice
        case $choice in
            1)
                launch_meld
                ;;
            2)
                launch_git_gui
                ;;
            *)
                echo "Invalid option. Launching Meld by default..."
                launch_meld
                ;;
        esac
    else
        echo "Non-interactive mode detected. Launching Meld..."
        launch_meld
    fi
fi

echo ""
echo "Git GUI tools are now running!"
echo "You can also launch them manually:"
echo "  git-gui    - Git repository browser"
echo "  gitk --all - Git history viewer"
echo "  meld       - File comparison tool"
