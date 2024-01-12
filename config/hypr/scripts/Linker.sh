#!/bin/bash

# Define the path to the swww cache directory
cache_dir="$HOME/.cache/swww/"

# Get a list of monitor outputs
monitor_outputs=("$cache_dir"/*)

# Initialize a flag to determine if the ln command was executed
ln_success=false

# Loop through monitor outputs
for cache_file in "${monitor_outputs[@]}"; do
    # Check if the cache file exists for the current monitor output
    if [ -f "$cache_file" ]; then
        # Get the wallpaper path from the cache file
        wallpaper_path=$(<"$cache_file")

        # Copy the wallpaper to the location Rofi can access
        if ln -sf "$wallpaper_path" "$HOME/.config/rofi/.current_wallpaper"; then
            ln_success=true  # Set the flag to true upon successful execution
            break  # Exit the loop after processing the first found monitor output
        fi
    fi
done

# Add a message indicating whether the ln command was successful
if $ln_success; then
    echo "Wallpaper linked successfully."
else
    echo "Failed to link wallpaper."
fi
