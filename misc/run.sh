#!/bin/bash

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
export LD_LIBRARY_PATH=".:bin:$LD_LIBRARY_PATH"

export WORKSHOP_COLLECTION=177294269

cd "$HOME/s"

pushd garrysmod/addons/spaceage
git pull
popd

steamcmd +runscript "$HOME/install.txt"

./grabaddons.sh

exec ./srcds_linux -usercon -autoupdate -tickrate 20 -game garrysmod +ip 0.0.0.0 +maxplayers 32 +map sb_gooniverse_v4 +host_workshop_collection "$WORKSHOP_COLLECTION" +gamemode spaceage -disableluarefresh -console
