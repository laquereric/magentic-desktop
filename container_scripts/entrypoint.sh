#!/bin/bash 

/scripts/0_bundler.rb
bundle exec /scripts/1_users.rb
bundle exec /scripts/2_xdisplay.rb