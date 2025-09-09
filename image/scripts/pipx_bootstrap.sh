#!/bin/bash
# Bootstrap pipx to the latest version.
pipx install pipx
apt-get remove -y pipx
/usr/local/bin/pipx install pipx --global
pipx uninstall pipx
