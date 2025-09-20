# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

Repository purpose
- Build and run a Dockerized Lubuntu desktop environment with XRDP and development tooling (Docker-in-Docker, VS Code, Ruby, Node). The container is intended to be started via Docker Compose and interacted with over RDP (port 3389) or an interactive shell.

Prerequisites (macOS host)
- Docker Desktop installed and running (provides `docker` and `docker compose`).
- The host paths referenced in compose.yml must exist on this machine:
  - /Users/ericlaquer/Secrets -> mounted to /Secrets in the container
  - /Users/ericlaquer/Documents/GitHub -> mounted to /GitHub in the container
- Optional: RDP client to connect to localhost:3389

Common commands
- Build the image (no cache):
  - ./scripts/build
  - docker compose build --no-cache

- Start the container (recommended: run the Ruby entrypoint inside):
  - ./scripts/compose -s "/scripts/entrypoint.rb" up
  Notes:
  - The compose wrapper sets OVERRIDE_COMMAND to the given value and uses bash -c to run it as the container command.
  - Without an override, compose.yml defaults to /desks/entrypoint.sh which is not provided by this repo. Always pass -s or use the shell mode below.

- Rebuild the image and start fresh (cleans old containers/images):
  - ./scripts/compose -s "/scripts/entrypoint.rb" rebuild

- Follow logs:
  - ./scripts/compose logs

- Stop and remove the container:
  - ./scripts/compose down

- Check status:
  - ./scripts/compose status

- Open an interactive shell in a running container:
  - ./scripts/compose shell

- One-off exec examples (in a running container):
  - docker compose exec magentic-desktop ruby -v
  - docker compose exec magentic-desktop bundle exec ruby /scripts/catalog.rb

Notes about tests and linting
- This repository does not define a test or linting stack. There are no spec/ or test/ trees and no Ruby/Node linters configured. Use the commands above for smoke checks (e.g., run catalog.rb) if needed.

High-level architecture
- Orchestration (compose.yml)
  - Single service: magentic-desktop
  - Builds from Dockerfile in this repo
  - entrypoint overridden to ["/bin/bash", "-c"], with command derived from OVERRIDE_COMMAND
  - Ports: 3389 (XRDP), 8080 (VS Code)
  - Privileged: true; mounts the Docker socket (/var/run/docker.sock) to enable Docker-in-Docker workflows
  - Volumes (host -> container):
    - /Users/ericlaquer/Secrets -> /Secrets
    - /Users/ericlaquer/Documents/GitHub -> /GitHub (used by the Ruby Gemfile to access local gems)
    - /var/run/docker.sock -> /var/run/docker.sock
    - /tmp/.X11-unix -> /tmp/.X11-unix
    - /var/lib/containers -> /var/lib/containers
    - ./.gem -> /.gem

- Image build (Dockerfile)
  - Base: ubuntu:latest
  - Installs: Docker Engine/CLI, XRDP, Lubuntu desktop, VS Code (via Microsoft repo), Node.js, Ruby (ruby-full, ruby-dev), build-essential, and assorted tooling
  - Adds APT keyrings and repos for Docker, VS Code, and Firefox (see image_config/*)
  - Copies container_scripts/* into /scripts and marks them executable
  - Exposes ports 3389 and 8080
  - Note: The image-level ENTRYPOINT points to /scripts/entrypoint.sh, but compose.yml overrides ENTRYPOINT to use bash -c. The provided workflows rely on the compose override; prefer the compose wrapper.

- Container initialization flow (/scripts/*.rb)
  - /scripts/entrypoint.rb (run with ./scripts/compose -s "/scripts/entrypoint.rb" up):
    - Starts the Docker service inside the container
    - Installs bundler, runs bundle install using Gemfile at image root
    - Executes bundle exec ruby /scripts/catalog.rb
    - Ensures XRDP service is running
    - If a command is provided as an argument, execs it; otherwise drops to an interactive shell
  - /scripts/catalog.rb:
    - Requires the lubuntu-gui Ruby gem and instantiates a LubuntuGui::Catalog based on files under /scripts
    - Useful for smoke verification of catalog parsing; run via docker compose exec magentic-desktop bundle exec ruby /scripts/catalog.rb
  - The Gemfile pins Ruby dependencies and references a local gem path mounted from the host: gem "lubuntu-gui", path: "/GitHub/lubuntu-gui"

- Configuration assets (image_config/*)
  - firefox/: apt pinning and repo sources for Mozilla Firefox
  - vscode/: Microsoft GPG key and repo configuration for VS Code

Development tips specific to this repo
- Always use the compose wrapper (./scripts/compose …). It handles cleanup, sets OVERRIDE_COMMAND, and provides consistent start/logs/down/status flows without relying on a non-existent /desks/entrypoint.sh.
- If bundle install fails due to missing /GitHub/lubuntu-gui, ensure the host directory exists (it is mounted via compose.yml).
- To run custom startup logic, pass a shell override. Examples:
  - ./scripts/compose -s "bash" up
  - ./scripts/compose -s "bash -lc 'bundle install && ruby /scripts/catalog.rb'" up
