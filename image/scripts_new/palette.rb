#!/usr/bin/env ruby

DEBUG = true

class Palette
    attr_accessor :applications
    def initialize
        @applications = get_applications
    end

    private

    def palette_folder
        r = File.expand_path("../palette", __FILE__)
        puts "palette_folder: #{r}" if DEBUG
        r
    end 
    
    def glob_string
        r = "#{palette_folder}/*.rb"
        puts "glob_string: #{r}" if DEBUG
        r
    end

    def glob_palette_folder
        r = Dir.glob(glob_string)
        puts "glob_palette_folder: #{r}" if DEBUG
        r
    end
    
    def eval_application(file)
        {
            file:   file,
            evaled: load(file)
        }
    end

    def add_application(acc, file)
        acc[file] = eval_application(file)[:evaled]
    end
    
    def get_applications
        r = glob_palette_folder.each_with_object({}) do |file, acc|
            add_application(acc, file)
        end
        puts "get_applications: #{r}" if DEBUG
        r
    end

end

if __FILE__ == $0
    Palette.new
end