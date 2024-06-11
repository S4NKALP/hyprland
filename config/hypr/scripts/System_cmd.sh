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
sys_lock() {
    if _need_confirm "Lock screen?"; then
        pidof hyprlock || hyprlock -q
    fi
}
sys_logout() {
    if _need_confirm "Logout?"; then
        loginctl kill-session $XDG_SESSION_ID
    fi
}
sys_suspend() {
    if _need_confirm "Suspend system?"; then
        systemctl suspend
    fi
}
sys_hibernate() {
    if _need_confirm "Hibernate system?"; then
        systemctl hibernate
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

    processes=("waybar" "rofi" "swaync" "ags")

    for process in "${processes[@]}"; do
        pid=$(pidof "$process")
        if [ -n "$pid" ]; then
            pkill "$process"
        fi
    done

    sleep 0.3
    ags &
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

        if [ "$PERCENT" -le 40 ] && [ "$LOW_BATTERY_NOTIFIED" -eq 0 ]; then     # Check if the battery percentage is less than or equal to 20% and low battery notification has not been sent
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


######################################
#                                                                                          #
#                        Power Profile Daemon                         #
#                                                                                          #
######################################

power_profile() {
    get_pwr() {
        PWR=$(powerprofilesctl get)
    }

    get_pwr

    if [[ "$PWR" == "balanced" ]]; then
        text="󰾅"
        tooltip="Balanced"
    elif [[ "$PWR" == "performance" ]]; then
        text="󰓅"
        tooltip="Performance"
    elif [[ "$PWR" == "power-saver" ]]; then
        text="󰾆"
        tooltip="Power Saver"
    fi

    echo '{"text": "'$text'", "tooltip": "'$tooltip'"}'

    if [[ "$1" == "next" ]]; then
        current=$(powerprofilesctl get)
        if [[ "$current" == "balanced" ]]; then
            next="performance"
        elif [[ "$current" == "performance" ]]; then
            next="power-saver"
        elif [[ "$current" == "power-saver" ]]; then
            next="balanced"
        fi
        powerprofilesctl set "$next"
        pkill -SIGRTMIN+8 waybar
        get_pwr
        notify-send -h string:x-canonical-private-synchronous:sys-notify -u low "Power Profile changed to $PWR"
    fi
}

######################################
#                                                                                          #
#                                     SymLink                                      #
#                                                                                          #
######################################

symlink() {
    # Define cache directory
    cache_dir="$HOME/.cache/swww/"

    # Get a list of monitor outputs
    monitor_outputs=($(ls "$cache_dir"))

    # Initialize variables
    ln_success=false
    current_monitor=$(hyprctl monitors | awk '/^Monitor/{name=$2} /focused: yes/{print name}')
    echo $current_monitor
    cache_file="$cache_dir$current_monitor"
    echo $cache_file

    if [ -f "$cache_file" ]; then
        # Read wallpaper path from cache file
        wallpaper_path=$(cat "$cache_file")
        echo $wallpaper_path

        # Symlink wallpaper to the location accessible by Rofi
        if ln -sf "$wallpaper_path" "$HOME/dotfiles/hypr/wallpaper_effects/.wallpaper_current"; then
            ln_success=true  # Set the flag to true upon successful execution
        fi

        # Copy the wallpaper for wallpaper effects (optional)
        # cp -r "$wallpaper_path" "$HOME/.config/hypr/wallpaper_effects/.wallpaper_current"
    fi

    # Check if symlink was successful
    if [ "$ln_success" = true ]; then
        echo 'Symlink successful'
    fi
}

######################################
#                                                                                           #
#                                   Wallpaper Effect                         #
#                                                                                         #
######################################


apply_wallpaper_effects() {
    current_wallpaper="$HOME/dotfiles/hypr/wallpaper_effects/.wallpaper_current"
    wallpaper_output="$HOME/dotfiles/hypr/wallpaper_effects/.wallpaper_modified"
    focused_monitor=$(hyprctl monitors | awk '/^Monitor/{name=$2} /focused: yes/{print name}')
    iDIR="$HOME/dotfiles/hypr/assets/"
    SWWW_PARAMS="--transition-fps 60 --transition-type wipe --transition-duration 2"

    declare -A effects=(
        ["Black & White"]="magick $current_wallpaper -colorspace gray -sigmoidal-contrast 10,40% $wallpaper_output"
        ["Blurred"]="magick $current_wallpaper -blur 0x5 $wallpaper_output"
        ["Solarize"]="magick $current_wallpaper -solarize 80% $wallpaper_output"
        ["Sepia Tone"]="magick $current_wallpaper -sepia-tone 65% $wallpaper_output"
        ["Negate"]="magick $current_wallpaper -negate $wallpaper_output"
        ["Charcoal"]="magick $current_wallpaper -charcoal 0x5 $wallpaper_output"
        ["Edge Detect"]="magick $current_wallpaper -edge 1 $wallpaper_output"
        ["Emboss"]="magick $current_wallpaper -emboss 0x5 $wallpaper_output"
        ["Sharpen"]="magick $current_wallpaper -sharpen 0x5 $wallpaper_output"
        ["Oil Paint"]="magick $current_wallpaper -paint 4 $wallpaper_output"
        ["Vignette"]="magick $current_wallpaper -vignette 0x5 $wallpaper_output"
        ["Posterize"]="magick $current_wallpaper -posterize 4 $wallpaper_output"
        ["Polaroid"]="magick $current_wallpaper -polaroid 0 $wallpaper_output"
        ["No Effects"]="no-effects"
    )

    no_effects() {
        swww img -o "$focused_monitor" "$current_wallpaper" $SWWW_PARAMS &
        wait $!
        notify-send -u low -i "$iDIR/bell.png" "No wallpaper effects"
        cp $current_wallpaper $wallpaper_output
    }

    main() {
        options="No Effects"
        for effect in "${!effects[@]}"; do
            if [ "$effect" != "No Effects" ]; then
                options+="\n$effect"
            fi
        done

        choice=$(echo -e "$options" | rofi -i -dmenu)
        if [[ -n "$choice" && "${effects[$choice]+exists}" ]]; then
            if [ "$choice" == "No Effects" ]; then
                no_effects
            else
                notify-send -u normal -i "$iDIR/bell.png" "Applying $choice effects"
                eval "${effects[$choice]}"
                sleep 1
                swww img -o "$focused_monitor" "$wallpaper_output" $SWWW_PARAMS &
                wait $!
                notify-send -u low -i "$iDIR/bell.png" "$choice effects applied"
            fi
        else
            echo "Effects not recognized."
        fi
    }

    if pidof rofi > /dev/null; then
        pkill rofi
        exit 0
    fi

    main
}
