#!/usr/bin/env bash


# Source the configuration file.
CONFIG_FILE=~/.config/hypr/scripts/Ref.sh
source "$CONFIG_FILE"


# Todo List (SHIFT ALT T)
todo() {
    while cmd=$(rofi -dmenu -p "$prompt" -lines "$height" "$@" < "$file"); [ -n "$cmd" ]; do
        if grep -q "^$cmd\$" "$file"; then
            grep -v "^$cmd\$" "$file" > "$file.$$"
            mv "$file.$$" "$file"
            ((height--))
        else
            echo "$cmd" >> "$file"
            ((height++))
        fi
    done
    exit 0
}


# Function For Calculator (ALT C)
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


# Funtion for Tmux Sessions (ALT t)
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


# Take note (ALT B)
note() {
if [[ ! -d "${NOTES_FOLDER}" ]]; then
    mkdir -p "$NOTES_FOLDER"
fi
get_notes() {
    ls "${NOTES_FOLDER}"
}
edit_note() {
    note_location=$1
    $NOTES_EDITOR "$note_location"
}
delete_note() {
    local note=$1
    local action=$(echo -e "Yes\nNo" | rofi -dmenu -p "Are you sure you want to delete $note? ")
    case $action in
        "Yes")
            rm "$NOTES_FOLDER/$note"
            main
            ;;
        "No")
            main
    esac
}
note_context() {
    local note=$1
    local note_location="$NOTES_FOLDER/$note"
    local action=$(echo -e "Edit\nDelete" | rofi -dmenu -p "$note > ")
    case $action in
        "Edit")
            edit_note "$note_location"
            exit 0;;
        "Delete")
            delete_note "$note"
			exit 0;;
    esac
	exit 1
}
new_note() {
    local title=$(echo -e "Cancel" | rofi -dmenu -p "Input title: ")

    case "$title" in
        "Cancel")
            main
            ;;
        *)
            local file=$(echo "$title" | sed 's/ /_/g;s/\(.*\)/\L\1/g')
            local template=$(cat <<- END
---
title: $title
date: $(date --rfc-3339=seconds)
author: $AUTHOR
---

# $title
END
            )
            note_location="$NOTES_FOLDER/$file.md"
            if [ "$title" != "" ]; then
                echo "$template" > "$note_location" | edit_note "$note_location"
                exit 0
            fi
            ;;
    esac
}
main()
{
    local all_notes="$(get_notes)"
    local first_menu="New"
    if [ "$all_notes" ];then
        first_menu="New\n${all_notes}"
    fi
    local note=$(echo -e "$first_menu"  | rofi -dmenu -p "󰚸  Notes")
    case $note in
        "New")
            new_note
            ;;
        "")
            exit 1;;
        *)
            note_context "$note" && exit 0 # handle esc key in note_context
    esac
	exit 1
}
main
}


# Clipboard Manager. This script uses cliphist, rofi, and wl-copy. (SHIFT ALT C)
clip() {
    while true; do
        result=$(rofi -dmenu -kb-custom-1 "Control-Delete" -kb-custom-2 "Alt-Delete" -p "CTRL Del - Cliphist del || Alt Del - cliphist wipe" -config ~/.config/rofi/config-long.rasi < <(cliphist list))

        case "$?" in
            1) exit ;;
            0) [ -n "$result" ] && cliphist decode <<<"$result" | wl-copy; exit ;;
            10) cliphist delete <<<"$result" ;;
            11) cliphist wipe ;;
        esac
    done
}


# Rofi menu for Quick Edit / View of Settings (SUPER E)
edit() {
    menu() {
        options=("Env-variables" "Window-Rules" "Startup_Apps" "User-Keybinds" "Monitors" "Laptop-Keybinds" "User-Settings" "Default-Settings" "Default-Keybinds")
        for ((i = 0; i < ${#options[@]}; i++)); do
            printf "%d. view %s\n" "$((i + 1))" "${options[i]}"
        done
    }
    main() {
        options=("ENVariables.conf" "WindowRules.conf" "Startup_Apps.conf" "UserKeybinds.conf" "Monitors.conf" "Laptops.conf" "UserSettings.conf" "Settings.conf" "Keybinds.conf")
        choice=$(menu | rofi -dmenu -i -l 9 -p " View / Edit Hyprland Configs:" | cut -d. -f1)
        [[ $choice =~ ^[1-9]$ ]] && kitty -e nano "$UserConfigs/${options[choice - 1]}"
    }
    main
}


# Powermenu (SUPER X)
powermenu() {
    uptime_info=$(uptime -p | sed -e 's/up //g')
    host=$(hostnamectl hostname)
    options=("Lock(l)" "Suspend(u)" "Logout(e)" "Reboot(r)" "Shutdown(s)" "Hibernate(h)")
    icons=("" "" "󰿅" "󱄌" "" "󰒲")

    chosen_option=$(printf "%s\n" "${options[@]}" | \
        rofi -dmenu -i -p " $USER@$host" -mesg " Uptime: $uptime_info" \
        -kb-select-1 "l" \
        -kb-select-2 "u" \
        -kb-select-3 "e" \
        -kb-select-4 "r" \
        -kb-select-5 "s" \
        -kb-select-6 "h" \
        -theme ~/.config/rofi/config-powermenu.rasi | awk '{print $1}')

    case $chosen_option in
        "Lock(l)") swaylock & ;;
        "Suspend(u)") swaylock -f && systemctl suspend ;;
        "Logout(e)") hyprctl dispatch exit 0 ;;
        "Reboot(r)") systemctl reboot ;;
        "Shutdown(s)") systemctl poweroff ;;
        "Hibernate(h)") swaylock -f && systemctl hibernate ;;
        *) echo "choose: $chosen_option" ;;
    esac
}

