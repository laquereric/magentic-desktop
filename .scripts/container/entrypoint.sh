#!/bin/bash 
# ENTRYPOINT script for magentic-desktop container
# This script handles container initialization and user creation

echo "Container initialization started!"
echo " "

/scripts/docker.sh
/scripts/xdisplay.rb
/scripts/bundle.rb

echo " "
echo "Container initialization completed!"
echo "XRDP is running on port 3389"
echo " "

# Set up environment for systemctl replacement
export SYSTEMCTL_SKIP_SYSV=1
export SYSTEMCTL_SKIP_REDIRECT=1
export SYSTEMCTL_SKIP_DBUS=0

# Configure bash history
export HISTFILE=/root/.bash_history
export HISTSIZE=1000
export HISTFILESIZE=2000
export HISTCONTROL=ignoredups:erasedups

# Create history file if it doesn't exist
touch /root/.bash_history

# Set up bashrc for better terminal experience
cat > /root/.bashrc << 'EOF'
# Enable history
export HISTFILE=/root/.bash_history
export HISTSIZE=1000
export HISTFILESIZE=2000
export HISTCONTROL=ignoredups:erasedups

# Enable history sharing between sessions
shopt -s histappend
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# Set up prompt
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Enable color support
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# Aliases
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
EOF

# Start interactive bash shell
#echo "Starting interactive shell..."
#exec /bin/bash

# Start PID1 with systemctl
exec systemctl
