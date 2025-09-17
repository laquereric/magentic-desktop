FROM ubuntu:latest

# Update and install desktop environment and XRDP
RUN apt-get update && \
    apt-get install -y nano && \
    apt-get install -y git && \
    apt-get install -y x11-xkb-utils 

RUN install -d -m 0755 /etc/apt/keyrings

# Install Desktop
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y lubuntu-desktop && \
    apt-get install -y xrdp && \
    adduser xrdp ssl-cert

# Copy image directory as a unit
COPY image/ /tmp/image/

# Install Firefox and VS Code configurations
RUN mv /tmp/image/config/firefox/packages.mozilla.org.asc /etc/apt/keyrings/ && \
    mv /tmp/image/config/firefox/mozilla.sources /etc/apt/sources.list.d/ && \
    mv /tmp/image/config/firefox/mozilla /etc/apt/preferences.d/ && \
    mv /tmp/image/config/vscode/microsoft.asc /etc/apt/keyrings/ && \
    mv /tmp/image/config/vscode/vscode.sources /etc/apt/sources.list.d/ && \
    mv /tmp/image/config/vscode/vscode /etc/apt/preferences.d/

# Update package lists and install applications
RUN apt-get -y update && apt-get -y --allow-downgrades install firefox code git-gui gitk meld


# Copy and setup scripts
RUN chmod +x /tmp/image/scripts/* && \
    mv /tmp/image/scripts/* /usr/local/bin/

# Expose ports
EXPOSE 3389 8080

# Writes to host desks/entrypoint.sh will uverride image value because of VOLUME mapping
COPY desks/ /desks/
RUN chmod +x /desks/*

ENTRYPOINT ["/desks/entrypoint.sh"]
