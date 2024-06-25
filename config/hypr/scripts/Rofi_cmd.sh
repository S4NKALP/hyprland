#!/usr/bin/env bash


# Source the configuration file.
CONFIG_FILE=~/dotfiles/hypr/scripts/Ref.sh
source "$CONFIG_FILE"

######################################
#                                    #
#               Quick Edit           #
#                                    #
######################################

edit() {
    menu() {
        options=("Env-variables" "Window-Rules" "Startup_Apps" "User-Keybinds" "Monitors" "Laptop-Keybinds" "User-Settings" )
        for ((i = 0; i < ${#options[@]}; i++)); do
            printf "%d. view %s\n" "$((i + 1))" "${options[i]}"
        done
    }
    main() {
        options=("ENVariables.conf" "WindowRules.conf" "Startup_Apps.conf" "UserKeybinds.conf" "Monitors.conf" "Laptops.conf" "UserSettings.conf" )
        choice=$(menu | rofi -dmenu -i -p " View / Edit Hyprland Configs:" | cut -d. -f1)
        [[ $choice =~ ^[1-7]$ ]] && kitty -e nvim "$UserConfigs/${options[choice - 1]}"
    }
    main
}

######################################
#                                    #
#               Keybinds             #
#                                    #
######################################

keybind() {
CONFIG=$(fd --base-directory "$HOME/dotfiles/keyb/bindings" --type f . | rofi -dmenu -p "Keybinds" -config ~/dotfiles/rofi/config-long.rasi)

hyprctl dispatch exec "[float;size 45% 80%;center 1] kitty keyb -k '$HOME/dotfiles/keyb/bindings/$CONFIG'"
}

######################################
#                                    #
#               Emoji                #
#                                    #
######################################

emoji() {
    A="$(rofi -dmenu -p "Emoji:" -config ~/dotfiles/rofi/config-long.rasi < "$HOME/dotfiles/hypr/configs/emojis" | cut -d ' ' -f 1 | tr -d '\n')"
[[ -n "$A" ]] && wl-copy -- "$A"
}

