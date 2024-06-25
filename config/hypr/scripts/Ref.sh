#!/bin/bash

# For Notification icon
notif="$HOME/dotfiles/hypr/assets/bell.png"
reload="$HOME/dotfiles/hypr/assets/reload.svg"

# Scripts DIR
SCRIPTSDIR="$HOME/dotfiles/hypr/scripts"
UserSCRIPTSDIR="$HOME/dotfiles/hypr/UserScripts"


# For Random Wallpaper
wallDIR="$HOME/Pictures/wallpapers"
FPS=60
TYPE="random"
DURATION=1
BEZIER=".43,1.19,1,.4"
SWWW_PARAMS="--transition-fps ${FPS} --transition-type ${TYPE} --transition-duration ${DURATION} --transition-bezier ${BEZIER}"

# For Select Wallpaper
FPS1=30
TYPE1="wipe"
DURATION1=1
BEZIER1=".43,1.19,1,.4"
SWWW_PARAMS1="--transition-fps $FPS1 --transition-type $TYPE1 --transition-duration $DURATION1 --transition-bezier ${BEZIER1}"


# For Keyboard Layout Switcher
layout_f="$HOME/.cache/kb_layout"
settings_file="$HOME/dotfiles/hypr/UserConfigs/UserSettings.conf"


# For Quickedit
configs="$HOME/dotfiles/hypr/configs"
UserConfigs="$HOME/dotfiles/hypr/UserConfigs"

iDIR="$HOME/dotfiles/hypr/assets"

RunCMD="$SCRIPTSDIR/RunCMD.sh"
