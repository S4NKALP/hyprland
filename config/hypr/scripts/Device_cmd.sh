#!/bin/bash

# Source the configuration file.
CONFIG_FILE=~/.config/hypr/scripts/Ref.sh
source "$CONFIG_FILE"


# Toggle touchpad state. (SUPER SHIFT D)
touchpad() {
  local status_file="$STATUS_FILE"
  local action

  if [[ ! -e "$status_file" ]] || ! $(<"$status_file"); then
    echo "true" > "$status_file"
    action="enabled"
  else
    echo "false" > "$status_file"
    action="disabled"
  fi

  notify-send -u low -i "$notif" "Touchpad $action"
  hyprctl keyword "device:$HYPRLAND_DEVICE:enabled" "$(cat "$status_file")"
}


# Toggle Wifi
wifi() {
    wifi_status=$(nmcli radio wifi)
    if [ "$wifi_status" == "enabled" ]; then
	    nmcli radio wifi off
        notify-send -u low -i "$notif" 'Airplane mode: OFF'
    else
        nmcli radio wifi on
        notify-send -u low -i "$notif" 'Airplane mode: ON'
    fi
}

# Toggle Bluetooth
bluetooth() {
    if [ "$bluetooth_status" == "no" ]; then
        bluetoothctl power on
        notify-send -u low -i "$notif" 'Bluetooth ON'
    else
        bluetoothctl power off
        notify-send -u low -i "$notif" 'Bluetooth OFF'
    fi
}

# Reload Waybar, Rofi, Swaync, and Rainbowborder.sh (SHIFT ALT R)
reload() {
    file_exists() {
        [ -e "$1" ]
    }

    processes=("waybar" "rofi" "swaync")

    for process in "${processes[@]}"; do
        pid=$(pidof "$process")
        if [ -n "$pid" ]; then
            pkill "$process"
        fi
    done

    sleep 0.3
    waybar &
    sleep 0.5
    swaync > /dev/null 2>&1 &
    sleep 1

    script_path="${UserSCRIPTSDIR}/RainbowBorders.sh"
    if file_exists "$script_path"; then
        "$script_path" &
    fi
}


# LockScreen with swaylock
lockscreen() {
    LOCKCONFIG="$HOME/.config/swaylock/config"
    sleep 0.5s
    swaylock --config ${LOCKCONFIG} &
    disown
}


# Switch Keyboard Layout (ALT F1)
kb() {
if [ ! -f "$layout_f" ]; then
  default_layout=$(grep 'kb_layout=' "$settings_file" | cut -d '=' -f 2 | cut -d ',' -f 1 2>/dev/null)
  if [ -z "$default_layout" ]; then
    default_layout="us" # Default to 'us' layout if Settings.conf or 'kb_layout' is not found
  fi
  echo "$default_layout" > "$layout_f"
fi
current_layout=$(cat "$layout_f")
if [ -f "$settings_file" ]; then   # Read keyboard layout settings from Settings.conf
  kb_layout_line=$(grep 'kb_layout=' "$settings_file" | cut -d '=' -f 2)
  IFS=',' read -ra layout_mapping <<< "$kb_layout_line"
fi
layout_count=${#layout_mapping[@]}
for ((i = 0; i < layout_count; i++)); do  # Find the index of the current layout in the mapping
  if [ "$current_layout" == "${layout_mapping[i]}" ]; then
    current_index=$i
    break
  fi
done
next_index=$(( (current_index + 1) % layout_count ))  # Calculate the index of the next layout
new_layout="${layout_mapping[next_index]}"
hyprctl keyword input:kb_layout "$new_layout"   # Update the keyboard layout
echo "$new_layout" > "$layout_f"
notify-send -u low -i "$notif" "Keyboad Layout Changed to $new_layout"
}

disable_edp1() {
  enable_edp1
	sleep 1
	hyprctl keyword monitor eDP-1,disable
}
enable_edp1() {
	hyprctl keyword monitor eDP-1,preferred,auto,1
}

weather() {
    city=kohalpur
    cachedir=~/.cache/rbn
    cachefile=${0##*/}-$1

    mkdir -p $cachedir
    touch $cachedir/$cachefile

    SAVEIFS=$IFS;IFS=$'\n'
    cacheage=$(($(date +%s) - $(stat -c '%Y' "$cachedir/$cachefile")))
    [ $cacheage -gt 1740 ] || [ ! -s $cachedir/$cachefile ] && {
        data=($(curl -s https://en.wttr.in/"$city"$1\?0qnT 2>&1))
        for i in {1..2}; do echo ${data[$i]} | sed -E 's/^.{15}//' >> $cachedir/$cachefile; done
    }
    IFS=$SAVEIFS

    weather=($(cat $cachedir/$cachefile))
    temperature=$(echo ${weather[2]} | sed -E 's/([[:digit:]]+)\.\./\1 to /g')

    case $(echo ${weather[1]##*,} | tr '[:upper:]' '[:lower:]') in
        clear|sunny) condition="" ;;
        partly\ cloudy) condition="󰖕" ;;
        cloudy) condition="" ;;
        overcast) condition="" ;;
        fog|freezing\ fog) condition="" ;;
        patchy\ rain\ possible|patchy\ light\ drizzle|light\ drizzle|patchy\ light\ rain|light\ rain|light\ rain\ shower|mist|rain) condition="󰼳" ;;
        moderate\ rain\ at\ times|moderate\ rain|heavy\ rain\ at\ times|heavy\ rain|moderate\ or\ heavy\ rain\ shower|torrential\ rain\ shower|rain\ shower) condition="" ;;
        patchy\ snow\ possible|patchy\ sleet\ possible|patchy\ freezing\ drizzle\ possible|freezing\ drizzle|heavy\ freezing\ drizzle|light\ freezing\ rain|moderate\ or\ heavy\ freezing\ rain|light\ sleet|ice\ pellets|light\ sleet\ showers|moderate\ or\ heavy\ sleet\ showers) condition="󰼴" ;;
        blowing\ snow|moderate\ or\ heavy\ sleet|patchy\ light\ snow|light\ snow|light\ snow\ showers) condition="󰙿" ;;
        blizzard|patchy\ moderate\ snow|moderate\ snow|patchy\ heavy\ snow|heavy\ snow|moderate\ or\ heavy\ snow\ with\ thunder|moderate\ or\ heavy\ snow\ showers) condition="" ;;
        thundery\ outbreaks\ possible|patchy\ light\ rain\ with\ thunder|moderate\ or\ heavy\ rain\ with\ thunder|patchy\ light\ snow\ with\ thunder) condition="" ;;
        *) condition="" ;;
    esac

    echo -e "{\"text\":\""$temperature $condition"\", \"alt\":\""${weather[0]}"\", \"tooltip\":\""${weather[0]}: $temperature ${weather[1]}"\"}"
}

