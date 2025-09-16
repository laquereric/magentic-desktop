#!/usr/bin/env ruby

require "lubuntu_gui"
require 'pp'

if __FILE__ == $0
    PP.pp(
        LubuntuGui::Catalog.new(source_file: File.expand_path(__FILE__)).instance
    )
    #p "example: #{instance.children.first}"
    #p "count: #{instance.children.count}"
end
