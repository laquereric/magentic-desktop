#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'open3'

class Nebius
  def initialize
    @options = {}
    parse_options
  end

  def run
    case ARGV.first
    when 'root_shell'
      root_shell
    when 'upload_run'
      upload_run
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
        root_shell    - Open SSH shell to remote server using credentials from .secrets/eric.laquer
        upload_run    - Upload and run the host run script on remote server
      
      Options:
        -h, --help     Show this help message
      
      Examples:
        #{$0} root_shell
    USAGE
  end

  def root_shell
    puts "Opening SSH shell to remote server..."
    
    # Change to .secrets/eric.laquer directory (relative to project root)
    project_root = File.expand_path('../..', __dir__)
    secrets_dir = File.expand_path(".secrets/#{`whoami`.strip}", project_root)
    
    unless Dir.exist?(secrets_dir)
      puts "Error: .secrets/eric.laquer directory not found!"
      puts "Expected directory: #{secrets_dir}"
      exit 1
    end
    
    # Change to the secrets directory
    Dir.chdir(secrets_dir) do
      puts "Changed to directory: #{Dir.pwd}"
      
      # Check if SSH key exists
      ssh_key = File.join(Dir.pwd, 'id_ed25519')
      unless File.exist?(ssh_key)
        puts "Error: SSH private key not found at #{ssh_key}"
        exit 1
      end
      
      # Set proper permissions on SSH key
      File.chmod(0600, ssh_key)
      puts "Set SSH key permissions to 600"
      
      # Run SSH command with the private key
      ssh_command = [
        'ssh',
        '-i', 'id_ed25519',
        '-l', 'eric_laquer',
        '-v',
        '204.12.169.67'
      ]
      
      puts "Executing SSH command: #{ssh_command.join(' ')}"
      
      # Execute the SSH command
      exec(*ssh_command)
    end
  rescue Errno::ENOENT => e
    puts "Error: #{e.message}"
    exit 1
  rescue => e
    puts "Error: #{e.message}"
    exit 1
  end

  def upload_run
    puts "Uploading and running host run script on remote server..."
    
    # Change to .secrets/eric.laquer directory (relative to project root)
    project_root = File.expand_path('../..', __dir__)
    secrets_dir = File.expand_path(".secrets/#{`whoami`.strip}", project_root)
    
    unless Dir.exist?(secrets_dir)
      puts "Error: .secrets/eric.laquer directory not found!"
      puts "Expected directory: #{secrets_dir}"
      exit 1
    end
    
    # Change to the secrets directory
    Dir.chdir(secrets_dir) do
      puts "Changed to directory: #{Dir.pwd}"
      
      # Check if SSH key exists
      ssh_key = File.join(Dir.pwd, 'id_ed25519')
      unless File.exist?(ssh_key)
        puts "Error: SSH private key not found at #{ssh_key}"
        exit 1
      end
      
      # Set proper permissions on SSH key
      File.chmod(0600, ssh_key)
      puts "Set SSH key permissions to 600"
      
      # Upload the host run script
      puts "Uploading host run script..."
      scp_command = [
        'scp',
        '-i', 'id_ed25519',
        '-o', 'StrictHostKeyChecking=no',
        '-o', 'UserKnownHostsFile=/dev/null',
        '../../.scripts/host/run.rb',
        'eric_laquer@204.12.169.67:~/run.rb'
      ]
      
      puts "Executing SCP command: #{scp_command.join(' ')}"
      
      unless system(*scp_command)
        puts "Error: Failed to upload run script"
        exit 1
      end
      
      puts "✓ Host run script uploaded successfully!"
      
      # Install Ruby on remote server if not present
      puts "Checking and installing Ruby on remote server..."
      ruby_check_command = [
        'ssh',
        '-i', 'id_ed25519',
        '-l', 'eric_laquer',
        '-o', 'StrictHostKeyChecking=no',
        '-o', 'UserKnownHostsFile=/dev/null',
        '204.12.169.67',
        'ruby --version'
      ]
      
      ruby_check_result = `#{ruby_check_command.join(' ')} 2>&1`
      
      unless $?.success?
        puts "Ruby not found, installing Ruby..."
        install_ruby_command = [
          'ssh',
          '-i', 'id_ed25519',
          '-l', 'eric_laquer',
          '-o', 'StrictHostKeyChecking=no',
          '-o', 'UserKnownHostsFile=/dev/null',
          '204.12.169.67',
          'sudo apt update && sudo apt install -y ruby-full'
        ]
        
        puts "Executing Ruby installation: #{install_ruby_command.join(' ')}"
        
        unless system(*install_ruby_command)
          puts "Error: Failed to install Ruby"
          exit 1
        end
        
        puts "✓ Ruby installed successfully!"
      else
        puts "✓ Ruby is already installed: #{ruby_check_result.strip}"
      end
      
      # Make the script executable on remote server
      puts "Making script executable on remote server..."
      ssh_command = [
        'ssh',
        '-i', 'id_ed25519',
        '-l', 'eric_laquer',
        '-v',
        '204.12.169.67',
        'chmod +x ~/run.rb'
      ]
      
      puts "Executing SSH command: #{ssh_command.join(' ')}"
      
      unless system(*ssh_command)
        puts "Error: Failed to make script executable"
        exit 1
      end
      
      puts "✓ Script is now executable on remote server!"
      puts "You can now run: ssh -i id_ed25519 -l eric_laquer 204.12.169.67 '~/run.rb start'"
    end
  rescue Errno::ENOENT => e
    puts "Error: #{e.message}"
    exit 1
  rescue => e
    puts "Error: #{e.message}"
    exit 1
  end
end

# Run the application
Nebius.new.run if __FILE__ == $0
