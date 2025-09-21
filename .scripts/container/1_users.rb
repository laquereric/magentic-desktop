#!/usr/bin/env ruby

def 1_users
  puts ".scripts/1_users.rb"
  require 'lubuntu_gui'
  
  users = Dir.glob("/.config/users/*.ini").map do |user_ini_file|
    user = LubuntuGui::Nouns::System::User.new(ini_file: user_ini_file)
    user.prepare
    user
  end
end

if __FILE__ == $0
  $0
end

