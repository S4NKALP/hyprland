#!/bin/bash

DIR="$HOME/Pictures/wallpapers"


PICS=($(find ${DIR} -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \)))
RANDOMPICS=${PICS[ $RANDOM % ${#PICS[@]} ]}


# Transition config
FPS=60
TYPE="random"
DURATION=1
BEZIER=".43,1.19,1,.4"
SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION --transition-bezier $BEZIER"


swww query || swww init && swww img ${RANDOMPICS} $SWWW_PARAMS

ln -sf "$RANDOMPICS" "$HOME/.config/hypr/.current_wallpaper"

