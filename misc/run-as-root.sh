#!/bin/sh

dpkg --add-architecture i386
apt update
apt -y install libssl git steamcmd tmux sudo curl
