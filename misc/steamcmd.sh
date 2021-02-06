#!/bin/bash

INSTALL_TXT="$HOME/s/garrysmod/addons/spaceage/misc/install.txt"
sed "s~__HOME__~$HOME~" "${INSTALL_TXT}.tpl" > "$INSTALL_TXT"
steamcmd +runscript "$HOME/s/garrysmod/addons/spaceage/misc/install.txt"
