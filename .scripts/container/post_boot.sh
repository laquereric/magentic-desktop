#!/bin/bash

echo "scripts/post_boot.sh"
service xrdp status
systemctl enable docker

/scripts/docker.sh
/scripts/bundle.rb

bundle exec /scripts/users.rb
bundle exec /scripts/xdisplay.rb
