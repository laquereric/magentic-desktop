#!/usr/bin/env ruby

def bundler
  puts "scripts/entrypoint.rb first - Starting magentic-desktop container initialization..."

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

bundler
