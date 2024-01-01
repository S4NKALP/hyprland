#!/usr/bin/env bash
# Scripts for refreshing waybar, rofi, swaync

SCRIPTSDIR=$HOME/.config/hypr/scripts
UserSCRIPTSDIR=$HOME/.config/hypr/UserScripts

# Define file_exists function
file_exists() {
    if [ -e "$1" ]; then
        return 0  # File exists
    else
        return 1  # File does not exist
    fi
}

# Kill already running processes
_ps=(waybar rofi swaync)
for _prs in "${_ps[@]}"; do
    if pidof "${_prs}" >/dev/null; then
        pkill "${_prs}"
    fi
done

sleep 0.3
# Relaunch waybar
waybar &

# relaunch swaync
sleep 0.5
swaync > /dev/null 2>&1 &

# Relaunching rainbow borders if the script exists
sleep 1
if file_exists "${UserSCRIPTSDIR}/RainbowBorders.sh"; then
    ${UserSCRIPTSDIR}/RainbowBorders.sh &
fi


exit 0
