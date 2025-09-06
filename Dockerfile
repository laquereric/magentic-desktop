FROM ubuntu:latest

# Update and install desktop environment and XRDP
RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y lubuntu-desktop && \
    apt install -y xrdp && \
    adduser xrdp ssl-cert

RUN apt-get install wget

RUN install -d -m 0755 /etc/apt/keyrings

RUN wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

COPY  image/etc/apt/keyrings/microsoft.asc /etc/apt/keyrings/microsoft.asc

COPY  image/etc/apt/sources.list.d/mozilla.sources /etc/apt/sources.list.d/mozilla.sources

COPY  image/etc/apt/sources.list.d/vscode.sources /etc/apt/sources.list.d/vscode.sources

COPY  image/etc/apt/preferences.d/mozilla /etc/apt/preferences.d/mozilla

COPY  image/etc/apt/preferences.d/vscode /etc/apt/preferences.d/vscode

RUN apt-get -y update && apt-get -y --allow-downgrades install firefox code

# Create a user and add to sudo group
RUN useradd -m testuser && \
    echo "testuser:1234" | chpasswd && \
    usermod -aG sudo testuser

# Expose port 3389
EXPOSE 3389

# Start services

CMD service xrdp start && \
    /bin/bash