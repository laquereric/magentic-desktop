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

# Install Firefox and VS Code configurations
RUN cp /tmp/image/config/firefox/packages.mozilla.org.asc /etc/apt/keyrings/ && \
    cp /tmp/image/config/firefox/mozilla.sources /etc/apt/sources.list.d/ && \
    cp /tmp/image/config/firefox/mozilla /etc/apt/preferences.d/ && \
    cp /tmp/image/config/vscode/microsoft.asc /etc/apt/keyrings/ && \
    cp /tmp/image/config/vscode/vscode.sources /etc/apt/sources.list.d/ && \
    cp /tmp/image/config/vscode/vscode /etc/apt/preferences.d/

# Update and install both applications
RUN apt-get -y update && apt-get -y --allow-downgrades install firefox code

# Copy and setup scripts
RUN cp /tmp/image/scripts/* /usr/local/bin/ && \
    chmod +x /usr/local/bin/launch-vscode.sh /usr/local/bin/add_coder /usr/local/bin/add_user /usr/local/bin/entrypoint.sh

# Clean up temporary image directory
RUN rm -rf /tmp/image

# Expose ports
EXPOSE 3389 8080

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]