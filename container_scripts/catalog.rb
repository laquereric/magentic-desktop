#!/usr/bin/env ruby

require "lubuntu_gui"
require 'pp'

def get_catalog_h(file:'scripts/catalog.rb')
    parent = file.split("/")[0..-2].join("/")
    catalog = LubuntuGui::Catalog.new(source_file: parent)
    {
        catalog: catalog,
        parent: parent,
        instance: catalog.instance
    }
end

def dump_catalog(file:'scripts/catalog.rb')
    catalog_h = get_catalog_h(file:'scripts/catalog.rb')
    PP.pp(catalog_h[:catalog].parts)
end

def catalog_test(file:'scripts/catalog.rb')
    c = dump_catalog(file: file)[:catalog]
    PP.pp(c.get_item(entry_path:'/collector_instance/users'))
end

if __FILE__ == $0
    dump_catalog(file: __FILE__)
end
    # instance = catalog.instance
    # PP.pp(instance.catalog.parts)
    # catalog.get_item(entry_path: "collector/instance/")
    
    # p "example: #{instance.children.first}"
    # p "count: #{instance.children.count}"
