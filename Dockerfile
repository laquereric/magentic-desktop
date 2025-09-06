FROM ubuntu:latest

# Update and install desktop environment and XRDP
RUN apt-get update && \
    apt-get install -y wget

RUN install -d -m 0755 /etc/apt/keyrings

# Install Desktop
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y lubuntu-desktop && \
    apt-get install -y xrdp && \
    adduser xrdp ssl-cert

# Install Firefox
COPY  config/firefox/packages.mozilla.org.asc /etc/apt/keyrings/packages.mozilla.org.asc
COPY  config/firefox/mozilla.sources /etc/apt/sources.list.d/mozilla.sources
COPY  config/firefox/mozilla /etc/apt/preferences.d/mozilla

# Install VS Code
COPY  config/vscode/microsoft.asc /etc/apt/keyrings/microsoft.asc
COPY  config/vscode/vscode.sources /etc/apt/sources.list.d/vscode.sources
COPY  config/vscode/vscode /etc/apt/preferences.d/vscode

# Update and install both applications
RUN apt-get -y update && apt-get -y --allow-downgrades install firefox code

# Copy scripts
COPY image/scripts/launch-vscode.sh /usr/local/bin/launch-vscode.sh
COPY image/scripts/add_coder /usr/local/bin/add_coder
COPY image/scripts/add_user /usr/local/bin/add_user
COPY image/scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/launch-vscode.sh /usr/local/bin/add_coder /usr/local/bin/add_user /usr/local/bin/entrypoint.sh

# Expose ports
EXPOSE 3389 8080

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]