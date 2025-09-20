#!/usr/bin/env ruby

def users
  puts "scripts/entrypoint.rb - next - Users"
  #puts "Adding users..."
  require 'lubuntu_gui'
  # ENTRYPOINT script for magentic-desktop container
  # This script handles container initialization and user creation
  
  users = Dir.glob("scripts/instance/users/*.ini").map do |user_ini_file|
    user = LubuntuGui::Nouns::System::User.new(ini_file: user_ini_file)
    user.prepare
    user
  end
end

users
