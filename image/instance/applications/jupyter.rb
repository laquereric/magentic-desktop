require "lubuntu_gui"

LubuntuGui::Application.new(name:"Jupyter",file:__FILE__).tap do |a|
  a.desktop_entry = <<~DESKTOP
[Desktop Entry]
    Version=1.0
    Type=Application
    Name=Jupyter
    Comment=Jupyter Notebook
    Exec=jupyter notebook
    Icon=jupyter
    Terminal=false
    StartupNotify=true
    Categories=Development;Education;
DESKTOP
end