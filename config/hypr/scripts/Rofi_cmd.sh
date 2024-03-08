#!/usr/bin/env bash


# Source the configuration file.
CONFIG_FILE=~/.config/hypr/scripts/Ref.sh
source "$CONFIG_FILE"


######################################
#                                    #
#              Calculator            #
#                                    #
######################################

calc() {
    roficmd="rofi -dmenu -p Calc $@"

    while true; do
        result=$(xsel -o -b | $roficmd | xargs echo | bc -l 2>&1)

        if [[ $result ]]; then
            printf "$result" | xsel -b
        else
            break
        fi
    done
}

######################################
#                                    #
#             Tmux Session           #
#                                    #
######################################

tmux(){
tmux_sessions() {
    tmux list-sessions | sed 's/: /| /' | column -t -s'|' -o' | '
}
add_session() {
    kitty -e tmux new-session
}
delete_session() {
    SESSION_TO_DELETE=$(tmux_sessions | rofi -dmenu -p "Select session to delete" | awk '{print $1}')
    [ -n "$SESSION_TO_DELETE" ] && tmux kill-session -t "$SESSION_TO_DELETE"
}
main() {
    if pgrep -x rofi > /dev/null; then
        echo ""
        exit
    fi
    TMUX_SESSION=$(
        (printf "%s\n" "$ADD" "$DELETE" "$QUIT"; tmux_sessions) |
            rofi -dmenu -p " Tmux" -no-show-icons
    )
    case "$TMUX_SESSION" in
        "$ADD") add_session ;;
        "$DELETE") delete_session ;;
        "$QUIT") exit ;;
        *)
            if [ -n "$TMUX_SESSION" ]; then
                SESSION=$(echo "$TMUX_SESSION" | cut -d\  -f1)
                kitty -e tmux attach -t "$SESSION"
            fi
            ;;
    esac
}
main
}

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
CONFIG=$(fd --base-directory "$HOME/.config/keyb/bindings" --type f . | rofi -dmenu -config ~/dotfiles/rofi/config-long.rasi)

hyprctl dispatch exec "[float;size 45% 80%;center 1] kitty keyb -k '$HOME/.config/keyb/bindings/$CONFIG'"
}

######################################
#                                    #
#               Emoji                #
#                                    #
######################################

emoji() {
    A="$(rofi -dmenu -p "Emoji:" -config ~/dotfiles/rofi/config-long.rasi < "$HOME/.config/hypr/configs/emojis" | cut -d ' ' -f 1 | tr -d '\n')"
[[ -n "$A" ]] && wl-copy -- "$A"
}

######################################
#                                    #
#             Bluetooth              #
#                                    #
######################################

