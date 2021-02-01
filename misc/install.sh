cd "$HOME/s"

cd gamemodes
ln -s ../addons/spaceage/gamemodes/spaceage ./
ln -s ../addons/spacebuild/gamemodes/spacebuild ./
cd ../lua
ln -s ../addons/spaceage/lua/bin ./

cd ../cfg
cp ../addons/spaceage/misc/server.cfg server.cfg
cp ../addons/spaceage/misc/game.cfg game.cfg
