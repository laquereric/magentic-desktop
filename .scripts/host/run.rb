#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'open3'

class HostRun
  def initialize
    @options = {}
    parse_options
  end

  def run
    case ARGV.first
    when 'start'
      start_container
    when 'stop'
      stop_container
    when 'restart'
      restart_container
    when 'status'
      show_status
    when 'context'
      show_context
    else
      show_usage
    end
  end

  private

  def parse_options
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [COMMAND] [OPTIONS]"
      
      opts.on("-h", "--help", "Show this help message") do
        show_usage
        exit
      end
    end.parse!
  end

  def show_usage
    puts <<~USAGE
      Usage: #{$0} [COMMAND] [OPTIONS]
      
      Commands:
        start     - Start the magentic-desktop container on remote server
        stop      - Stop the magentic-desktop container on remote server
        restart   - Restart the magentic-desktop container on remote server
        status    - Show the status of the magentic-desktop container
        context   - Show host system information (IP, RAM, disk)
      
      Options:
        -h, --help     Show this help message
      
      Examples:
        #{$0} start
        #{$0} stop
        #{$0} restart
        #{$0} status
        #{$0} context
    USAGE
  end

  def start_container
    puts "Starting magentic-desktop container on remote server..."
    
    # Check if container already exists and is running
    result = execute_remote_command("sudo docker ps --filter name=magentic-desktop --format '{{.Names}}'")
    
    if result.strip == "magentic-desktop"
      puts "Container is already running!"
      return
    end
    
    # Check if container exists but is stopped
    result = execute_remote_command("sudo docker ps -a --filter name=magentic-desktop --format '{{.Names}}'")
    
    if result.strip == "magentic-desktop"
      puts "Starting existing container..."
      execute_remote_command("sudo docker start magentic-desktop")
    else
      puts "Creating and starting new container..."
      execute_remote_command("sudo docker run -d --name magentic-desktop -p 3389:3389 -p 8080:8080 --privileged ghcr.io/laquereric/magentic-desktop:latest")
    end
    
    # Wait a moment for container to start
    sleep 3
    
    # Verify container is running
    result = execute_remote_command("sudo docker ps --filter name=magentic-desktop --format '{{.Names}}'")
    if result.strip == "magentic-desktop"
      puts "✓ Container successfully started!"
      puts "RDP available at: 204.12.169.67:3389"
    else
      puts "❌ Failed to start container!"
      exit 1
    end
  end

  def stop_container
    puts "Stopping magentic-desktop container on remote server..."
    
    # Check if container is running
    result = execute_remote_command("sudo docker ps --filter name=magentic-desktop --format '{{.Names}}'")
    
    if result.strip == "magentic-desktop"
      execute_remote_command("sudo docker stop magentic-desktop")
      puts "✓ Container successfully stopped!"
    else
      puts "Container is not running."
    end
  end

  def restart_container
    puts "Restarting magentic-desktop container on remote server..."
    
    # Stop container if running
    result = execute_remote_command("sudo docker ps --filter name=magentic-desktop --format '{{.Names}}'")
    if result.strip == "magentic-desktop"
      puts "Stopping existing container..."
      execute_remote_command("sudo docker stop magentic-desktop")
    end
    
    # Remove container if it exists
    result = execute_remote_command("sudo docker ps -a --filter name=magentic-desktop --format '{{.Names}}'")
    if result.strip == "magentic-desktop"
      puts "Removing existing container..."
      execute_remote_command("sudo docker rm magentic-desktop")
    end
    
    # Start new container
    puts "Starting new container..."
    execute_remote_command("sudo docker run -d --name magentic-desktop -p 3389:3389 -p 8080:8080 --privileged ghcr.io/laquereric/magentic-desktop:latest")
    
    # Wait a moment for container to start
    sleep 3
    
    # Verify container is running
    result = execute_remote_command("sudo docker ps --filter name=magentic-desktop --format '{{.Names}}'")
    if result.strip == "magentic-desktop"
      puts "✓ Container successfully restarted!"
      puts "RDP available at: 204.12.169.67:3389"
    else
      puts "❌ Failed to restart container!"
      exit 1
    end
  end

  def show_status
    puts "Checking magentic-desktop container status on remote server..."
    puts "=" * 60
    
    # Get container status
    result = execute_remote_command("sudo docker ps -a --filter name=magentic-desktop --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Image}}'")
    
    if result.strip.empty?
      puts "❌ No magentic-desktop container found on remote server"
      return
    end
    
    puts "📦 Container Status:"
    puts result
    
    # Check if container is running
    running_result = execute_remote_command("sudo docker ps --filter name=magentic-desktop --format '{{.Names}}'")
    
    if running_result.strip == "magentic-desktop"
      puts "\n✅ Container is RUNNING"
      puts "🌐 RDP available at: 204.12.169.67:3389"
      puts "🌐 VS Code available at: 204.12.169.67:8080"
      
      # Check if RDP port is accessible
      puts "\n🔍 Checking RDP port accessibility..."
      port_check = execute_remote_command("sudo netstat -tlnp | grep :3389")
      if port_check.include?("3389")
        puts "✅ RDP port 3389 is listening"
      else
        puts "❌ RDP port 3389 is not listening"
      end
    else
      puts "\n❌ Container is NOT RUNNING"
      puts "💡 Use 'start' command to start the container"
    end
    
    # Show container logs (last 10 lines)
    puts "\n📋 Recent container logs (last 10 lines):"
    logs_result = execute_remote_command("sudo docker logs --tail 10 magentic-desktop 2>&1")
    if logs_result.strip.empty?
      puts "No logs available"
    else
      puts logs_result
    end
  end

  def show_context
    puts "Gathering host system information..."
    puts "=" * 60
    
    # Get hostname and IP address
    puts "🌐 Network Information:"
    hostname = execute_remote_command("hostname").strip
    puts "  Hostname: #{hostname}"
    
    # Get external IP
    external_ip = execute_remote_command("curl -s ifconfig.me 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null || echo 'Unable to determine'").strip
    puts "  External IP: #{external_ip}"
    
    # Get internal IP
    internal_ip = execute_remote_command("hostname -I | awk '{print $1}'").strip
    puts "  Internal IP: #{internal_ip}"
    
    # Get system information
    puts "\n💻 System Information:"
    os_info = execute_remote_command("lsb_release -d 2>/dev/null | cut -f2 || uname -a").strip
    puts "  OS: #{os_info}"
    
    kernel = execute_remote_command("uname -r").strip
    puts "  Kernel: #{kernel}"
    
    # Get CPU information
    cpu_info = execute_remote_command("lscpu | grep 'Model name' | cut -d: -f2 | xargs").strip
    cpu_cores = execute_remote_command("nproc").strip
    puts "  CPU: #{cpu_info} (#{cpu_cores} cores)"
    
    # Get memory information
    puts "\n🧠 Memory Information:"
    memory_info = execute_remote_command("free -h | grep '^Mem:' | awk '{print $2}'").strip
    memory_used = execute_remote_command("free -h | grep '^Mem:' | awk '{print $3}'").strip
    memory_available = execute_remote_command("free -h | grep '^Mem:' | awk '{print $7}'").strip
    puts "  Total RAM: #{memory_info}"
    puts "  Used RAM: #{memory_used}"
    puts "  Available RAM: #{memory_available}"
    
    # Get disk information
    puts "\n💾 Disk Information:"
    disk_info = execute_remote_command("df -h / | tail -1 | awk '{print $2}'").strip
    disk_used = execute_remote_command("df -h / | tail -1 | awk '{print $3}'").strip
    disk_available = execute_remote_command("df -h / | tail -1 | awk '{print $4}'").strip
    disk_percent = execute_remote_command("df -h / | tail -1 | awk '{print $5}'").strip
    puts "  Total Disk: #{disk_info}"
    puts "  Used Disk: #{disk_used}"
    puts "  Available Disk: #{disk_available}"
    puts "  Usage: #{disk_percent}"
    
    # Get load average
    puts "\n⚡ System Load:"
    load_avg = execute_remote_command("uptime | awk -F'load average:' '{print $2}'").strip
    puts "  Load Average:#{load_avg}"
    
    uptime = execute_remote_command("uptime -p").strip
    puts "  Uptime: #{uptime}"
    
    # Get Docker information
    puts "\n🐳 Docker Information:"
    docker_version = execute_remote_command("docker --version 2>/dev/null || echo 'Docker not available'").strip
    puts "  Docker: #{docker_version}"
    
    container_count = execute_remote_command("sudo docker ps -q | wc -l").strip
    puts "  Running Containers: #{container_count}"
    
    # Get network ports
    puts "\n🔌 Network Ports:"
    listening_ports = execute_remote_command("sudo netstat -tlnp | grep LISTEN | wc -l").strip
    puts "  Listening Ports: #{listening_ports}"
    
    # Show specific important ports
    rdp_port = execute_remote_command("sudo netstat -tlnp | grep :3389 | wc -l").strip
    ssh_port = execute_remote_command("sudo netstat -tlnp | grep :22 | wc -l").strip
    puts "  RDP Port (3389): #{rdp_port == '1' ? 'Open' : 'Closed'}"
    puts "  SSH Port (22): #{ssh_port == '1' ? 'Open' : 'Closed'}"
    
    puts "\n" + "=" * 60
    puts "✅ Host context information gathered successfully!"
  end

  def execute_remote_command(command)
    # Check if we're running on the remote server (no SSH key needed)
    if File.exist?('/proc/version') && `hostname`.strip != 'Erics-MacBook-Air'
      # We're on the remote server, execute command directly
      result = `#{command}`
      
      unless $?.success?
        puts "Error executing command: #{command}"
        puts "Exit code: #{$?.exitstatus}"
        exit 1
      end
      
      result
    else
      # We're on local machine, use SSH to execute on remote server
      ssh_key = File.expand_path('.secrets/eric.laquer/id_ed25519', File.dirname(__FILE__) + '/../..')
      
      unless File.exist?(ssh_key)
        puts "Error: SSH key not found at #{ssh_key}"
        exit 1
      end
      
      # Set proper permissions on SSH key
      File.chmod(0600, ssh_key)
      
      # Execute command on remote server
      ssh_command = [
        'ssh',
        '-i', ssh_key,
        '-l', 'eric_laquer',
        '-o', 'StrictHostKeyChecking=no',
        '-o', 'UserKnownHostsFile=/dev/null',
        '204.12.169.67',
        command
      ]
      
      result = `#{ssh_command.join(' ')}`
      
      unless $?.success?
        puts "Error executing remote command: #{command}"
        puts "Exit code: #{$?.exitstatus}"
        exit 1
      end
      
      result
    end
  rescue => e
    puts "Error: #{e.message}"
    exit 1
  end
end

# Run the application
HostRun.new.run if __FILE__ == $0