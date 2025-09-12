#!/env ruby
`pipx ensurepath`

Dir.glob("/image/scripts/python/*").each do |script|
    if File.file?(script) && File.executable?(script)
        `pipx install #{script} --include-deps`
        puts "Running #{script}..."
        `bash "#{script}"`  
    end
end
# Run all Python scripts in the python directory