# Keybinds (SUPER F1 )
keybind() {
CONFIG=$(rofi -show file-browser-extended -file-browser-stdout -file-browser-dir "$HOME"/.config/keyb/bindings -config ~/.config/rofi/config-long.rasi)

hyprctl dispatch exec "[float;size 45% 80%;center 1] kitty keyb -k '$CONFIG'"
}

# Emoji (ALT SLASH)
emoji() {
    A="$(rofi -dmenu -p "Emoji:" -config ~/.config/rofi/config-long.rasi < "$HOME/.config/hypr/configs/emojis" | cut -d ' ' -f 1 | tr -d '\n')"
[[ -n "$A" ]] && wl-copy -- "$A"
}


bluetooth(){
goback=" Back"
theme=~/.config/rofi/config-long.rasi

# Checks if bluetooth controller is powered on
power_on() {
    if bluetoothctl show | grep -q "Powered: yes"; then
        return 0
    else
        return 1
    fi
}

# Toggles power state
toggle_power() {
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

# Checks if controller is scanning for new devices
scan_on() {
    if bluetoothctl show | grep -q "Discovering: yes"; then
        echo "󰂰 Scan: ON"
        return 0
    else
        echo "󰂰 Scan: OFF"
        return 1
    fi
}

# Toggles scanning state
toggle_scan() {
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

# Checks if controller is able to pair to devices
pairable_on() {
    if bluetoothctl show | grep -q "Pairable: yes"; then
        echo "󰂴 Pairable: ON"
        return 0
    else
        echo "󰂴 Pairable: OFF"
        return 1
    fi
}

# Toggles pairable state
toggle_pairable() {
    if pairable_on; then
        bluetoothctl pairable off
        show_menu
    else
        bluetoothctl pairable on
        show_menu
    fi
}

# Checks if controller is discoverable by other devices
discoverable_on() {
    if bluetoothctl show | grep -q "Discoverable: yes"; then
        echo "󰂳 Discoverable: ON"
        return 0
    else
        echo "󰂳 Discoverable: OFF"
        return 1
    fi
}

# Toggles discoverable state
toggle_discoverable() {
    if discoverable_on; then
        bluetoothctl discoverable off
        show_menu
    else
        bluetoothctl discoverable on
        show_menu
    fi
}

# Checks if a device is connected
device_connected() {
    device_info=$(bluetoothctl info "$1")
    if echo "$device_info" | grep -q "Connected: yes"; then
        return 0
    else
        return 1
    fi
}

# Toggles device connection
toggle_connection() {
    if device_connected $1; then
        bluetoothctl disconnect $1
        device_menu "$device"
    else
        bluetoothctl connect $1
        device_menu "$device"
    fi
}

# Checks if a device is paired
device_paired() {
    device_info=$(bluetoothctl info "$1")
    if echo "$device_info" | grep -q "Paired: yes"; then
        echo "Paired: "
        return 0
    else
        echo "Paired: "
        return 1
    fi
}

# Toggles device paired state
toggle_paired() {
    if device_paired $1; then
        bluetoothctl remove $1
        device_menu "$device"
    else
        bluetoothctl pair $1
        device_menu "$device"
    fi
}

# Checks if a device is trusted
device_trusted() {
    device_info=$(bluetoothctl info "$1")
    if echo "$device_info" | grep -q "Trusted: yes"; then
        echo "Trusted: "
        return 0
    else
        echo "Trusted: "
        return 1
    fi
}

# Toggles device connection
toggle_trust() {
    if device_trusted $1; then
        bluetoothctl untrust $1
        device_menu "$device"
    else
        bluetoothctl trust $1
        device_menu "$device"
    fi
}

# Prints a short string with the current bluetooth status
# Useful for status bars like polybar, etc.
print_status() {
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

# A submenu for a specific device that allows connecting, pairing, and trusting
device_menu() {
    device=$1

    # Get device name and mac address
    device_name=$(echo $device | cut -d ' ' -f 3-)
    mac=$(echo $device | cut -d ' ' -f 2)

    # Build options
    if device_connected $mac; then
        connected="Connected: "
    else
        connected="Connected: "
    fi
    paired=$(device_paired $mac)
    trusted=$(device_trusted $mac)
    options="$connected\n$paired\n$trusted\n$goback\n󰍃 Exit"

    # Open rofi menu, read chosen option
    chosen="$(echo -e "$options" | $rofi_command "$device_name")"

    # Match chosen option to command
    case $chosen in
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

# Opens a rofi menu with current bluetooth status and options to connect
show_menu() {
    # Get menu options
    if power_on; then
        power="󰂯 Power: ON"

        # Human-readable names of devices, one per line
        # If scan is off, will only list paired devices
        devices=$(bluetoothctl devices | grep Device | cut -d ' ' -f 3-)

        # Get controller flags
        scan=$(scan_on)
        pairable=$(pairable_on)
        discoverable=$(discoverable_on)

        # Options passed to rofi
        options="$devices\n$power\n$scan\n$pairable\n$discoverable\n󰍃 Exit"
    else
        power="󰂲 Power: OFF"
        options="$power\n󰍃 Exit"
    fi

    # Open rofi menu, read chosen option
    chosen="$(echo -e "$options" | $rofi_command " Bluetooth")"

    # Match chosen option to command
    case $chosen in
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
            # Open a submenu if a device is selected
            if [[ $device ]]; then device_menu "$device"; fi
            ;;
    esac
}

# Rofi command to pipe into, can add any options here
rofi_command="rofi -dmenu -no-fixed-num-lines -yoffset -100 -i -theme $theme -p"

case "$1" in
    --status)
        print_status
        ;;
    *)
        show_menu
        ;;
esac

    }
