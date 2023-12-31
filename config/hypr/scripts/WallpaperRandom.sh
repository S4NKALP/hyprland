#!/bin/bash

DIR="$HOME/Pictures/wallpapers/"
PICS=($(find "${DIR}" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \)))

# Check if there are wallpapers in the specified directory
if [ ${#PICS[@]} -eq 0 ]; then
    echo "No wallpapers found in ${DIR}. Exiting."
    exit 1
fi

# Check if swww is initialized, and initialize if not
swww query || swww init

# Set the transition type to random
export SWWW_TRANSITION_TYPE=random

# This controls (in seconds) when to switch to the next image
INTERVAL=1800

while true; do
    # Select a random wallpaper
    RANDOMPICS=${PICS[$RANDOM % ${#PICS[@]}]}

    # Create symbolic link to the selected wallpaper
    ln -sf "${RANDOMPICS}" "$HOME/.config/hypr/.current_wallpaper"

    # Set the new wallpaper
    swww img "$HOME/.config/hypr/.current_wallpaper"

    sleep $INTERVAL
done
