#!/bin/bash
source ~/.config/hypr/scripts/Ref.sh


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

# Reload Waybar, Rofi, Swaync, and Rainbowborder.sh (SHIFT ALT R)
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
	$notif "Reload Waybar"
}

update_waybar() {
	pkill -RTMIN+4 waybar
	notify-send -u low -i $notif 'Refresh Waybar'
}
reload_hypr() {
	hyprctl reload
	notify-send -u low -i $notif 'Reload Hyprland'
}
lock_screen() {
	LOCKCONFIG="$HOME/.config/swaylock/config"
	sleep 0.5s
	swaylock --config ${LOCKCONFIG} &
	disown
}


# Volume Controller
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


# ScreenShot
screenshot() {
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
        for ((sec = $1; sec > 0; sec--)); do
            notify-send -h string:x-canonical-private-synchronous:shot-notify -t 1000 -i "$iDIR"/timer.png "Taking shot in: $sec"
            sleep 1
        done
    }

    take_shot() {
        cd "${dir}" && grim - | tee "$file" | wl-copy
        sleep 2
        notify_view "$1"
    }

    shotnow() { take_shot; }
    shot_timer() { countdown "$1"; sleep 1 && take_shot; }
    shot5() { shot_timer 5; }
    shot10() { shot_timer 10; }

    shotarea() {
        tmpfile=$(mktemp)
        area="$(slurp)"

        [[ -z "$area" ]] && { notify-send -u low -i "$iDIR/picture.png"  'No area selected'; rm; "$tmpfile": return;}
        grim -g "$area" - > "$tmpfile" && [[ -s "$tmpfile" ]] && {
        wl-copy < "$tmpfile"
        mv "$tmpfile" "$dir/Screenshot_$(date '+%d-%b_%H-%M-%S')_${RANDOM}.png"
        notify_view
    }
        rm "$tmpfile"
    }

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
}


# Brightness Controller
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

battery_notify() {
last="NONE" # Possible values: NONE, FULL, LOW, CRITICAL, CHARGING
# Default values for LOW/CRITICAL status
low=40
critical=20

while true; do
  # If battery is plugged, do stuff
  battery="/sys/class/power_supply/BAT0"
  if [ -d $battery ]; then
    capacity=$(cat $battery/capacity)
    status=$(cat $battery/status)

    # If battery full and not already warned about that
    if [ "$last" != "FULL" ] && [ "$status" = "Full" ]; then
      notify-send -u normal -i "$iDIR/battery-full.png" "Battery full" "Remove the adapter! $capacity%"
      last="FULL"
    fi

    # If low and discharging
    if [ "$last" != "LOW" ] && [ "$status" = "Discharging" ] && [ $capacity -le $low ]; then
      notify-send -u normal -i "$iDIR/battery-low.png" "Battery low" "Plug in the adapter! $capacity%"
      last="LOW"
    fi

    # If critical and discharging
    if [ "$status" = "Discharging" ] && [ $capacity -le $critical ]; then
      notify-send -u critical -i "$iDIR/battery-low.png" "Battery very low" "Plug in the adapter!!! $capacity%"
      last="CRITICAL"
    fi

    # If charging and not already notified
    if [ "$last" != "CHARGING" ] && [ "$status" = "Charging" ]; then
      notify-send -u low -i "$iDIR/battery-charging.png" "Charger connected" "Battery is charging $capacity%"
      last="CHARGING"
    fi

        # If unplugged and not already notified
    if [ "$last" != "UNPLUGGED" ] && [ "$status" = "Discharging" ] && [ "$capacity" != "Full" ]; then
      notify-send -u normal -i "$iDIR/battery-notcharging.png" "Charger unplugged" "Battery is not charging! $capacity%"
      last="UNPLUGGED"
    fi
  fi
  sleep 0.1
done

}
