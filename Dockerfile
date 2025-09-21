FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y gpg lsb-release curl zsh nano git gh inetutils-ping net-tools iproute2 nmap snap

RUN install -d -m 0755 /etc/apt/keyrings

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod go+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg && \
    chmod go+r /etc/apt/keyrings/microsoft.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list > /dev/null && \
    apt-get update

# Update and install basic packages
RUN apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
    apt-get install -y x11-xkb-utils && \
    apt-get install -y ca-certificates gnupg lsb-release && \
    apt-get install -y nodejs yarn && \
    apt-get install -y build-essential libssl-dev libreadline-dev zlib1g-dev && \
    apt-get install -y ruby-full ruby-dev && \
    apt-get install -y xrdp

# Install Desktop Environment and Applications
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y lubuntu-desktop && \
    apt-get install -y code && \
    apt-get -y --allow-downgrades install firefox meld git-gui gitk && \
    xdg-mime default code.desktop text/plain

RUN id -u xrdp 2>/dev/null || adduser --disabled-password --gecos "" xrdp; \
    adduser xrdp ssl-cert || true; \
    mkdir -p /home/xrdp; \
    chown -R xrdp:xrdp /home/xrdp; \
    chmod 755 /home/xrdp; \
    systemctl enable docker; \
    usermod -aG docker root; \
    usermod -aG docker xrdp || true

# Copy .config/ directory as a unit
COPY .config/image /.config

# Install Firefox configurations
RUN mv /config/firefox/packages.mozilla.org.asc /etc/apt/keyrings/ && \
    mv /config/firefox/mozilla.sources /etc/apt/sources.list.d/ && \
    mv /config/firefox/mozilla /etc/apt/preferences.d/

    ############################################################

# Copy image_config directory as a unit
COPY .scripts/container /.scripts/

RUN chmod +x /.scripts/*

COPY Gemfile* /

EXPOSE 3389 8080

ENTRYPOINT ["/.scripts/entrypoint.sh"]
