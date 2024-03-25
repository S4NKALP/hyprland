#!/bin/bash

# A bash script designed to run only once dotfiles installed

# THIS SCRIPT CAN BE DELETED ONCE SUCCESSFULLY BOOTED!! And also, edit ~/.config/hypr/configs/Execs.conf
# not necessary to do since this script is only designed to run only once as long as the marker exists

# Variables
RunCMD=$HOME/.config/hypr/scripts/RunCMD.sh
wallpaper=$HOME/Pictures/wallpapers/47.png
kvantum_theme="Dracula"

swww="swww img"
effect="--transition-bezier .43,1.19,1,.4 --transition-fps 30 --transition-type grow --transition-pos 0.925,0.977 --transition-duration 2"

    # Check if a marker file exists.
    if [ ! -f $HOME/cache/.initial_startup_done ]; then

    # Initial scripts to load in order to have a proper wallpaper
    swww init || swww query && $swww "$wallpaper" $effect

    # For Symbolic Link
    $RunCMD linker > /dev/null 2>&1

    # initiate GTK dark mode and apply icon and cursor theme
    gsettings set org.gnome.desktop.interface gtk-theme Dracula > /dev/null 2>&1 &
    gsettings set org.gnome.desktop.wm.preferences theme Dracula > /dev/null 2>&1 &
    gsettings set org.gnome.desktop.interface icon-theme Dracula > /dev/null 2>&1 &
    gsettings set org.gnome.desktop.interface cursor-theme Bibata-Modern-Ice > /dev/null 2>&1 &
    gsettings set org.gnome.desktop.interface cursor-size 6 > /dev/null 2>&1 &
    gsettings set org.gnome.desktop.interface font-name JetBrainsMono Nerd Font 10 > /dev/null 2>&1 &

    # initiate kvantum theme
    kvantummanager --set "$kvantum_theme" > /dev/null 2>&1 &

    #initiate the kb_layout
    grep 'kb_layout=' "$HOME/.config/hypr/UserConfigs/UserSettings.conf" | cut -d '=' -f 2 | cut -d ',' -f 1 2>/dev/null > $HOME/.cache/kb_layout

    # Create a marker file to indicate that the script has been executed.
    touch $HOME/.cache/.initial_startup_done

    exit
fi
