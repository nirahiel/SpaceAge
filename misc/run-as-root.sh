#!/bin/sh

adduser server1

dpkg --add-architecture i386
apt update
apt -y dist-upgrade
apt -y install openssl git steamcmd tmux sudo curl htop haveged
