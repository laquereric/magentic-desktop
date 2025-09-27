#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'open3'

class Nebius
  # Configuration constants
  REMOTE_HOST = '204.12.169.67'
  REMOTE_USER = 'eric_laquer'
  SSH_KEY_NAME = 'id_ed25519'
  HOST_SCRIPT_PATH = '../../.scripts/host/run.rb'

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
    when 'profile_create'
      profile_create
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
        root_shell      - Open SSH shell to remote server using admin user credentials from .secrets/users/[admin_user]
        upload_run      - Upload and run the host run script on remote server
        profile_create  - Create Nebius profile using environment from .secrets/services/nebius/set_env.sh
      
      Options:
        -h, --help     Show this help message
      
      Examples:
        #{$0} root_shell
        #{$0} upload_run
        #{$0} profile_create
    USAGE
  end

  def root_shell
    puts "Opening SSH shell to remote server..."
    
    with_secrets_directory do
      setup_ssh_key
      execute_ssh_command
    end
  rescue => e
    handle_error(e)
  end

  def upload_run
    puts "Uploading and running host run script on remote server..."
    
    with_secrets_directory do
      setup_ssh_key
      upload_host_script
      ensure_ruby_installed
      make_script_executable
    end
  rescue => e
    handle_error(e)
  end

  def profile_create
    puts "Creating Nebius profile..."
    
    load_nebius_environment
    validate_environment_variables
    execute_nebius_profile_create
  rescue => e
    handle_error(e)
  end

  # Helper methods

  def with_secrets_directory
    project_root = File.expand_path('../..', __dir__)
    admin_user = get_admin_user(project_root)
    secrets_dir = File.expand_path(".secrets/users/#{admin_user}", project_root)
    
    unless Dir.exist?(secrets_dir)
      puts "Error: .secrets/users/#{admin_user} directory not found!"
      puts "Expected directory: #{secrets_dir}"
      exit 1
    end
    
    Dir.chdir(secrets_dir) do
      puts "Changed to directory: #{Dir.pwd}"
      yield
    end
  end

  def get_admin_user(project_root)
    admin_roles_dir = File.expand_path('.secrets/roles/admin', project_root)
    
    unless Dir.exist?(admin_roles_dir)
      puts "Error: .secrets/roles/admin directory not found!"
      puts "Expected directory: #{admin_roles_dir}"
      exit 1
    end
    
    # Find the first admin user file
    admin_files = Dir.glob(File.join(admin_roles_dir, '*')).select { |f| File.file?(f) }
    
    if admin_files.empty?
      puts "Error: No admin user files found in #{admin_roles_dir}"
      puts "Please create an admin user file (e.g., .secrets/roles/admin/username)"
      exit 1
    end
    
    # Get the username from the filename
    admin_user = File.basename(admin_files.first)
    puts "Using admin user: #{admin_user}"
    admin_user
  end

  def load_nebius_environment
    project_root = File.expand_path('../..', __dir__)
    env_file = File.expand_path('.secrets/services/nebius/set_env.sh', project_root)
    
    unless File.exist?(env_file)
      puts "Error: Nebius environment file not found at #{env_file}"
      exit 1
    end
    
    puts "Loading Nebius environment from #{env_file}"
    
    # Read and parse the environment file
    File.readlines(env_file).each do |line|
      line = line.strip
      next if line.empty? || line.start_with?('#')
      
      if line.start_with?('export ')
        # Parse export statements like "export VAR=value"
        match = line.match(/^export\s+(\w+)=(.*)$/)
        if match
          var_name = match[1]
          var_value = match[2]
          ENV[var_name] = var_value
          puts "  Set #{var_name}=#{var_value}"
        end
      end
    end
    
    puts "✓ Nebius environment loaded successfully!"
  end

  def setup_ssh_key
    ssh_key = File.join(Dir.pwd, SSH_KEY_NAME)
    unless File.exist?(ssh_key)
      puts "Error: SSH private key not found at #{ssh_key}"
      exit 1
    end
    
    File.chmod(0600, ssh_key)
    puts "Set SSH key permissions to 600"
  end

  def execute_ssh_command
    ssh_command = [
      'ssh',
      '-i', SSH_KEY_NAME,
      '-l', REMOTE_USER,
      '-v',
      REMOTE_HOST
    ]
    
    puts "Executing SSH command: #{ssh_command.join(' ')}"
    exec(*ssh_command)
  end

  def upload_host_script
    puts "Uploading host run script..."
    scp_command = [
      'scp',
      '-i', SSH_KEY_NAME,
      '-o', 'StrictHostKeyChecking=no',
      '-o', 'UserKnownHostsFile=/dev/null',
      HOST_SCRIPT_PATH,
      "#{REMOTE_USER}@#{REMOTE_HOST}:~/run.rb"
    ]
    
    puts "Executing SCP command: #{scp_command.join(' ')}"
    
    unless system(*scp_command)
      puts "Error: Failed to upload run script"
      exit 1
    end
    
    puts "✓ Host run script uploaded successfully!"
  end

  def ensure_ruby_installed
    puts "Checking and installing Ruby on remote server..."
    
    ruby_check_command = build_ssh_command('ruby --version')
    ruby_check_result = `#{ruby_check_command.join(' ')} 2>&1`
    
    unless $?.success?
      install_ruby
    else
      puts "✓ Ruby is already installed: #{ruby_check_result.strip}"
    end
  end

  def install_ruby
    puts "Ruby not found, installing Ruby..."
    install_ruby_command = build_ssh_command('sudo apt update && sudo apt install -y ruby-full')
    
    puts "Executing Ruby installation: #{install_ruby_command.join(' ')}"
    
    unless system(*install_ruby_command)
      puts "Error: Failed to install Ruby"
      exit 1
    end
    
    puts "✓ Ruby installed successfully!"
  end

  def make_script_executable
    puts "Making script executable on remote server..."
    ssh_command = build_ssh_command('chmod +x ~/run.rb', verbose: true)
    
    puts "Executing SSH command: #{ssh_command.join(' ')}"
    
    unless system(*ssh_command)
      puts "Error: Failed to make script executable"
      exit 1
    end
    
    puts "✓ Script is now executable on remote server!"
    puts "You can now run: ssh -i #{SSH_KEY_NAME} -l #{REMOTE_USER} #{REMOTE_HOST} '~/run.rb start'"
  end

  def build_ssh_command(remote_command, verbose: false)
    command = [
      'ssh',
      '-i', SSH_KEY_NAME,
      '-l', REMOTE_USER,
      '-o', 'StrictHostKeyChecking=no',
      '-o', 'UserKnownHostsFile=/dev/null'
    ]
    
    command << '-v' if verbose
    command << REMOTE_HOST
    command << remote_command
    
    command
  end

  def validate_environment_variables
    required_vars = %w[NB_PROFILE_NAME NB_PROJECT_ID]
    missing_vars = required_vars.select { |var| ENV[var].nil? || ENV[var].empty? }
    
    unless missing_vars.empty?
      puts "Error: Missing required environment variables: #{missing_vars.join(', ')}"
      puts "Please set the following environment variables:"
      required_vars.each { |var| puts "  export #{var}=<value>" }
      exit 1
    end
  end

  def execute_nebius_profile_create
    nebius_command = [
      'nebius', 'profile', 'create',
      '--profile', ENV['NB_PROFILE_NAME'],
      '--endpoint', 'api.nebius.cloud',
      '--federation-endpoint', 'auth.nebius.com',
      '--parent-id', ENV['NB_PROJECT_ID']
    ]
    
    puts "Executing command: #{nebius_command.join(' ')}"
    
    unless system(*nebius_command)
      puts "Error: Failed to create Nebius profile"
      exit 1
    end
    
    puts "✓ Nebius profile created successfully!"
  end

  def handle_error(error)
    puts "Error: #{error.message}"
    exit 1
  end
end

# Run the application
Nebius.new.run if __FILE__ == $0