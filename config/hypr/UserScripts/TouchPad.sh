#!/bin/bash

# For disabling touchpad.

notif="$HOME/.config/swaync/images/bell.png"

# NOTE: find the right device using hyprctl devices

HYPRLAND_DEVICE="dll07a7:01-044e:120b"

XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
STATUS_FILE="$XDG_RUNTIME_DIR/touchpad.status"

toggle_touchpad() {
  if [ ! -f "$STATUS_FILE" ] || [ "$(cat "$STATUS_FILE")" = "false" ]; then
    echo "true" > "$STATUS_FILE"
    action="enabled"
  else
    echo "false" > "$STATUS_FILE"
    action="disabled"
  fi

  notify-send -u low -i "$notif" "Touchpad $action"
  hyprctl keyword "device:$HYPRLAND_DEVICE:enabled" "$(cat "$STATUS_FILE")"
}

toggle_touchpad
