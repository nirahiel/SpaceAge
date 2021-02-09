#!/bin/sh

adduser server1

export DEBIAN_FRONTEND=noninteractive

echo steam steamcmd/question select "I AGREE" | sudo debconf-set-selections
echo steam steamcmd/license note '' | sudo debconf-set-selections

dpkg --add-architecture i386
apt update
apt -y dist-upgrade
apt -y install openssl git steamcmd tmux sudo curl htop haveged
