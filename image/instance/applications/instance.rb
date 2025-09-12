#!/usr/bin/env ruby

require "lubuntu_gui"

if __FILE__ == $0
    instance = LubuntuGui::Instance.new
    p instance.children
end