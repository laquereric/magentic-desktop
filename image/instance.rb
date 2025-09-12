#!/usr/bin/env ruby

require "lubuntu_gui"

if __FILE__ == $0
    directory = File.expand_path('..',__FILE__)
    instance = LubuntuGui::Instance.new(directory:directory)
    p instance.children
end