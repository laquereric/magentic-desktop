FROM ubuntu:latest

# Update and install desktop environment and XRDP
RUN apt-get update && \
    apt-get install -y wget

RUN install -d -m 0755 /etc/apt/keyrings

# Install Desktop
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y lubuntu-desktop && \
    apt-get install -y xrdp && \
    adduser xrdp ssl-cert

# Copy image directory as a unit
COPY image/ /tmp/image/

# Copy and setup scripts
RUN chmod +x /tmp/image/scripts/* && \
    mv /tmp/image/scripts/* /usr/local/bin/

# Install Firefox and VS Code configurations
RUN mv /tmp/image/config/firefox/packages.mozilla.org.asc /etc/apt/keyrings/ && \
    mv /tmp/image/config/firefox/mozilla.sources /etc/apt/sources.list.d/ && \
    mv /tmp/image/config/firefox/mozilla /etc/apt/preferences.d/ && \
    mv /tmp/image/config/vscode/microsoft.asc /etc/apt/keyrings/ && \
    mv /tmp/image/config/vscode/vscode.sources /etc/apt/sources.list.d/ && \
    mv /tmp/image/config/vscode/vscode /etc/apt/preferences.d/

# Update package lists and install applications
RUN apt-get -y update && apt-get -y --allow-downgrades install firefox code git-gui gitk meld

# Clean up temporary image directory
RUN rm -rf /tmp/image

# Create Firefox state directories for persistent profiles
RUN mkdir -p /home/testuser/firefox-state && \
    mkdir -p /home/coder/firefox-state && \
    chmod 755 /home/testuser/firefox-state && \
    chmod 755 /home/coder/firefox-state

# Create generic Firefox startup script with proper display detection
RUN echo '#!/bin/bash\n\
\n\
# Auto-launch Firefox with magenticmarket.ai using persistent profile\n\
echo "Opening Firefox to magenticmarket.ai..."\n\
\n\
# Wait for desktop session to be fully loaded\n\
sleep 10\n\
\n\
# Get current user\n\
CURRENT_USER=$(whoami)\n\
\n\
# Auto-detect the correct display and user\n\
# Look for Xorg processes and extract the display number and user\n\
XORG_INFO=$(ps aux | grep "Xorg.*:" | grep -v grep | head -1)\n\
if [ -n "$XORG_INFO" ]; then\n\
    DISPLAY_NUM=$(echo "$XORG_INFO" | sed -n "s/.*Xorg :\\([0-9]*\\).*/\\1/p")\n\
    ACTIVE_USER=$(echo "$XORG_INFO" | awk "{print \\$1}")\n\
    echo "Found active session: user=$ACTIVE_USER, display=:$DISPLAY_NUM"\n\
else\n\
    # Fallback\n\
    DISPLAY_NUM="0"\n\
    ACTIVE_USER="$CURRENT_USER"\n\
    echo "Using fallback: user=$ACTIVE_USER, display=:$DISPLAY_NUM"\n\
fi\n\
\n\
export DISPLAY=":$DISPLAY_NUM"\n\
\n\
FIREFOX_PROFILE_DIR="/home/$ACTIVE_USER/firefox-state"\n\
mkdir -p "$FIREFOX_PROFILE_DIR"\n\
\n\
# Start Firefox with persistent profile and magenticmarket.ai\n\
if [ "$CURRENT_USER" = "root" ] && [ "$ACTIVE_USER" != "root" ]; then\n\
    # Running as root but need to run Firefox as the active user\n\
    echo "Running Firefox as user: $ACTIVE_USER"\n\
    sudo -u "$ACTIVE_USER" bash -c "export DISPLAY=:$DISPLAY_NUM && firefox -profile $FIREFOX_PROFILE_DIR http://magenticmarket.ai &"\n\
else\n\
    # Running as the correct user\n\
    firefox -profile "$FIREFOX_PROFILE_DIR" http://magenticmarket.ai &\n\
fi\n\
\n\
echo "Firefox opened to magenticmarket.ai with persistent profile for user: $ACTIVE_USER on display: $DISPLAY"' > /usr/local/bin/start-firefox-magentic.sh && \
    chmod +x /usr/local/bin/start-firefox-magentic.sh

# Create system-wide Firefox autostart entry
RUN echo '[Desktop Entry]\n\
Type=Application\n\
Name=Firefox Auto Launch\n\
Comment=Automatically launch Firefox with magenticmarket.ai\n\
Exec=/usr/local/bin/start-firefox-magentic.sh\n\
Hidden=false\n\
NoDisplay=false\n\
X-GNOME-Autostart-enabled=true' > /etc/xdg/autostart/firefox.desktop

# Expose ports
EXPOSE 3389 8080

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]