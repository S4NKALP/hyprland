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
linker="$SCRIPTSDIR/RunCMD.sh linker"


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
SWWW_PARAMS1="--transition-fps $FPS1 --transition-type $TYPE1 --transition-duration $DURATION1 --transition-bezier ${BEZIER1}"


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
RunCMD="$SCRIPTSDIR/RunCMD.sh"


# For Note
NOTES_AUTHOR="$(whoami)"
NOTES_FOLDER="$HOME/Documents/Notes"
NOTES_EDITOR="kitty --class fly_is_kitty -e nvim"

# Misc
lock="$SCRIPTSDIR/device_cmd.sh lockscreen"
