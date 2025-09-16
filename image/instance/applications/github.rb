require "lubuntu_gui"

LubuntuGui::Application.new(name:"Github",file:__FILE__).tap do |a|
    a.desktop_entry = <<~DESKTOP
[Desktop Entry]
    Version=1.0
    Type=Application
    Name=Github
    Comment=GitHub Desktop
    Exec=github-desktop
    Icon=github-desktop
    Terminal=false
    StartupNotify=true
    Categories=Development;VersionControl;
DESKTOP
end
