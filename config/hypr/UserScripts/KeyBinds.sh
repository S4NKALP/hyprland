#!/usr/bin/env bash

CONFIG=$(rofi -show file-browser-extended -file-browser-stdout -file-browser-dir "$HOME"/.config/keyb/bindings -config ~/.config/rofi/keybinds.rasi)

hyprctl dispatch exec "[float;size 45% 80%;center 1] kitty keyb -k '$CONFIG'"
