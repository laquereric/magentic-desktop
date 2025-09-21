#!/bin/bash

echo ".scripts/0_bundler.sh"

# Start Docker service
echo "Starting Docker service..."
if ! service docker start; then
    echo "Docker service already running or failed to start"
fi

echo " "

# Install bundler and run bundle install
gem install bundler
bundle install

echo " "
