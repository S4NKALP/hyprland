#!/bin/bash

# Directory for icons
iDIR="$HOME/.config/swaync/icons"
scriptsDir="$HOME/.config/hypr/scripts"
RunCMD="$scriptsDir/RunCMD.sh"
# Note: You can add more options below with the following format:
# ["TITLE"]="link"

# Define menu options as an associative array
declare -A menu_options=(


	#waybar
	["wbt ToggleWaybar"]="killall -SIGUSR1 waybar"
	["wbl WaybarLayout"]="$RunCMD waybarl"
        ["wbr Reload Waybar"]="$RunCMD reload_waybar"
	["wbu Update Waybar"]="$RunCMD update_waybar"
  #hypr
	["hpr Reload hyprland"]="$RunCMD reload_hypr"
        ["rld Reload All"]="$RunCMD reloadall"
        ["cl ChangeLayout"]="$RunCMD layout"
	["gm GameMode"]="$RunCMD gamemode"
	["bl ChangeBlur"]="$RunCMD blur"
	["flt Float all window"]="hyprctl dispatch workspaceopt allfloat"
        ["hpa Toggle hyprland animation"]="$RunCMD animation"
        ["op1 enable_opaque"]="$RunCMD enable_opaque"
	["op0 disable_opaque"]="$RunCMD disable_opaque"
  #wallpaper
        ["ws Wallpaper Select"]="$RunCMD selectwall"
        ["wc Random Wallpaper"]="$RunCMD randomwall"
  #RunCMD
	["; Launcher"]="rofi -show drun -modi drun,filebrowser,run,window -theme $HOME/.config/rofi/launcher.rasi"
        ["cb Clipboard"]="$RunCMD clip"
        ["rmc RunCMDMusic"]="$RunCMD music -m"
	["emj RunCMDEmoji"]="$RunCMD emoji"
	["cc Calculator"]="$RunCMD calc"
        ["td Todo"]="$RunCMD todo"
        ["tx Tmux"]="$RunCMD tmux"
        ["nt Note"]="$RunCMD note"
        ["kb Kebinds"]="$RunCMD keybind"
        ["qe Edits"]="$RunCMD edit"
  #System
	["qq Shutdown"]="$RunCMD sys_poweroff"
	["rr Reboot"]="$RunCMD sys_reboot"
	["pm Powermenu"]="$RunCMD powermenu"
	["cn Close Notifactions"]="swaync-client -C"
	["dm0"]="$RunCMD enable_edp1"
	["dm1"]="$RunCMD enable_edp1"
        ["tt Touchpad"]="$RunCMD touchpad"
        ["tw Wifi"]="$RunCMD wifi"
        ["kb Keyboard switcher"]="$RunCMD kb"
  #Misc
	["ff Firefox"]="firefox"
        ["sr ScreenRecord"]="$RunCMD sr"
	["lg Lazygit"]="kitty lazygit"
        ["vi Nvim"]="kitty nvim"
        ["yz Yazi"]="kitty yazi"
        ["cd Codium"]="codium"
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
