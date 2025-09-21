#!/bin/bash 
# ENTRYPOINT script for magentic-desktop container
# This script handles container initialization and user creation

echo "Container initialization started!"
echo " "

/.scripts/00_docker.sh
/.scripts/0_bundler.rb
bundle exec /.scripts/1_users.rb
bundle exec /.scripts/2_xdisplay.rb

echo " "
echo "Container initialization completed!"
echo "XRDP is running on port 3389"
echo " "