#!/bin/bash

iDIR="$HOME/.config/swaync/icons"
notify_cmd_shot="notify-send -h string:x-canonical-private-synchronous:shot-notify -u low -i ${iDIR}/picture.png"
time=$(date "+%d-%b_%H-%M-%S")
dir="$(xdg-user-dir)/Pictures/Screenshots"
file="Screenshot_${time}_${RANDOM}.png"
active_window_path="${dir}/Screenshot_${time}_$(hyprctl -j activewindow | jq -r '(.class)').png"

notify_view() {
    local msg="Screenshot Saved."
    [[ "$1" == "active" && ! -e "${active_window_path}" ]] && msg="Screenshot NOT Saved."
    ${notify_cmd_shot} "$msg"
}

countdown() {
    for sec in $(seq $1 -1 1); do
        notify-send -h string:x-canonical-private-synchronous:shot-notify -t 1000 -i "$iDIR"/timer.png "Taking shot in : $sec"
        sleep 1
    done
}

take_shot() {
    cd ${dir} && grim - | tee "$file" | wl-copy
    sleep 2
    notify_view "$1"
}

shotnow() { take_shot; }
shot5() { countdown '5'; sleep 1 && take_shot; }
shot10() { countdown '10'; take_shot; }
shotarea() { cd ${dir} && grim -g "$(slurp)" - | tee "$file" | wl-copy; notify_view; }
shotactive() { hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | grim -g - "${active_window_path}" && sleep 1 && notify_view "active"; }

[[ ! -d "$dir" ]] && mkdir -p "$dir"

case "$1" in
    --now) shotnow ;;
    --in5) shot5 ;;
    --in10) shot10 ;;
    --area) shotarea ;;
    --active) shotactive ;;
    *) echo -e "Available Options: --now --in5 --in10 --area --active"
esac

exit 0
