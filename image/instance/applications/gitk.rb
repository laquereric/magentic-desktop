require "lubuntu_gui"

LubuntuGui::Application.new(name:"GitK",file:__FILE__).tap do |a|
  a.desktop_entry = <<~DESKTOP
[Desktop Entry]
    Version=1.0
    Type=Application
    Name=GitK
    Comment=Git repository history viewer
    Exec=gitk --all
    Icon=git
    Terminal=false
    StartupNotify=true
    Categories=Development;VersionControl;
DESKTOP
end
