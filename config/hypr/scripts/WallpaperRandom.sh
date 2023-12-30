#!/bin/bash

DIR="$HOME/Pictures/wallpapers/"
PICS=($(find "${DIR}" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \)))
RANDOMPICS=${PICS[$RANDOM % ${#PICS[@]}]}

# Create symbolic link to the selected wallpaper
ln -sf "${RANDOMPICS}" "$HOME/.config/hypr/.current_wallpaper"

# Check if swww is initialized
swww query || swww init

# Set the wallpaper
swww img "$HOME/.config/hypr/.current_wallpaper"

if [[ $# -lt 1 ]] || [[ ! -d $1 ]]; then
    exit 1
fi

export SWWW_TRANSITION_TYPE=random

# This controls (in seconds) when to switch to the next image
INTERVAL=1800

while true; do
    find "$1" -type f \
        | shuf \
        | while read -r img; do
            # Update the symbolic link to the new wallpaper
            ln -sf "$img" "$HOME/.config/hypr/.current_wallpaper"
            # Set the new wallpaper
            swww img "$HOME/.config/hypr/.current_wallpaper"
            sleep $INTERVAL
        done
done
