#!/bin/bash

# Source the configuration file.
CONFIG_FILE=~/dotfiles/hypr/scripts/Ref.sh
source "$CONFIG_FILE"

brightness() {
    local notification_timeout=1000

    get_backlight() {
        brightnessctl -m | cut -d, -f4
    }

    get_icon() {
        local current=$(get_backlight | sed 's/%//')
        echo "$iDIR/brightness.svg"
    }

    notify_user() {
        local current=$(get_backlight | sed 's/%//')
        local icon=$(get_icon)
        notify-send -e -h string:x-canonical-private-synchronous:brightness_notif -h int:value:$current -u low -i "$icon" "Brightness : $current%"
    }

    change_backlight() {
        brightnessctl set "$1" && notify_user
    }

    case "$1" in
        --get) get_backlight ;;
        --inc) change_backlight "+5%" ;;
        --dec) change_backlight "5%-" ;;
        *) get_backlight ;;
    esac
}

volume() {
    get_volume() {
        local volume=$(pamixer --get-volume)
        [[ "$volume" -eq "0" ]] && echo "Muted" || echo "$volume%"
    }

    get_icon() {
        local current=$(get_volume)
        if [[ "$current" == "Muted" ]]; then
            echo "$iDIR/volume-mute.png"
        elif [[ "${current%\%}" -le 30 ]]; then
            echo "$iDIR/volume-low.png"
        elif [[ "${current%\%}" -le 60 ]]; then
            echo "$iDIR/volume-mid.png"
        else
            echo "$iDIR/volume-high.png"
        fi
    }

    notify_user() {
        local volume=$(get_volume)
        local icon=$(get_icon)
        if [[ "$volume" == "Muted" ]]; then
            notify-send -e -h string:x-canonical-private-synchronous:volume_notif -u low -i "$icon" "Volume: Muted"
        else
            notify-send -e -h int:value:"${volume%\%}" -h string:x-canonical-private-synchronous:volume_notif -u low -i "$icon" "Volume: $volume"
        fi
    }

    change_volume() {
        pamixer "$1" "$2" && notify_user
    }

    toggle_mute() {
        if [ "$(pamixer --get-mute)" == "false" ]; then
            pamixer -m && notify-send -e -u low -i "$iDIR/volume-mute.png" "Volume Switched OFF"
        elif [ "$(pamixer --get-mute)" == "true" ]; then
            pamixer -u && notify-send -e -u low -i "$(get_icon)" "Volume Switched ON"
        fi
    }

    toggle_mic() {
        if [ "$(pamixer --default-source --get-mute)" == "false" ]; then
            pamixer --default-source -m && notify-send -e -u low -i "$iDIR/microphone-mute.png" "Microphone Switched OFF"
        elif [ "$(pamixer --default-source --get-mute)" == "true" ]; then
            pamixer -u --default-source u && notify-send -e -u low -i "$iDIR/microphone.png" "Microphone Switched ON"
        fi
    }

    notify_mic_user() {
        local volume=$(pamixer --default-source --get-volume)
        local icon=$(pamixer --default-source --get-mute && echo "$iDIR/microphone-mute.png" || echo "$iDIR/microphone.png")
        notify-send -e -h int:value:"$volume" -h string:x-canonical-private-synchronous:volume_notif -u low -i "$icon" "Mic-Level: $volume%"
    }

    change_mic_volume() {
        pamixer --default-source "$1" "$2" && notify_mic_user
    }

    case "$1" in
        --get) get_volume ;;
        --inc) change_volume -i 5 ;;
        --dec) change_volume -d 5 ;;
        --toggle) toggle_mute ;;
        --toggle-mic) toggle_mic ;;
        --mic-inc) change_mic_volume -i 5 ;;
        --mic-dec) change_mic_volume -d 5 ;;
        *) get_volume ;;
    esac
}

screenshot() {
    local notify_cmd_shot="notify-send -h string:x-canonical-private-synchronous:shot-notify -u low -i ${iDIR}/screenshot.svg"
    local time=$(date "+%d-%b_%H-%M-%S")
    local dir="$(xdg-user-dir)/Pictures/Screenshots"
    local file="Screenshot_${time}_${RANDOM}.png"
    local active_window_path="${dir}/Screenshot_${time}_$(hyprctl -j activewindow | jq -r '.class').png"

    notify_view() {
        local msg="Screenshot Saved."
        [[ "$1" == "active" && ! -e "$active_window_path" ]] && msg="Screenshot NOT Saved."
        $notify_cmd_shot "$msg"
    }

    countdown() {
        for ((sec=$1; sec>0; sec--)); do
            notify-send -h string:x-canonical-private-synchronous:shot-notify -t 1000 -i "$iDIR/timer.png" "Taking shot in: $sec"
            sleep 1
        done
    }

    take_shot() {
        cd "$dir" && grim - | tee "$file" | wl-copy
        sleep 2
        notify_view "$1"
    }

    shot_timer() {
        countdown "$1"
        sleep 1
        take_shot "$2"
    }

    shotarea() {
        local tmpfile=$(mktemp)
        local area=$(slurp)
        [[ -z "$area" ]] && { notify-send -u low -i "$iDIR/picture.png" 'No area selected'; rm "$tmpfile"; return; }
        grim -g "$area" - > "$tmpfile" && [[ -s "$tmpfile" ]] && {
            wl-copy < "$tmpfile"
            mv "$tmpfile" "$dir/Screenshot_$(date '+%d-%b_%H-%M-%S')_${RANDOM}.png"
            notify_view
        }
        rm "$tmpfile"
    }

    shotactive() {
        hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | grim -g - "$active_window_path"
        sleep 1
        notify_view "active"
    }

    [[ ! -d "$dir" ]] && mkdir -p "$dir"

    case "$1" in
        --now) take_shot ;;
        --in5) shot_timer 5 ;;
        --in10) shot_timer 10 ;;
        --area) shotarea ;;
        --active) shotactive ;;
        *) echo "Available Options: --now --in5 --in10 --area --active" ;;
    esac
}
