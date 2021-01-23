#!/bin/bash
# Main server runscript

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
export LD_LIBRARY_PATH="$HOME/s/bin/linux64"

cd "$HOME/s"

upgrade_addon() {
    pushd "garrysmod/addons/$1"
    git pull
    popd
}

upgrade_addon spaceage
upgrade_addon spacebuild
upgrade_addon sbep
upgrade_addon smartsnap
upgrade_addon wire-extras

INSTALL_TXT="$HOME/s/garrysmod/addons/spaceage/misc/install.txt"
sed "s~__HOME__~$HOME~" "${INSTALL_TXT}.tpl" > "$INSTALL_TXT"
steamcmd +runscript "$HOME/s/garrysmod/addons/spaceage/misc/install.txt"

export WORKSHOP_COLLECTION=177294269
"$HOME/s/garrysmod/addons/spaceage/misc/grabaddons.sh"

exec ./bin/linux64/srcds -usercon -autoupdate -tickrate 20 -game garrysmod +ip 0.0.0.0 +maxplayers 32 +map sb_gooniverse_v4 +host_workshop_collection "2371557248" +gamemode spaceage -disableluarefresh -console
