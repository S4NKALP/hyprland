#!/bin/bash

# A bash script designed to run only once dotfiles installed

# THIS SCRIPT CAN BE DELETED ONCE SUCCESSFULLY BOOTED!!

# Variables
wallpaper=$HOME/Pictures/wallpapers/wall-03.jpg
kvantum_theme="Darker"
color_scheme="prefer-dark"
gtk_theme="Darker"
icon_theme="Tela-circle-dark"
cursor_theme="Bibata-Orginal-Classic"
font_name=" JetBrainsMono Nerd Font 10"

swww="swww img"
effect="--transition-bezier .43,1.19,1,.4 --transition-fps 30 --transition-type grow --transition-pos 0.925,0.977 --transition-duration 2"

    # Check if a marker file exists.
    if [ ! -f $HOME/cache/.initial_startup_done ]; then

    # Initial scripts to load in order to have a proper wallpaper
    swww query || swww-daemon && $swww $wallpaper $effect

    # initiate GTK dark mode and apply icon and cursor theme
    gsettings set org.gnome.desktop.interface color-scheme $color_scheme > /dev/null 2>&1 &
    gsettings set org.gnome.desktop.interface gtk-theme $gtk_theme > /dev/null 2>&1 &
    gsettings set org.gnome.desktop.wm.preferences theme $gtk_theme > /dev/null 2>&1 &
    gsettings set org.gnome.desktop.interface icon-theme $icon_theme > /dev/null 2>&1 &
    gsettings set org.gnome.desktop.interface cursor-theme $cursor_theme > /dev/null 2>&1 &
    gsettings set org.gnome.desktop.interface cursor-size 6 > /dev/null 2>&1 &
    gsettings set org.gnome.desktop.interface font-name $font_name > /dev/null 2>&1 &

    # initiate kvantum theme
    kvantummanager --set "$kvantum_theme" > /dev/null 2>&1 &

    #initiate the kb_layout
    grep 'kb_layout=' "$HOME/dotfiles/hypr/UserConfigs/UserSettings.conf" | cut -d '=' -f 2 | cut -d ',' -f 1 2>/dev/null > $HOME/.cache/kb_layout

    # Create a marker file to indicate that the script has been executed.
    touch $HOME/.cache/.initial_startup_done

    exit
fi
