#!/bin/sh
RES=$(ps -Al | grep -i  -E "(totem|vlc|mplayer)")

if [ -n "${RES}" ]; then
exit 1;
else
exit 0;
fi 
