#!/bin/bash

# Clipboard Manager. This needed cliphist & wl-copy and of course rofi

while true; do
    if pidof rofi &> /dev/null; then
        pkill rofi
    fi

    result=$(cliphist list | rofi -kb-custom-1 "Ctrl+Delete" -dmenu -config ~/.config/rofi/config-long.rasi)
    exit_state=$?

    [[ $exit_state -eq 1 ]] && break

    case "$exit_state" in
        0)
            cliphist decode <<<"$result" | wl-copy
            exit
            ;;
        10)
            cliphist delete <<<"$result"
            ;;
    esac
done
