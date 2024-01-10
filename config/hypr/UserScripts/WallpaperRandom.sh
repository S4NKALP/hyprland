#!/bin/bash

# Script for Random Wallpaper (SHIFT ALT W)

# Directory paths
wallDIR="$HOME/Pictures/wallpapers"
hyprConfigDir="$HOME/.config/hypr"
scriptsDir="$hyprConfigDir/scripts"

# Check if swww is initialized; if not, initialize it
swww query || swww init

# Array of image files in wallDIR
PICS=($(find "${wallDIR}" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \)))

# Check if there are images in the specified directory
if [ ${#PICS[@]} -eq 0 ]; then
  echo "No images found in ${wallDIR}. Exiting."
  exit 1
fi

# Select a random image
RANDOMPICS=${PICS[$RANDOM % ${#PICS[@]}]}

# Transition config
FPS=60
TYPE="random"
DURATION=1
BEZIER=".43,1.19,1,.4"
SWWW_PARAMS="--transition-fps ${FPS} --transition-type ${TYPE} --transition-duration ${DURATION} --transition-bezier ${BEZIER}"

# Set the randomly selected wallpaper
swww img "${RANDOMPICS}" ${SWWW_PARAMS}

${scriptsDir}/Linker.sh
