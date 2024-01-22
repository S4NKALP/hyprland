#!/bin/bash

# Directory for icons
iDIR="$HOME/.config/swaync/icons"
scriptsDir="$HOME/.config/hypr/scripts"
RunCMD="$scriptsDir/RunCMD.sh"
yes='Yes'
no='No'
# Note: You can add more options below with the following format:
# ["TITLE"]="link"

# Define menu options as an associative array
declare -A menu_options=(


	#waybar
	["wbt ToggleWaybar"]="killall -SIGUSR1 waybar"
	["wbl WaybarLayout"]="$RunCMD waybarl"
  #hypr
	["hpr Reload hyprland"]="hyprctl reload"
        ["cl ChangeLayout"]="$RunCMD layout"
	["rld Reload All"]="$RunCMD reload"
	["gm GameMode"]="$RunCMD gamemode"
	["bl ChangeBlur"]="$RunCMD blur"
	["flt Float all window"]="hyprctl dispatch workspaceopt allfloat"
  #wallpaper
        ["ws Wallpaper Select"]="$RunCMD selectwall"
        ["wc Random Wallpaper"]="$RunCMD randomwall"
  #RunCMD
	["; Launcher"]="rofi -show drun -modi drun,filebrowser,run,window -theme $HOME/.config/rofi/launcher.rasi"
        ["cb Clipboard"]="$RunCMD clip"
        ["rm RunCMDMusic"]="$scriptsDir/Music_cmd.sh -m"
	["emj RunCMDEmoji"]="$scriptsDir/Emoji.sh"
	["cc Calculator"]="$RunCMD calc"
        ["td Todo"]="$RunCMD todo"
        ["tx Tmux"]="$RunCMD tmux"
        ["nt Note"]="$RunCMD note"
        ["kb Kebinds"]="$RunCMD keybind"
        ["qe Edits"]="$RunCMD edit"
  #System
	["QQ Shutdown"]="needConfim "poweroff""
	["RR Reboot"]="needConfim "reboot""
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

# Function for displaying notifications
notification() {
	notify-send -e -u low "$@"
}

confirm_cmd() {
	rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 250px;}' \
		-theme-str 'mainbox {children: [ "message", "listview" ];}' \
		-theme-str 'listview {columns: 2; lines: 1;}' \
		-theme-str 'element-text {horizontal-align: 0.5;}' \
		-theme-str 'textbox {horizontal-align: 0.5;}' \
		-kb-accept-entry 'Return,space' \
		-dmenu \
		-p 'Confirmation' \
		-mesg 'Are you Sure?'
	# -theme ${dir}/${theme}.rasi
}

# Ask for confirmation
confirm_exit() {
	echo -e "$no\n$yes" | confirm_cmd
}
needConfim() {
	selected="$(confirm_exit)"
	if [[ "$selected" == "$yes" ]]; then
		$1
	fi
}
# myt="$(notification number)"
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
	# notification "$choice"
	# test_cmd
}

main
