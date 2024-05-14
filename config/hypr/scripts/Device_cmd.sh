#!/bin/bash

# Source the configuration file.
CONFIG_FILE=~/dotfiles/hypr/scripts/Ref.sh
source "$CONFIG_FILE"


######################################
#                                    #
#       Toggle touchpad state        #
#                                    #
######################################

toggle_touchpad() {
  local status_file="$STATUS_FILE"
  local action

  if [[ ! -e "$status_file" ]] || ! $(<"$status_file"); then
    echo "1" > "$status_file"
    action="enabled"
  else
    echo "0" > "$status_file"
    action="disabled"
  fi

  notify-send -u low -i "$notif" "Touchpad $action"
  hyprctl keyword "device:$HYPRLAND_DEVICE:enabled" "$(cat "$status_file")"
}

######################################
#                                    #
#       Toggle wifi state            #
#                                    #
######################################

toggle_wifi() {
    wifi_status=$(nmcli radio wifi)
    if [ "$wifi_status" == "enabled" ]; then
	    nmcli radio wifi off
        notify-send -u low -i "$notif" 'Airplane mode: OFF'
    else
        nmcli radio wifi on
        notify-send -u low -i "$notif" 'Airplane mode: ON'
    fi
}

######################################
#                                    #
#       Toggle bluetooth state       #
#                                    #
######################################

toggle_bluetooth() {
    if [ "$bluetooth_status" == "no" ]; then
        bluetoothctl power on
        notify-send -u low -i "$notif" 'Bluetooth ON'
    else
        bluetoothctl power off
        notify-send -u low -i "$notif" 'Bluetooth OFF'
    fi
}

######################################
#                                    #
#        Enable/Disable Monitor      #
#                                    #
######################################

disable_edp1() {
  enable_edp1
	sleep 1
	hyprctl keyword monitor eDP-1,disable
}
enable_edp1() {
	hyprctl keyword monitor eDP-1,preferred,auto,1
}

