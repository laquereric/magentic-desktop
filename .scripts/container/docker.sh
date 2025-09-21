#!/bin/bash

echo ".scripts/00_docker.sh"

if ! service docker start; then
    echo "Docker service already running or failed to start"
fi
