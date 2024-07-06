#!/bin/bash

# A bash script designed to run only once to install dotfiles
# THIS SCRIPT CAN BE DELETED ONCE SUCCESSFULLY BOOTED!!

# Variables
color_scheme="prefer-dark"
gtk_theme="adw-gtk3-dark"
icon_theme="Tela-nord-dark"
cursor_theme="Bibata-Original-Classic"
font_name="JetBrainsMono Nerd Font 12"

# Check if a marker file exists.
if [ ! -f "$HOME/.cache/.initial_startup_done" ]; then

    # Initiate GTK dark mode and apply icon and cursor theme
    gsettings set org.gnome.desktop.interface color-scheme "$color_scheme" > /dev/null 2>&1 &
    gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme" > /dev/null 2>&1 &
    gsettings set org.gnome.desktop.wm.preferences theme "$gtk_theme" > /dev/null 2>&1 &
    gsettings set org.gnome.desktop.interface icon-theme "$icon_theme" > /dev/null 2>&1 &
    gsettings set org.gnome.desktop.interface cursor-theme "$cursor_theme" > /dev/null 2>&1 &
    gsettings set org.gnome.desktop.interface cursor-size 6 > /dev/null 2>&1 &
    gsettings set org.gnome.desktop.interface font-name "$font_name" > /dev/null 2>&1 &


    # Initiate the keyboard layout
    kb_layout=$(grep 'kb_layout=' "$HOME/dotfiles/hypr/UserConfigs/UserSettings.conf" | cut -d '=' -f 2 | cut -d ',' -f 1)
    echo "$kb_layout" > "$HOME/.cache/kb_layout"

    # Create a marker file to indicate that the script has been executed.
    touch "$HOME/.cache/.initial_startup_done"

    exit
fi
