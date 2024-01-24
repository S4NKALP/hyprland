#!/bin/bash

# Script for keyboard backlights (if supported) & screen using brightnessctl

iDIR="$HOME/.config/swaync/icons"
notification_timeout=1000

get_backlight() {
    echo $(brightnessctl -m | cut -d, -f4)
}

get_kbd_backlight() {
    brightnessctl -d '*::kbd_backlight' -m | cut -d, -f4 | tr -d '%'
}

get_icon() {
    current=$(get_backlight | sed 's/%//')
    [ "$current" -le "20" ] && icon="$iDIR/brightness-20.png" ||
    [ "$current" -le "40" ] && icon="$iDIR/brightness-40.png" ||
    [ "$current" -le "60" ] && icon="$iDIR/brightness-60.png" ||
    [ "$current" -le "80" ] && icon="$iDIR/brightness-80.png" ||
    icon="$iDIR/brightness-100.png"
}

notify_user() {
    notify-send -e -h string:x-canonical-private-synchronous:brightness_notif -h int:value:$current -u low -i "$icon" "Brightness: $current%"
}

change_backlight() {
    brightnessctl set "$1" && get_icon && notify_user
}

change_kbd_backlight() {
    brightnessctl -d '*::kbd_backlight' set "$1" && get_icon && notify_user
}

case "$1" in
    "--get")
        get_backlight
        ;;
    "--inc")
        change_backlight "+5%"
        ;;
    "--dec")
        change_backlight "5%-"
        ;;
    "--get-kbd")
        get_kbd_backlight
        ;;
    "--inc-kbd")
        change_kbd_backlight "+30%"
        ;;
    "--dec-kbd")
        change_kbd_backlight "30%-"
        ;;
    *)
        get_backlight
        ;;
esac
