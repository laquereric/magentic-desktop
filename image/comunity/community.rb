#!/usr/bin/env ruby

require "lubuntu_gui"

class Community < LubuntuGui::CollectorBase
    attr_accessor :palette
    def initialize
        @palette = Palette.new
    end
end

if __FILE__ == $0
    instance = LubuntuGui::Instance.new
    p instance.palette.applications
end