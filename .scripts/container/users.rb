#!/usr/bin/env ruby``

def users
  require 'lubuntu_gui'

  users = Dir.glob("/config/users/*.ini").map do |user_ini_file|
    puts "Running #{user_ini_file}..."
    user = LubuntuGui::Nouns::System::User.new(ini_file: user_ini_file)
    user.prepare
    user
  end
end

if __FILE__ == $0
  puts "Running /scripts/users.rb"
  users
end
