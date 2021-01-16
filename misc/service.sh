#!/bin/sh

case "$1" in
  start)
    tmux new-session -d -s server -d "$HOME/s/garrysmod/addons/spaceage/misc/run.sh"
    ;;

  stop)
    tmux send-keys -t server 'quit' C-m
    ;;
  *)
esac

exit 0
