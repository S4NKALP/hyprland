#!/bin/bash

# Screenshots scripts
iDIR="$HOME/dotfiles/hypr/assets"

notify_cmd_shot="notify-send -h string:x-canonical-private-synchronous:shot-notify -u low -i ${iDIR}/screenshot.svg"
dir="$(xdg-user-dir PICTURES)/Screenshots"
[[ ! -d "$dir" ]] && mkdir -p "$dir"

notify_view() {
    local msg="Screenshot Saved."
    if [[ "$1" == "active" && ! -e "$active_window_path" ]]; then
        msg="Screenshot NOT Saved."
    fi
    $notify_cmd_shot "$msg"
}

countdown() {
    for ((sec=$1; sec>0; sec--)); do
        notify-send -h string:x-canonical-private-synchronous:shot-notify -t 1000 -i "$iDIR/timer.png" "Taking shot in: $sec"
        sleep 1
    done
}

take_shot() {
    local time=$(date "+%d-%b_%H-%M-%S")
    local file="Screenshot_${time}_${RANDOM}.png"
    cd "$dir" && grim - | tee "$file" | wl-copy
    sleep 2
    notify_view "$1"
}

shot_timer() {
    local time=$(date "+%d-%b_%H-%M-%S")
    local file="Screenshot_${time}_${RANDOM}.png"
    countdown "$1"
    sleep 1
    take_shot "$2"
}

shotarea() {
    local time=$(date "+%d-%b_%H-%M-%S")
    local tmpfile=$(mktemp)
    local area=$(slurp)
    if [[ -z "$area" ]]; then
        notify-send -u low -i "$iDIR/picture.png" 'No area selected'
        rm "$tmpfile"
        return
    fi
    grim -g "$area" - > "$tmpfile" && [[ -s "$tmpfile" ]] && {
        wl-copy < "$tmpfile"
        mv "$tmpfile" "$dir/Screenshot_${time}_${RANDOM}.png"
        notify_view
    }
    rm "$tmpfile"
}

shotactive() {
    local time=$(date "+%d-%b_%H-%M-%S")
    local active_window_path="${dir}/Screenshot_${time}_$(hyprctl -j activewindow | jq -r '.class').png"
    hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | grim -g - "$active_window_path"
    sleep 1
    notify_view "active"
}

case "$1" in
    --now) take_shot ;;
    --in5) shot_timer 5 ;;
    --in10) shot_timer 10 ;;
    --area) shotarea ;;
    --active) shotactive ;;
    *) echo "Available Options: --now --in5 --in10 --area --active" ;;
esac
