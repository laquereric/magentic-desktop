#!/usr/bin/env ruby

require "lubuntu_gui"
require 'pp'

if __FILE__ == $0
    file = __FILE__
    parent = file.split("/")[0..-2].join("/")
    catalog = LubuntuGui::Catalog.new(source_file: parent)
    instance = catalog.instance
    PP.pp(instance.catalog.parts)
    catalog.get_item(entry_path: "collector/instance/")
    #p "example: #{instance.children.first}"
    #p "count: #{instance.children.count}"
end
