#!/usr/bin/env bash


# Source the configuration file.
CONFIG_FILE=~/dotfiles/hypr/scripts/Ref.sh
source "$CONFIG_FILE"


######################################
#                                    #
#          Clipboard Manager         #
#                                    #
######################################

clip() {
    while true; do
        result=$(rofi -dmenu -kb-custom-1 "Control-Delete" -kb-custom-2 "Alt-Delete" -p "CTRL Del - Cliphist del || Alt Del - cliphist wipe" -config ~/dotfiles/rofi/config-long.rasi < <(cliphist list))

        case "$?" in
            1) exit ;;
            0) [ -n "$result" ] && cliphist decode <<<"$result" | wl-copy; exit ;;
            10) cliphist delete <<<"$result" ;;
            11) cliphist wipe ;;
        esac
    done
}


######################################
#                                    #
#               Quick Edit           #
#                                    #
######################################

edit() {
    menu() {
        options=("Env-variables" "Window-Rules" "Startup_Apps" "User-Keybinds" "Monitors" "Laptop-Keybinds" "User-Settings" "Default-Settings" "Default-Keybinds")
        for ((i = 0; i < ${#options[@]}; i++)); do
            printf "%d. view %s\n" "$((i + 1))" "${options[i]}"
        done
    }
    main() {
        options=("ENVariables.conf" "WindowRules.conf" "Startup_Apps.conf" "UserKeybinds.conf" "Monitors.conf" "Laptops.conf" "UserSettings.conf" "Settings.conf" "Keybinds.conf")
        choice=$(menu | rofi -dmenu -i -p " View / Edit Hyprland Configs:" | cut -d. -f1)
        [[ $choice =~ ^[1-9]$ ]] && kitty -e nano "$UserConfigs/${options[choice - 1]}"
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


######################################
#                                    #
#              Powermenu             #
#                                    #
######################################

powermenu() {
    uptime=$(uptime -p | sed -e 's/up //g')
    host=$(hostnamectl hostname)

    # Options
    shutdown='󰤁'
    reboot='󰜉'
    lock=''
    suspend='󰤄'
    logout='󰍃'
    yes='󰸞'
    no='󱎘'

    rofi_cmd() {
        rofi -dmenu \
            -p "Uptime: $uptime" \
            -mesg "Uptime: $uptime" \
            -theme ~/.config/rofi/powermenu.rasi
    }

    confirm_cmd() {
        rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
            -theme-str 'mainbox {children: [ "message", "listview" ];}' \
            -theme-str 'listview {columns: 2; lines: 1;}' \
            -theme-str 'element-text {horizontal-align: 0.5;}' \
            -theme-str 'textbox {horizontal-align: 0.5;}' \
            -dmenu \
            -p 'Confirmation' \
            -mesg 'Are you sure?' \
            -theme ~/.config/rofi/powermenu.rasi
    }

    confirm_exit() {
        echo -e "$yes\n$no" | confirm_cmd
    }

    run_rofi() {
        echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
    }

    # Execute Command
    run_cmd() {
        selected=$(confirm_exit)
        if [[ "$selected" == "$yes" ]]; then
            case $1 in
                --shutdown) systemctl poweroff ;;
                --reboot) systemctl reboot ;;
                --suspend) hyprlock -f && systemctl suspend ;;
                --logout) loginctl terminate-user $USER ;;
            esac
        else
            exit 0
        fi
    }

    chosen=$(run_rofi)
    case ${chosen} in
        $shutdown) run_cmd --shutdown ;;
        $reboot) run_cmd --reboot ;;
        $lock) hyprlock ;;
        $suspend) run_cmd --suspend ;;
        $logout) run_cmd --logout ;;
    esac
}
