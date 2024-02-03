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
toggle_bluetooth() {
    if [ "$bluetooth_status" == "no" ]; then
        bluetoothctl power on
        notify-send -u low -i "$notif" 'Bluetooth ON'
    else
        bluetoothctl power off
        notify-send -u low -i "$notif" 'Bluetooth OFF'
    fi
}

disable_edp1() {
  enable_edp1
	sleep 1
	hyprctl keyword monitor eDP-1,disable
}
enable_edp1() {
	hyprctl keyword monitor eDP-1,preferred,auto,1
}

