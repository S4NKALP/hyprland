#!/bin/bash

# Source the configuration file.
CONFIG_FILE=~/dotfiles/hypr/scripts/Ref.sh
source "$CONFIG_FILE"

# Note: You can add more options below with the following format:
# ["TITLE"]="link"

# Define menu options as an associative array
declare -A menu_options=(

	#waybar
	["wbt ToggleWaybar"]="killall -SIGUSR1 waybar"
	#["wbl WaybarLayout"]="$RunCMD waybar_layout"
        ["wbr Reload Waybar"]="$RunCMD reload_waybar"
	["wbu Update Waybar"]="$RunCMD update_waybar"
  #hypr
	["hpr Reload hyprland"]="$RunCMD reload_hypr"
        ["rld Reload All"]="$RunCMD reload_all"
        ["cl ChangeLayout"]="$RunCMD change_layout"
	["gm GameMode"]="$RunCMD gamemode"
	["bl ChangeBlur"]="$RunCMD toggle_blur"
	["flt Float all window"]="hyprctl dispatch workspaceopt allfloat"
        ["hpa Toggle hyprland animation"]="$RunCMD toggle_animation"
        ["op1 enable_opaque"]="$RunCMD enable_opaque"
	["op0 disable_opaque"]="$RunCMD disable_opaque"
  #wallpaper
        ["ws Wallpaper Select"]="$RunCMD select_wall"
        ["wc Random Wallpaper"]="$RunCMD random_wall"
  #RunCMD
	["; Launcher"]="rofi -show drun -modi drun,filebrowser,run,window"
        ["cb Clipboard"]="$RunCMD clip"
        ["rm Music"]="$RunCMD music -m"
	["emj Emoji"]="$RunCMD emoji"
        ["kb Kebinds"]="$RunCMD KeyHints.sh"
        ["qe QuickEdits"]="$RunCMD edit"
  #System
	["qq Shutdown"]="$RunCMD sys_poweroff"
	["rr Reboot"]="$RunCMD sys_reboot"
	["lk Lock"]="$RunCMD sys_lock"
	["lo LogOut"]="$RunCMD sys_logout"
        ["sp Suspend"]="$RunCMD sys_suspend"
        ["hb Hibernate"]="$RunCMD sys_hibernate"
	["cn Close Notifactions"]="swaync-client -C"
	["dm0 disable monitor"]="$RunCMD disable_edp1"
	["dm1 enable monitor"]="$RunCMD enable_edp1"
        ["tt Touchpad"]="$RunCMD toggle_touchpad"
        ["tbt Bluetooth"]="$RunCMD toggle_bluetooth"
        ["tw Wifi"]="$RunCMD totggle_wifi"
        ["kb Keyboard switcher"]="$RunCMD kb_changer"
  #Misc
	["ff Firefox"]="firefox"
	["ffp Firefox"]="firefox --private-window"
        ["vi Nvim"]="pypr toggle nvim"
        ["yz Yazi"]="pypr toggle yazi"
        ["tg Telegram"]="telegram-desktop"
)

# Main function
main() {
	choice=$(
		printf "%s\n" "${!menu_options[@]}" |
			rofi -dmenu \
				-p "Rofi" \
				-mesg "Hello" \
				-max-history-size 0 \
				-auto-select


	)

	if [ -z "$choice" ]; then
		exit 1
	fi

	link="${menu_options[$choice]}"
	$link
}

main
