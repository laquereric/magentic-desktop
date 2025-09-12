require "lubuntu_gui"

LubuntuGui::Application.new(name:"JupyterLab",file:__FILE__).tap do |a|
  a.desktop_entry = <<~DESKTOP
[Desktop Entry]
    Version=1.0
    Type=Application
    Name=JupyterLab
    Comment=JupyterLab Interactive Development Environment
    Exec=jupyter lab
    Icon=jupyter
    Terminal=false
    StartupNotify=true
    Categories=Development;Education;
DESKTOP
end