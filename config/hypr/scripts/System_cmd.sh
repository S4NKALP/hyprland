#!/bin/bash


# Source the configuration file.
CONFIG_FILE=~/dotfiles/hypr/scripts/Ref.sh
source "$CONFIG_FILE"

######################################
#                                    #
#       Rofi  Option for Xmenu       #
#                                    #
######################################

_confirm_rofi() {
	rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 250px;}' \
		-theme-str 'mainbox {children: [ "message", "listview" ];}' \
		-theme-str 'listview {columns: 2; lines: 1;}' \
		-theme-str 'element-text {horizontal-align: 0.5;}' \
		-theme-str 'textbox {horizontal-align: 0.5;}' \
		-kb-accept-entry 'Return,space' \
		-dmenu \
		-mesg "$1"

}
_need_confirm() {
	local _result="$(echo -e "No\nYes" | _confirm_rofi "$1")"
	if [[ "$_result" == "Yes" ]]; then
		return 0
	else
		return 1
	fi
}

######################################
#                                    #
#           Power & Reboot           #
#                                    #
######################################

sys_reboot() {
	if _need_confirm "Reboot system?"; then
		reboot
	fi
}
sys_poweroff() {
	if _need_confirm "Shutdown system?"; then
		poweroff
	fi
}

#######################################################
#                                                     #
#               Reload Waybar, Rofi, Swaync           #
#                                                     #
#######################################################
#  (SHIFT ALT R)
reload_all() {
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
}

######################################
#                                    #
#           Reload Waybar            #
#                                    #
######################################

reload_waybar() {
	_ps=(waybar rofi)
	for _prs in "${_ps[@]}"; do
		if pidof "${_prs}" >/dev/null; then
			pkill "${_prs}"
		fi
	done

	sleep 0.1
	# Relaunch waybar
	if [[ -z $1 ]]; then
		waybar &
	fi
	notify-send -u low -i $reload "Reload Waybar"

}

######################################
#                                    #
#         Reload Hyprland            #
#                                    #
######################################

reload_hypr() {
	hyprctl reload
	notify-send -u low -i $reload 'Reload Hyprland'
}

######################################
#                                    #
#       lockscreen(hyprlock)         #
#                                    #
######################################

lock_screen() {
    hyprlock
}

######################################
#                                    #
#           Battery Notifer          #
#                                    #
######################################

battery_notify() {
    PREV_STATUS="Unknown" # Initialize previous status
    FULL_CHARGE_NOTIFIED=0
    LOW_BATTERY_NOTIFIED=0

    while true; do
        STATUS=$(cat /sys/class/power_supply/AC/online 2>/dev/null)   # Get charger status using power supply directory

        if [ "$STATUS" != "$PREV_STATUS" ]; then   # Check if the charger status has changed
            FULL_CHARGE_NOTIFIED=0     # Reset full charge notification state when charger status changes
            LOW_BATTERY_NOTIFIED=0     # Reset low battery notification state when charger status changes
            PREV_STATUS="$STATUS"   # Update previous status
        fi

        # Get battery percentage and remaining time using acpi
        BATTERY_INFO=$(acpi)
        PERCENT=$(echo "$BATTERY_INFO" | awk -F ',|%' '{print $2}')

        if [ "$STATUS" == "1" ] && [ "$PERCENT" -eq 100 ] && [ "$FULL_CHARGE_NOTIFIED" -eq 0 ]; then      # Check if the battery is charging and the percentage is 100%
            notify-send -u low "🔌 Battery Fully Charged" "You can unplug the charger"        # Send a notification when the battery is fully charged
            FULL_CHARGE_NOTIFIED=1    # Set the state to indicate that the full charge notification has been sent
        fi

        if [ "$PERCENT" -le 20 ] && [ "$LOW_BATTERY_NOTIFIED" -eq 0 ]; then     # Check if the battery percentage is less than or equal to 20% and low battery notification has not been sent
            notify-send -u critical "🪫 Low Battery" "Plug in the charger"    # Send low battery notification
            LOW_BATTERY_NOTIFIED=1  # Set the state to indicate that the low battery notification has been sent
        fi
        sleep 0.1  # Sleep for some time before checking again
    done
}



######################################
#                                    #
#               Polkit               #
#                                    #
######################################

polkit_(){
    polkit=(
  "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
  "/usr/lib/polkit-kde-authentication-agent-1"
  "/usr/lib/polkit-gnome-authentication-agent-1"
  "/usr/libexec/polkit-gnome-authentication-agent-1"
  "/usr/lib/x86_64-linux-gnu/libexec/polkit-kde-authentication-agent-1"
  "/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1"
)
executed=false  # Flag to track if a file has been executed
# Loop through the list of files
for file in "${polkit[@]}"; do
  if [ -e "$file" ]; then
    echo "File $file found, executing command..."
    exec "$file"
    executed=true
    break
  fi
done
# If none of the files were found, you can add a fallback command here
if [ "$executed" == false ]; then
  echo "None of the specified files were found. Install a Polkit"
fi
}
