#!/bin/bash
# Main server runscript

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
export LD_LIBRARY_PATH="$HOME/s/bin/linux64"

cd "$HOME/s"

IP="0.0.0.0"
TICKRATE="20"
MAXPLAYERS="16"
MAP="sb_gooniverse_v4"
source "$HOME/config.sh"

"$HOME/s/garrysmod/addons/spaceage/misc/upgrade.sh"

"$HOME/s/garrysmod/addons/spaceage/misc/steamcmd.sh"

"$HOME/s/garrysmod/addons/spaceage/misc/grabaddons.sh" 177294269

exec ./bin/linux64/srcds -usercon -autoupdate -tickrate "$TICKRATE" -game garrysmod +ip "$IP" +maxplayers "$MAXPLAYERS" +map "$MAP" +host_workshop_collection "2371557248" +gamemode spaceage -disableluarefresh -console
