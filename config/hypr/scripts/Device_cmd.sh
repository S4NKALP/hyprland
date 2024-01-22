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
    wifi="$(nmcli r wifi | awk 'FNR = 2 {print $1}')"
    if [ -n "$wifi" ]; then
        rfkill block all &
        notify-send -u low -i "$notif" 'Airplane mode: OFF'
    else
        rfkill unblock all &
        notify-send -u low -i "$notif" 'Airplane mode: ON'
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
