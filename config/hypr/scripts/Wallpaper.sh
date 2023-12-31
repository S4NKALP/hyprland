#!/bin/bash

# Wallpaper directory
DIR="$HOME/Pictures/wallpapers"

# Find wallpapers
PICS=($(find "${DIR}" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \)))

# Check if there are wallpapers in the specified directory
if [ ${#PICS[@]} -eq 0 ]; then
    echo "No wallpapers found in ${DIR}. Exiting."
    exit 1
fi

# Randomly select a wallpaper
RANDOMPICS=${PICS[$RANDOM % ${#PICS[@]}]}

# Transition config
FPS=60
TYPE="random"
DURATION=1
BEZIER=".43,1.19,1,.4"
SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION --transition-bezier $BEZIER"

# Check if swww is initialized, and initialize if not
swww query || swww init

# Set the wallpaper with transition parameters
swww img "${RANDOMPICS}" $SWWW_PARAMS

# Notify that the wallpaper has changed
notify-send "Wallpaper Changed" -i "${RANDOMPICS}"

# Create a symbolic link to the current wallpaper
ln -sf "${RANDOMPICS}" "$HOME/.config/hypr/.current_wallpaper"
