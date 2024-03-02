#!/bin/bash
source ~/.config/hypr/scripts/Ref.sh

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
	notify-send -u low -i $notif "Reload Waybar"
}

######################################
#                                    #
#          Update Waybar             #
#                                    #
######################################

update_waybar() {
	pkill -RTMIN+4 waybar
	notify-send -u low -i $notif 'Refresh Waybar'
}

######################################
#                                    #
#         Reload Hyprland            #
#                                    #
######################################

reload_hypr() {
	hyprctl reload
	notify-send -u low -i $notif 'Reload Hyprland'
}

######################################
#                                    #
#       lockscreen(swaylock)         #
#                                    #
######################################

lock_screen() {
	LOCKCONFIG="$HOME/.config/swaylock/config"
	sleep 0.5s
	swaylock --config ${LOCKCONFIG} &
	disown
}


######################################
#                                    #
#        Volume Controller           #
#                                    #
######################################

volume() {
    get_volume() {
        volume=$(pamixer --get-volume)
        if [[ "$volume" -eq "0" ]]; then
            echo "Muted"
        else
            echo "$volume%"
        fi
    }
    get_icon() {
        current=$(get_volume)
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
        if [[ "$(get_volume)" == "Muted" ]]; then
            notify-send -e -h string:x-canonical-private-synchronous:volume_notif -u low -i "$(get_icon)" "Volume: Muted"
        else
            notify-send -e -h int:value:"$(get_volume | sed 's/%//')" -h string:x-canonical-private-synchronous:volume_notif -u low -i "$(get_icon)" "Volume: $(get_volume)"
        fi
    }
    inc_volume() {
        if [ "$(pamixer --get-mute)" == "true" ]; then
            pamixer -u && notify_user
        fi
        pamixer -i 5 && notify_user
    }
    dec_volume() {
        if [ "$(pamixer --get-mute)" == "true" ]; then
            pamixer -u && notify_user
        fi
        pamixer -d 5 && notify_user
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
    get_mic_icon() {
        current=$(pamixer --default-source --get-volume)
        if [[ "$current" -eq "0" ]]; then
            echo "$iDIR/microphone-mute.png"
        else
            echo "$iDIR/microphone.png"
        fi
    }
    get_mic_volume() {
        volume=$(pamixer --default-source --get-volume)
        if [[ "$volume" -eq "0" ]]; then
            echo "Muted"
        else
            echo "$volume%"
        fi
    }
    notify_mic_user() {
        volume=$(get_mic_volume)
        icon=$(get_mic_icon)
        notify-send -e -h int:value:"$volume" -h "string:x-canonical-private-synchronous:volume_notif" -u low -i "$icon" "Mic-Level: $volume"
    }
    inc_mic_volume() {
        if [ "$(pamixer --default-source --get-mute)" == "true" ]; then
            pamixer --default-source -u && notify_mic_user
        fi
        pamixer --default-source -i 5 && notify_mic_user
    }
    dec_mic_volume() {
        if [ "$(pamixer --default-source --get-mute)" == "true" ]; then
            pamixer --default-source -u && notify_mic_user
        fi
        pamixer --default-source -d 5 && notify_mic_user
    }
    if [[ "$1" == "--get" ]]; then
        get_volume
    elif [[ "$1" == "--inc" ]]; then
        inc_volume
    elif [[ "$1" == "--dec" ]]; then
        dec_volume
    elif [[ "$1" == "--toggle" ]]; then
        toggle_mute
    elif [[ "$1" == "--toggle-mic" ]]; then
        toggle_mic
    elif [[ "$1" == "--get-icon" ]]; then
        get_icon
    elif [[ "$1" == "--get-mic-icon" ]]; then
        get_mic_icon
    elif [[ "$1" == "--mic-inc" ]]; then
        inc_mic_volume
    elif [[ "$1" == "--mic-dec" ]]; then
        dec_mic_volume
    else
        get_volume
    fi
}


############################################################
#                                                          #
#        Brightness Controller both keyboard & screen      #
#                                                          #
############################################################

brightness() {
notification_timeout=1000
get_backlight() {
    echo $(brightnessctl -m | cut -d, -f4)
}
get_kbd_backlight() {
    brightnessctl -d '*::kbd_backlight' -m | cut -d, -f4 | tr -d '%'
}
get_icon() {
    current=$(get_backlight | sed 's/%//')
    [ "$current" -le "20" ] && icon="$iDIR/brightness-20.png" ||
    [ "$current" -le "40" ] && icon="$iDIR/brightness-40.png" ||
    [ "$current" -le "60" ] && icon="$iDIR/brightness-60.png" ||
    [ "$current" -le "80" ] && icon="$iDIR/brightness-80.png" ||
    icon="$iDIR/brightness-100.png"
}
notify_user() {
    notify-send -e -h string:x-canonical-private-synchronous:brightness_notif -h int:value:$current -u low -i "$icon" "Brightness: $current%"
}
change_backlight() {
    brightnessctl set "$1" && get_icon && notify_user
}
change_kbd_backlight() {
    brightnessctl -d '*::kbd_backlight' set "$1" && get_icon && notify_user
}
case "$1" in
    "--get")
        get_backlight
        ;;
    "--inc")
        change_backlight "+5%"
        ;;
    "--dec")
        change_backlight "5%-"
        ;;
    "--get-kbd")
        get_kbd_backlight
        ;;
    "--inc-kbd")
        change_kbd_backlight "+30%"
        ;;
    "--dec-kbd")
        change_kbd_backlight "30%-"
        ;;
    *)
        get_backlight
        ;;
esac
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

        if [ "$STATUS" == "1" ]; then    # Send a notification when charger is plugged in or unplugged
            notify-send -u low "🔌 Charger Plugged In" "Battery charging"
        else
            notify-send -u low "🔌 Charger Unplugged" "Battery not charging"
        fi
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
