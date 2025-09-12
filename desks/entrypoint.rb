#!/usr/bin/env ruby

# ENTRYPOINT script for magentic-desktop container
# This script handles container initialization and user creation

# Function to show usage
def show_usage
  puts "Usage: docker run [OPTIONS] magentic-desktop [COMMAND]"
  puts ""
end

def main
  puts "scripts/entrypoint.rb - Starting magentic-desktop container initialization..."

  #require_relative("../image/scripts/pipx_bootstrap")
  # pipx_bootstrap

  require_relative("../image/scripts/pipx_config")
  pipx_config

  # Start Docker service
  puts "Starting Docker service..."
  unless system("service docker start")
    puts "Docker service already running or failed to start"
  end
  
  # Create system-wide desktop shortcuts and autostart entries
  system("setup-desktop-shortcuts.sh --system")

  puts " "

  puts "Adding users..."
  system("bash /usr/local/bin/add_users")

  puts " "
  # Check and start XRDP service
  puts "Checking XRDP service status..."
   
  if system("service xrdp status >/dev/null 2>&1")
    puts "XRDP service is already running."
  else
    puts "XRDP service is not running. Starting XRDP service..."
    system("service xrdp start")
    puts "XRDP service started successfully."
  end

  puts " "
  puts "Container initialization completed!"
  puts "XRDP is running on port 3389"
  puts "VS Code will be available on port #{ENV['VSCODE_PORT']}"
  puts " "

  # If a command was provided, execute it
  if ARGV.length > 0
    puts "Executing command: #{ARGV.join(' ')}"
    exec(*ARGV)
  else
    # Default: keep container running with bash
    puts "Starting interactive shell..."
    exec("/bin/bash")
  end
end

main
