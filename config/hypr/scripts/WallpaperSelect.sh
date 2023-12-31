#!/bin/bash

WALLPAPERS_DIR="$HOME/Pictures/wallpapers/"

# find image size to display (very slow)
#echo $(identify -format '%[fx:w]x%[fx:h]\' $HOME/Pictures/wallpapers/$A 2>/dev/null)

build_theme() {
    rows=$1
    cols=$2
    icon_size=$3

    echo "element{orientation:vertical;}element-text{horizontal-align:0.5;}element-icon{size:$icon_size.0000em;}listview{lines:$rows;columns:$cols;}"
}

theme="$HOME/.config/rofi/config-wallpaper.rasi"

ROFI_CMD="rofi -dmenu -i -show-icons -theme-str $(build_theme 3 5 6) -theme ${theme}"

choice=$(ls --escape "$WALLPAPERS_DIR" | xargs -I {} printf "{}\x00icon\x1f$WALLPAPERS_DIR/{}\n" | $ROFI_CMD -p "󰸉  Wallpaper")

wallpaper="$WALLPAPERS_DIR/$choice"

set_wallpaper_kde() {
    qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript \
        "var allDesktops = desktops(); for (i=0;i<allDesktops.length;i++) {d = allDesktops[i];d.wallpaperPlugin = \"org.kde.image\";d.currentConfigGroup = Array(\"Wallpaper\", \"org.kde.image\", \"General\");d.writeConfig(\"Image\", \"file:$1\")}"
    notify-send "Wallpaper Changed" -i "$1"
}

set_wallpaper_gnome() {
    gsettings set org.gnome.desktop.background picture-uri "file://$1"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$1"
    notify-send "Wallpaper Changed" -i "$1"
}

set_wallpaper_sway() {
    swaymsg output "*" bg "$1" "stretch"
    notify-send "Wallpaper Changed" -i "$1"
}

set_wallpaper_default() {
    swww img -t any --transition-bezier 0,.53,1,.48 --transition-duration 1 --transition-fps 60 "$1" &&
    ln -sf "$1" "$HOME/.config/hypr/.current_wallpaper"
    notify-send "Wallpaper Changed" -i "$1"
}

if [ -n "$choice" ]; then
    case "$XDG_CURRENT_DESKTOP" in
        "KDE") set_wallpaper_kde "$wallpaper" ;;
        "GNOME") set_wallpaper_gnome "$wallpaper" ;;
        "sway") set_wallpaper_sway "$wallpaper" ;;
        *) set_wallpaper_default "$wallpaper" ;;
    esac
    exit 0
fi

exit 1
