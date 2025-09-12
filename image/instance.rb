#!/usr/bin/env ruby

require "lubuntu_gui"

if __FILE__ == $0
    instance = LubuntuGui::Instance.new(name: 'top.instance', source_file: __FILE__, directory: File.expand_path('..',__FILE__))
    p instance.children
end