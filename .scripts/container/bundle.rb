#!/usr/bin/env ruby

def bundler
  puts ".scripts/0_bundler.rb"

  # Start Docker service
  puts "Starting Docker service..."
  unless system("service docker start")
    puts "Docker service already running or failed to start"
  end

  puts " "

  #system("bash /usr/local/bin/add_users")
  system("gem install bundler")
  system("bundle install")
  #system("bundle exec ruby /scripts/catalog.rb")

  puts " "
end

if __FILE__ == $0
  $0
end
