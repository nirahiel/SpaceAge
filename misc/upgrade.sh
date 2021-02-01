#!/bin/bash

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"

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
