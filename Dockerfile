FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y gpg lsb_release curl nano

RUN install -d -m 0755 /etc/apt/keyrings

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod go+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \

# Update and install basic packages
RUN apt-get install -y git gh && \
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
    apt-get install -y buildah podman && \
    apt-get install -y x11-xkb-utils && \
    apt-get install -y ca-certificates curl gnupg lsb-release && \
    apt-get install -y python3-full python3-pip python3-venv python3-dev python3-setuptools python3-wheel pipx&& \
    apt-get install -y python3-tk python3-numpy python3-scipy python3-matplotlib python3-pandas && \
    apt-get install -y nodejs npm default-jre && \
    apt-get install -y build-essential libssl-dev libreadline-dev zlib1g-dev && \
    apt-get install -y ruby-full ruby-dev && \
    apt-get install -y DEBIAN_FRONTEND=noninteractive lubuntu-desktop && \
    apt-get install -y xrdp && \
    apt-get -y --allow-downgrades install firefox code meld
    
RUN chown -R xrdp:xrdp /home/xrdp && \
    adduser xrdp ssl-cert && \
    systemctl enable docker && \
    usermod -aG docker root && \
    usermod -aG docker xrdp

# Copy image directory as a unit
COPY image/ /tmp/image/

# Install Firefox and VS Code configurations
RUN mv /tmp/image/config/firefox/packages.mozilla.org.asc /etc/apt/keyrings/ && \
    mv /tmp/image/config/firefox/mozilla.sources /etc/apt/sources.list.d/ && \
    mv /tmp/image/config/firefox/mozilla /etc/apt/preferences.d/ && \
    mv /tmp/image/config/vscode/microsoft.asc /etc/apt/keyrings/ && \
    mv /tmp/image/config/vscode/vscode.sources /etc/apt/sources.list.d/ && \
    mv /tmp/image/config/vscode/vscode /etc/apt/preferences.d/

# Copy and setup scripts
RUN chmod +x /tmp/image/scripts/* && \
    mv /tmp/image/scripts/* /usr/local/bin/

# Install Ruby gems
RUN mkdir -p /ruby

COPY Gemfile* /ruby

RUN gem install bundler && \
    cd /ruby && \
    bundle install

# Expose ports
EXPOSE 3389 8080

# Writes to host desks/entrypoint.sh will uverride image value because of VOLUME mapping
COPY desks/ /desks/
RUN chmod +x /desks/*

ENTRYPOINT ["/desks/entrypoint.sh"]
