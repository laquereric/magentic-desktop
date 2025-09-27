#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'open3'

class NebiusRunner
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
    when 'start_compute'
      start_compute
    when 'stop_compute'
      stop_compute
    when 'compute_status'
      compute_status
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
        start_compute   - Start Nebius compute instance using nebius gem
        stop_compute    - Stop Nebius compute instance using nebius gem
        compute_status  - Show status of all Nebius compute instances using nebius gem
      
      Options:
        -h, --help     Show this help message
      
      Examples:
        #{$0} root_shell
        #{$0} upload_run
        #{$0} profile_create
        #{$0} start_compute
        #{$0} stop_compute
        #{$0} compute_status
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

  def start_compute
    puts "Starting Nebius compute instance..."
    
    load_nebius_environment
    validate_environment_variables
    execute_start_compute
  rescue => e
    handle_error(e)
  end

  def stop_compute
    puts "Stopping Nebius compute instance..."
    
    load_nebius_environment
    validate_environment_variables
    execute_stop_compute
  rescue => e
    handle_error(e)
  end

  def compute_status
    puts "Checking Nebius compute instances status..."
    
    load_nebius_environment
    validate_environment_variables
    execute_compute_status
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
    exec('bundle', 'exec', *ssh_command)
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
    
      unless system('bundle', 'exec', *scp_command)
        puts "Error: Failed to upload run script"
        exit 1
      end
    
    puts "✓ Host run script uploaded successfully!"
  end

  def ensure_ruby_installed
    puts "Checking and installing Ruby on remote server..."
    
    ruby_check_command = build_ssh_command('ruby --version')
    ruby_check_result = `bundle exec #{ruby_check_command.join(' ')} 2>&1`
    
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
    
        unless system('bundle', 'exec', *install_ruby_command)
          puts "Error: Failed to install Ruby"
          exit 1
        end
    
    puts "✓ Ruby installed successfully!"
  end

  def make_script_executable
    puts "Making script executable on remote server..."
    ssh_command = build_ssh_command('chmod +x ~/run.rb', verbose: true)
    
    puts "Executing SSH command: #{ssh_command.join(' ')}"
    
      unless system('bundle', 'exec', *ssh_command)
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
    
    unless system('bundle', 'exec', *nebius_command)
      puts "Error: Failed to create Nebius profile"
      exit 1
    end
    
    puts "✓ Nebius profile created successfully!"
  end

  def execute_start_compute
    puts "Using Nebius CLI to start compute instance..."
    
    # Build the nebius compute instance create command
    nebius_command = [
      'nebius', 'compute', 'instance', 'create',
      '--profile', ENV['NB_PROFILE_NAME'],
      '--name', "magentic-desktop-#{Time.now.to_i}",
      '--zone-id', 'ru-central1-a',
      '--cores', '2',
      '--memory', '4',
      '--image-family', 'ubuntu-2004-lts',
      '--ssh-key', '~/.ssh/id_rsa.pub'
    ]
    
    puts "Executing command: #{nebius_command.join(' ')}"
    
    unless system('bundle', 'exec', *nebius_command)
      puts "Error: Failed to start compute instance"
      exit 1
    end
    
    puts "✓ Compute instance started successfully!"
  end

  def execute_stop_compute
    puts "Using Nebius CLI to stop compute instance..."
    
    # First get the list of instances to find one to stop
    instances = compute_instances
    if instances.empty?
      puts "No compute instances found to stop."
      return
    end
    
    # Stop the first running instance
    running_instance = instances.find { |instance| instance[:status] == 'running' }
    if running_instance.nil?
      puts "No running instances found to stop."
      return
    end
    
    # Build the nebius compute instance delete command
    nebius_command = [
      'nebius', 'compute', 'instance', 'delete',
      '--profile', ENV['NB_PROFILE_NAME'],
      '--id', running_instance[:id]
    ]
    
    puts "Executing command: #{nebius_command.join(' ')}"
    
    unless system('bundle', 'exec', *nebius_command)
      puts "Error: Failed to stop compute instance"
      exit 1
    end
    
    puts "✓ Compute instance stopped successfully!"
  end

  def execute_compute_status
    puts "Using Nebius CLI to check compute instances status..."
    
    # Get compute instances status using nebius CLI
    begin
      result = compute_instances
      
      puts "✓ Compute instances status retrieved successfully!"
      puts "\n=== Compute Instances Status ==="
      
      if result && result.any?
        result.each_with_index do |instance, index|
          puts "\nInstance #{index + 1}:"
          puts "  ID: #{instance[:id] || 'N/A'}"
          puts "  Name: #{instance[:name] || 'N/A'}"
          puts "  Status: #{instance[:status] || 'N/A'}"
          puts "  Public IP: #{instance[:public_ip] || 'N/A'}"
          puts "  Resources/Preset: #{instance[:resources] || 'N/A'}"
          puts "  Zone: #{instance[:zone] || 'N/A'}"
          puts "  Created: #{instance[:created_at] || 'N/A'}"
        end
      else
        puts "No compute instances found."
      end
      
    rescue => e
      puts "Error: Failed to get compute instances status: #{e.message}"
      exit 1
    end
  end

  def compute_instances
    # Build the nebius compute instance list command
    nebius_command = [
      'nebius', 'compute', 'instance', 'list',
      '--profile', ENV['NB_PROFILE_NAME'],
      '--format', 'json'
    ]
    
    puts "Executing command: #{nebius_command.join(' ')}"
    
    # Execute the command and capture output
    output = `#{nebius_command.join(' ')} 2>&1`
    
    unless $?.success?
      puts "Error: Failed to execute nebius compute list command"
      puts "Output: #{output}"
      return []
    end
    
    # Parse JSON output
    begin
      require 'json'
      instances_data = JSON.parse(output)
      
      # Handle different JSON response structures
      instances_data_array = []
      
      if instances_data.is_a?(Array)
        instances_data_array = instances_data
      elsif instances_data.is_a?(Hash)
        # Check if the hash contains an array of instances
        if instances_data['instances'] && instances_data['instances'].is_a?(Array)
          instances_data_array = instances_data['instances']
        elsif instances_data['items'] && instances_data['items'].is_a?(Array)
          instances_data_array = instances_data['items']
        else
          # If it's a single instance hash, wrap it in an array
          instances_data_array = [instances_data]
        end
      else
        puts "Warning: Unexpected JSON structure, got #{instances_data.class}"
        return []
      end
      
      # Extract and format instance information
      instances = []
      instances_data_array.each do |instance|
        # Ensure instance is a hash
        unless instance.is_a?(Hash)
          puts "Warning: Expected instance to be a hash, got #{instance.class}"
          next
        end
        
        # Safely extract public IP
        public_ip = 'N/A'
        begin
          if instance['network_interfaces'] && instance['network_interfaces'].is_a?(Array) && !instance['network_interfaces'].empty?
            network_interface = instance['network_interfaces'].first
            if network_interface.is_a?(Hash) && network_interface['primary_v4_address'] && network_interface['primary_v4_address']['one_to_one_nat']
              public_ip = network_interface['primary_v4_address']['one_to_one_nat']['address'] || 'N/A'
            end
          end
        rescue => e
          puts "Warning: Error extracting public IP: #{e.message}"
        end
        
        # Safely extract resources
        resources = 'N/A'
        begin
          if instance['resources'] && instance['resources'].is_a?(Hash)
            if instance['resources']['cores'] && instance['resources']['memory']
              cores = instance['resources']['cores']
              memory = instance['resources']['memory']
              resources = "#{cores} cores, #{memory} GB"
            elsif instance['resources']['preset']
              resources = instance['resources']['preset']
            end
          end
        rescue => e
          puts "Warning: Error extracting resources: #{e.message}"
        end
        
        instances << {
          id: instance['id'] || 'N/A',
          name: instance['name'] || 'N/A',
          status: instance['status'] || 'N/A',
          public_ip: public_ip,
          resources: resources,
          zone: instance['zone_id'] || 'N/A',
          created_at: instance['created_at'] || 'N/A'
        }
      end
      
      instances
    rescue JSON::ParserError => e
      puts "Error: Failed to parse JSON output: #{e.message}"
      puts "Raw output: #{output}"
      []
    rescue => e
      puts "Error: Unexpected error parsing instances: #{e.message}"
      puts "Raw output: #{output}"
      []
    end
  end

  def handle_error(error)
    puts "Error: #{error.message}"
    exit 1
  end
end

# Run the application
NebiusRunner.new.run if __FILE__ == $0