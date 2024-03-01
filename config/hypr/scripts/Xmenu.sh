#!/bin/bash

# Source the configuration file.
CONFIG_FILE=~/.config/hypr/scripts/Ref.sh
source "$CONFIG_FILE"

# Note: You can add more options below with the following format:
# ["TITLE"]="link"

# Define menu options as an associative array
declare -A menu_options=(

	#waybar
	["wbt ToggleWaybar"]="killall -SIGUSR1 waybar"
	["wbl WaybarLayout"]="$RunCMD waybar_layout"
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
	["; Launcher"]="rofi -show drun -modi drun,filebrowser,run,window -theme $HOME/.config/rofi/launcher.rasi"
        ["cb Clipboard"]="$RunCMD clip"
        ["rm RunCMDMusic"]="$RunCMD music -m"
	["emj RunCMDEmoji"]="$RunCMD emoji"
	["cc Calculator"]="$RunCMD calc"
        ["tx Tmux"]="$RunCMD tmux"
        ["kb Kebinds"]="$RunCMD keybind"
        ["qe Edits"]="$RunCMD edit"
  #System
	["qq Shutdown"]="$RunCMD sys_poweroff"
	["rr Reboot"]="$RunCMD sys_reboot"
	["pm Powermenu"]="$RunCMD powermenu"
	["cn Close Notifactions"]="swaync-client -C"
	["dm0 disable monitor"]="$RunCMD disable_edp1"
	["dm1 enable monitor"]="$RunCMD enable_edp1"
        ["tt Touchpad"]="$RunCMD toggle_touchpad"
        ["tbt Bluetooth"]="$RunCMD toggle_bluetooth"
        ["tw Wifi"]="$RunCMD toggle_wifi"
        ["kb Keyboard switcher"]="$RunCMD kb_changer"
        ["bt Bluetooth"]="$RunCMD bluetooth"
  #Misc
	["ff Firefox"]="firefox"
	["ffp Firefox"]="firefox --private-window"
        ["sr ScreenRecord"]="$RunCMD sr"
	["lg Lazygit"]="kitty lazygit"
        ["vi Nvim"]="kitty nvim"
        ["yz Yazi"]="kitty yazi"
        ["cd Codium"]="codium --disable-gpu"
)

# Main function
main() {
	choice=$(
		printf "%s\n" "${!menu_options[@]}" |
			rofi -dmenu -config ~/.config/rofi/config-long.rasi \
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
