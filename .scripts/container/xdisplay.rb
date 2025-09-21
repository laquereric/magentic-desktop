#!/usr/bin/env ruby

def xdisplay
  puts ".scripts/xdisplay.rb"
   
  if system("service xrdp status >/dev/null 2>&1")
    puts "XRDP service is already running."
  else
    puts "XRDP service is not running. Starting XRDP se]rvice..."
    system("service xrdp start")
    puts "XRDP service started successfully."
  end

  # If a command was provided, execute it
  if ARGV.length > 0
    puts "Executing command: #{ARGV.join(' ')}"
    exec(*ARGV)
  #else
    # Default: keep container running with bash
  #  puts "Starting interactive shell..."
  #  exec("/bin/bash")
  end
end

if __FILE__ == $0
  xdisplay
end