bluetooth(){
divider="—————————————————————————————————————————————————————————"
goback=" Back"
theme=~/.config/rofi/config-long.rasi

power_on() {   # Checks if bluetooth controller is powered on
    if bluetoothctl show | grep -q "Powered: yes"; then
        return 0
    else
        return 1
    fi
}
toggle_power() {           # Toggles power state
    if power_on; then
        bluetoothctl power off
        show_menu
    else
        if rfkill list bluetooth | grep -q 'blocked: yes'; then
            rfkill unblock bluetooth && sleep 3
        fi
        bluetoothctl power on
        show_menu
    fi
}
scan_on() {           # Checks if controller is scanning for new devices
    if bluetoothctl show | grep -q "Discovering: yes"; then
        echo "󰂰 Scan: ON"
        return 0
    else
        echo "󰂰 Scan: OFF"
        return 1
    fi
}
toggle_scan() {       # Toggles scanning state
    if scan_on; then
        kill $(pgrep -f "bluetoothctl scan on")
        bluetoothctl scan off
        show_menu
    else
        bluetoothctl scan on &
        echo "Scanning..."
        sleep 5
        show_menu
    fi
}
pairable_on() {         # Checks if controller is able to pair to devices
    if bluetoothctl show | grep -q "Pairable: yes"; then
        echo "󰂴 Pairable: ON"
        return 0
    else
        echo "󰂴 Pairable: OFF"
        return 1
    fi
}
toggle_pairable() {      # Toggles pairable state
    if pairable_on; then
        bluetoothctl pairable off
        show_menu
    else
        bluetoothctl pairable on
        show_menu
    fi
}
discoverable_on() {       # Checks if controller is discoverable by other devices
    if bluetoothctl show | grep -q "Discoverable: yes"; then
        echo "󰂳 Discoverable: ON"
        return 0
    else
        echo "󰂳 Discoverable: OFF"
        return 1
    fi
}
toggle_discoverable() {    # Toggles discoverable state
    if discoverable_on; then
        bluetoothctl discoverable off
        show_menu
    else
        bluetoothctl discoverable on
        show_menu
    fi
}
device_connected() {         # Checks if a device is connected
    device_info=$(bluetoothctl info "$1")
    if echo "$device_info" | grep -q "Connected: yes"; then
        return 0
    else
        return 1
    fi
}
toggle_connection() {    # Toggles device connection
    if device_connected $1; then
        bluetoothctl disconnect $1
        device_menu "$device"
    else
        bluetoothctl connect $1
        device_menu "$device"
    fi
}
device_paired() {     # Checks if a device is paired
    device_info=$(bluetoothctl info "$1")
    if echo "$device_info" | grep -q "Paired: yes"; then
        echo "Paired: "
        return 0
    else
        echo "Paired: "
        return 1
    fi
}
toggle_paired() {       # Toggles device paired state
    if device_paired $1; then
        bluetoothctl remove $1
        device_menu "$device"
    else
        bluetoothctl pair $1
        device_menu "$device"
    fi
}
device_trusted() {        # Checks if a device is trusted
    device_info=$(bluetoothctl info "$1")
    if echo "$device_info" | grep -q "Trusted: yes"; then
        echo "Trusted: "
        return 0
    else
        echo "Trusted: "
        return 1
    fi
}
toggle_trust() {           # Toggles device connection
    if device_trusted $1; then
        bluetoothctl untrust $1
        device_menu "$device"
    else
        bluetoothctl trust $1
        device_menu "$device"
    fi
}
print_status() {         # Prints a short string with the current bluetooth status
    if power_on; then
        printf ''

        mapfile -t paired_devices < <(bluetoothctl paired-devices | grep Device | cut -d ' ' -f 2)
        counter=0

        for device in "${paired_devices[@]}"; do
            if device_connected $device; then
                device_alias=$(bluetoothctl info $device | grep "Alias" | cut -d ' ' -f 2-)

                if [ $counter -gt 0 ]; then
                    printf ", %s" "$device_alias"
                else
                    printf " %s" "$device_alias"
                fi

                ((counter++))
            fi
        done
        printf "\n"
    else
        echo ""
    fi
}
device_menu() {        # A submenu for a specific device that allows connecting, pairing, and trusting
    device=$1
    device_name=$(echo $device | cut -d ' ' -f 3-)     # Get device name and mac address
    mac=$(echo $device | cut -d ' ' -f 2)
    if device_connected $mac; then               # Build options
        connected="Connected: "
    else
        connected="Connected: "
    fi
    paired=$(device_paired $mac)
    trusted=$(device_trusted $mac)
    options="$connected\n$paired\n$trusted\n$divider\n$goback\n󰍃 Exit"n
    chosen="$(echo -e "$options" | $rofi_command "$device_name")"         # Open rofi menu, read chosen optio
    case $chosen in            # Match chosen option to command
        "" | $divider)
            echo "No option chosen."
            ;;
        $connected)
            toggle_connection $mac
            ;;
        $paired)
            toggle_paired $mac
            ;;
        $trusted)
            toggle_trust $mac
            ;;
        $goback)
            show_menu
            ;;
    esac
}
show_menu() {             # Opens a rofi menu with current bluetooth status and options to connect
    if power_on; then                 # Get menu options
        power="󰂯 Power: ON"
        devices=$(bluetoothctl devices | grep Device | cut -d ' ' -f 3-)s   # Human-readable names of devices, one per line. If scan is off, will only list paired devices
        scan=$(scan_on)                    # Get controller flag
        pairable=$(pairable_on)
        discoverable=$(discoverable_on)
        options="$devices\n$divider\n$power\n$scan\n$pairable\n$discoverable\n󰍃 Exit"             # Options passed to rofi
    else
        power="󰂲 Power: OFF"
        options="$power\n󰍃 Exit"
    fi
    chosen="$(echo -e "$options" | $rofi_command " Bluetooth")"        # Open rofi menu, read chosen option
    case $chosen in                  # Match chosen option to command
        "" | $divider)
            echo "No option chosen."
            ;;
        $power)
            toggle_power
            ;;
        $scan)
            toggle_scan
            ;;
        $discoverable)
            toggle_discoverable
            ;;
        $pairable)
            toggle_pairable
            ;;
        *)
            device=$(bluetoothctl devices | grep "$chosen")
            if [[ $device ]]; then device_menu "$device"; fi                     # Open a submenu if a device is selected
            ;;
    esac
}
rofi_command="rofi -dmenu -no-fixed-num-lines -yoffset -100 -i -theme $theme -p"   # Rofi command to pipe into, can add any options here
case "$1" in
    --status)
        print_status
        ;;
    *)
        show_menu
        ;;
esac
}
