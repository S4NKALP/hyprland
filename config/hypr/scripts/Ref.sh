#!/bin/bash

# For TouchPad
HYPRLAND_DEVICE="dll07a7:01-044e:120b"
DIR=$HOME/.cache
STATUS_FILE="$DIR/touchpad.status"

# For Notification icon
notif="$HOME/.config/swaync/images/bell.png"

# Scripts DIR
SCRIPTSDIR="$HOME/.config/hypr/scripts"
UserSCRIPTSDIR="$HOME/.config/hypr/UserScripts"
linker="$SCRIPTSDIR/Linker.sh"


# For Tmux Sessions
ADD="  Add new session"
DELETE="󰆴  Delete a session"
QUIT="󰗼  Quit"


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
SWWW_PARAMS1="--transition-fps $FPS1 --transition-type $TYPE1 --transition-duration $DURATION1"


# For Keyboard Layout Switcher
layout_f="$HOME/.cache/kb_layout"
settings_file="$HOME/.config/hypr/UserConfigs/UserSettings.conf"


# For Quickedit
configs="$HOME/.config/hypr/configs"
UserConfigs="$HOME/.config/hypr/UserConfigs"


# For TODO
file="$HOME/Documents/Notes/.rofi_todo"
touch "$file"
prompt="Add/delete a task: "
height=$(wc -l "$file" | awk '{print $1}')


# For Waybar Layout
config_dir="$HOME/.config/waybar/configs"
waybar_config="$HOME/.config/waybar/config"
CMD="$SCRIPTSDIR/RunCMD.sh reload"


# For Note
NOTES_AUTHOR="$(whoami)"
NOTES_FOLDER="$HOME/Documents/Notes"
NOTES_EDITOR="kitty nvim"

# Misc
lock="$SCRIPTSDIR/device_cmd.sh lockscreen"


# Wallpaper Downloader
CATEGORIES=100
FILTER=100
RESOLUTION=1920x1080
ATLEAST=1920x1080
ASPECTRATIO=16x9
TOPRANGE=1y
ORDER=desc
COLLECTION="Default"
COLOR=""
PARALLEL=1
THUMBS=24
LOCATION=$HOME/Pictures/Wallpapers
APIKEY="u4YNdj6N0M7nkrM2Pbz7fHAY0EYIT5WL"

