#!/usr/bin/env ruby

require "lubuntu_gui"

if __FILE__ == $0
    source_file = __FILE__
    catalog = LubuntuGui::Catalog.new(source_file: source_file)
    p catalog
    #p "example: #{instance.children.first}"
    #p "count: #{instance.children.count}"
end