require "lubuntu_gui"

LubuntuGui::Application.new(name:"Firefox",file:__FILE__).tap do |a|
    a.desktop_entry = <<~DESKTOP
[Desktop Entry]
  Version=1.0
  Type=Application
  Name=Firefox
  Comment=Web Browser
  Exec=firefox
  Icon=firefox
  Terminal=false
  StartupNotify=true
  Categories=Network;WebBrowser;
DESKTOP
end