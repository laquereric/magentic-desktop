#!/usr/bin/env ruby

require_relative "../../collector_base"

if __FILE__ == $0
    instance = LubuntuGui::Instance.new
    p instance
    p instance.children
end