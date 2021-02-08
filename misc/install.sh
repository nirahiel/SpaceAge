cd "$HOME/s"

"$HOME/s/garrysmod/addons/spaceage/misc/steamcmd.sh"

git clone https://github.com/MattJeanes/Joystick-Module

cd garrysmod/addons
git clone https://github.com/SpaceAgeMP/sbep
git clone https://github.com/SpaceAgeMP/spacebuild
git clone https://github.com/SpaceAgeMP/smartsnap
git clone https://github.com/wiremod/wire-extras
git clone https://github.com/TomyLobo/lua_reloadent.git
git clone https://github.com/SpaceAgeMP/multi-parent.git
git clone https://github.com/SpaceAgeMP/physgun-build-mode.git

ln -s ../../Joystick-Module/addons/Joystick joystick


cd ../gamemodes
ln -s ../addons/spaceage/gamemodes/spaceage ./
ln -s ../addons/spacebuild/gamemodes/spacebuild ./
cd ../lua
ln -s ../addons/spaceage/lua/bin ./

cd ../cfg
cp ../addons/spaceage/misc/server.cfg server.cfg
cp ../addons/spaceage/misc/game.cfg game.cfg
