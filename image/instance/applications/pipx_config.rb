#!/usr/bin/env ruby

# pipx_config.rb - Configure pipx and run Python scripts

def pipx_config
  system("pipx ensurepath")

  # Run all Python scripts in the python directory
  python_scripts_dir = "/image/scripts/python/*"
  
  Dir.glob(python_scripts_dir).each do |script|
    if File.file?(script) && File.executable?(script)
      puts "Running #{script}..."
      system("bash #{script}")
    end
  end
end

# Run the function if this script is executed directly
if __FILE__ == $0
  pipx_config
end
