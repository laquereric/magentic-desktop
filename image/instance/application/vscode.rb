require "lubuntu_gui"

LubuntuGui::Application.new(name:"VsCode",file:__FILE__).tap do |a|
    a.desktop_entry = <<~DESKTOP
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=VsCode
      Comment=VsCode Editor
      Exec=vscode
      Icon=vscode
      Terminal=false
      StartupNotify=true
      Categories=Development;TextEditor;
    DESKTOP
end