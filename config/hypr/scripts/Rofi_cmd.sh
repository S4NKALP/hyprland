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
    [ ! -d "$NOTES_FOLDER" ] && mkdir -p "$NOTES_FOLDER"
}
get_notes() {
    ls "$NOTES_FOLDER"
}
edit_note() {
    $NOTES_EDITOR "$1"
}
delete_note() {
    note=$1
    action=$(echo -e "Yes\nNo" | rofi -dmenu -p "Delete $note? ")

    case $action in
        "Yes")
            rm "$NOTES_FOLDER/$note"
            main ;;
        "No")
            main ;;
    esac
}
note_context() {
    note=$1
    note_location="$NOTES_FOLDER/$note"
    action=$(echo -e "Edit\nDelete" | rofi -dmenu -p "$note > ")

    case $action in
        "Edit") edit_note "$note_location"; exit 0 ;;
        "Delete") delete_note "$note"; exit 0 ;;
    esac

    exit 1
}
new_note() {
    title=$(echo -e "Cancel" | rofi -dmenu -p "Input title: ")

    case "$title" in
        "Cancel") main ;;
        *)
            file=$(echo "$title" | sed 's/ /_/g;s/\(.*\)/\L\1/g')
            template="---\ntitle: $title\ndate: $(date --rfc-3339=seconds)\nauthor: $NOTES_AUTHOR\n---\n"
            note_location="$NOTES_FOLDER/$file.md"

            [ "$title" != "" ] && echo -e "$template" > "$note_location" | edit_note "$note_location"
            exit 0
            ;;
    esac
}
main() {
    all_notes="$(get_notes)"
    first_menu="New Note"

    [ "$all_notes" ] && first_menu="New Note\n$all_notes"

    note=$(echo -e "$first_menu" | rofi -dmenu -i -p "Note: ")

    case $note in
        "New Note") new_note ;;
        "") exit 1 ;;
        *) note_context "$note" & ;;
    esac
    exit 1
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
    emojis_file="$HOME/.config/hypr/scripts/emoji.txt"

    show_emoji_menu() {
        awk '{print $1, substr($0, index($0,$2))}' "$emojis_file" | rofi -dmenu -p "🔎 Search" -config ~/.config/rofi/config-long.rasi
    }

    emojis=$(awk '{print $1}' "$emojis_file" | tr '\n' ' ')
    selected_emoji=$(show_emoji_menu)

    if [ -n "$selected_emoji" ]; then
        emoji=$(grep "$selected_emoji" "$emojis_file" | awk '{print $1}')
        echo -n "$emoji" | wl-copy
    fi
}

