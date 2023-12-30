#!/usr/bin/env bash

notif="$HOME/.config/swaync/images/bell.png"

# Script to toggle animations in hyprland

# Function to toggle animations
function toggle_mode() {
    status=$(hyprctl getoption animations:enabled -j | jq ".int")
    if [[ $status -eq 1 ]]; then
        notify-send -e -u low -i "$notif" "All animations off"
        hyprctl keyword animations:enabled 0
        swww kill
    else
         notify-send -e -u normal -i "$notif" "All animations normal"
        hyprctl keyword animations:enabled 1
        swww init && swww img "$HOME/.config/hypr/.current_wallpaper"
    fi
}

# Parse options
while getopts t flag; do
    case "${flag}" in
        t) toggle_mode ;;
    esac
done
