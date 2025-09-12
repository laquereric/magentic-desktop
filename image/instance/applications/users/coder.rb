
username = "coder"
password = "coder123"
home_directory = "/home/#{user.username}"
shell_path = "/usr/bin/zsh"
desktop_entry = <<~DESKTOP
[Desktop Entry]
    Version=1.0
    Type=User
    Name=User
    Comment=User
    Exec=jupyter lab
    Icon=User
    Terminal=false
    StartupNotify=true
    Categories=Development;Education;
DESKTOP
