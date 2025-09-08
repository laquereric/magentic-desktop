FROM ubuntu:latest

# Update and install desktop environment and XRDP
RUN apt-get update && \
    apt-get install -y buildah && \
    apt-get install -y podman && \
    apt-get install -y nano && \
    apt-get install -y git && \
    apt-get install -y x11-xkb-utils && \
    apt-get install -y ruby-full && \
    apt-get install -y ca-certificates curl gnupg lsb-release

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh

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

# Install Ruby gems
COPY Gemfile /tmp/Gemfile
RUN gem install bundler && \
    cd /tmp && \
    bundle install --system

# Expose ports
EXPOSE 3389 8080

# Writes to host desks/entrypoint.sh will uverride image value because of VOLUME mapping
COPY desks/ /desks/
RUN chmod +x /desks/*

ENTRYPOINT ["/desks/entrypoint.sh"]
