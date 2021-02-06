#!/bin/sh
# Loads addons into a lua file for easy resource adding

set -e

WORKSHOP_COLLECTION="$1"

RES="$(curl -s -f -XPOST 'https://api.steampowered.com/ISteamRemoteStorage/GetCollectionDetails/v1/' -d "collectioncount=1&publishedfileids%5B0%5D=$WORKSHOP_COLLECTION" | jq -r '.response.collectiondetails[0].children | map("resource.AddWorkshop(\"" + .publishedfileid + "\")") | join("\n")')"

echo "$RES" > "$HOME/s/garrysmod/lua/autorun/server/loadaddons.lua"
