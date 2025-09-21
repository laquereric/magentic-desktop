#!/usr/bin/env ruby

def bundle
  puts "/scripts/bundle.rb"

  puts "Installing bundler and running bundle install..."
  system("gem install bundler && bundle install && bundle exec ruby /scripts/users.rb")

  puts "Bundle setup completed"
end

if __FILE__ == $0
  bundle
end
