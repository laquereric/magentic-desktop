#!/usr/bin/env ruby

def xdisplay
  puts "scripts/entrypoint.rb - last - Starting magentic-desktop container initialization..."

  # Check and start XRDP service
  puts "Checking XRDP service status..."
   
  if system("service xrdp status >/dev/null 2>&1")
    puts "XRDP service is already running."
  else
    puts "XRDP service is not running. Starting XRDP se]rvice..."
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

xdisplay
