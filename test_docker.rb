#!/usr/bin/env ruby

# Test script to verify Docker installation in the container

require 'open3'

def test_docker_installation
  puts "Testing Docker installation..."
  
  # Test Docker version
  puts "\n1. Testing Docker version:"
  stdout, stderr, status = Open3.capture3("docker --version")
  if status.success?
    puts "✓ Docker installed: #{stdout.chomp}"
  else
    puts "✗ Docker not found: #{stderr}"
    return false
  end
  
  # Test Docker Compose version
  puts "\n2. Testing Docker Compose version:"
  stdout, stderr, status = Open3.capture3("docker compose version")
  if status.success?
    puts "✓ Docker Compose installed: #{stdout.chomp}"
  else
    puts "✗ Docker Compose not found: #{stderr}"
  end
  
  # Test Docker service status
  puts "\n3. Testing Docker service status:"
  stdout, stderr, status = Open3.capture3("service docker status")
  if status.success?
    puts "✓ Docker service status: #{stdout.chomp}"
  else
    puts "✗ Docker service check failed: #{stderr}"
  end
  
  # Test Docker info
  puts "\n4. Testing Docker info:"
  stdout, stderr, status = Open3.capture3("docker info")
  if status.success?
    puts "✓ Docker daemon accessible"
    puts "  Server Version: #{stdout.lines.grep(/Server Version/).first&.chomp}"
  else
    puts "✗ Docker daemon not accessible: #{stderr}"
    puts "  This is normal if Docker daemon is not running"
  end
  
  puts "\nDocker installation test completed!"
  true
end

# Run the test
test_docker_installation
