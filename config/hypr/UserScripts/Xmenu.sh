#!/bin/bash

# Directory for icons
iDIR="$HOME/.config/swaync/icons"
scriptsDir="$HOME/.config/hypr/scripts"
UserScripts="$HOME/.config/hypr/UserScripts"
yes='Yes'
no='No'
# Note: You can add more options below with the following format:
# ["TITLE"]="link"

# Define menu options as an associative array
declare -A menu_options=(
	["nv Neovim"]="kitty -e nvim"
	["re RofiEmoji"]="$scriptsDir/RofiEmoji.sh"
	["rn RofiNotes"]="$scriptsDir/RofiNotes.sh"
	["rs TmuxSesions"]="$scriptsDir/RofiTmuxSesions.sh"
	["rt RofiTodo"]="rofi -modi TODO:$scriptsDir/RofiTodo.sh -show TODO"
	["ws WallpaperSelect"]="$UserScripts/WallpaperSelect.sh"
	["wb ToggleWaybar"]="killall -SIGUSR1 waybar"
	["wl WaybarLayout"]="$scriptsDir/WaybarLayout.sh"
	["gm GameMode"]="$scriptsDir/ToggleAnimation -t"
	["rm RofiMusic"]="$UserScripts/RofiMusic.sh"
	["cb ChangeBlur"]="$scriptsDir/ChangeBlur.sh"
	["po Shutdown"]="needConfim "poweroff""
	["rr Reboot"]="needConfim "reboot""
	["pm PowerMenu"]="$scriptsDir/RofiPower.sh"
	["rfs Refesh All"]="$scriptsDir/Refresh.sh"
	["cc Calculator"]="rofi -modi \"calc:$scriptsDir/RofiCalc.sh\" -show calc"
	["fd Finder"]="rofi -modi \"find:$scriptsDir/Finder.sh\" -show find"
	["cb Clipborad"]="$scriptsDirt/ClipManager.sh"
	["flt Float all window"]="hyprctl dispatch workspaceopt allfloat"
	["; Launcher"]="rofi -show drun -modi drun,filebrowser,run,window -config ~/.config/rofi/launcher.rasi"
	["ff firefox"]="firefox"
	["fp firefox"]="firefox --private-window"
        ["qe QuickEdit"]="$UserScripts/QuickEdit.sh"
        ["tp Touchpad"]="$UserScripts/TouchPad.sh"
        ["yz Yazi"]="kitty -e yazi"
        ["ds Discord"]="discord"
        ["tg Telegram"]="telegram-desktop"
        ["fz FuzzyFind"]="kitty fzf -e"
        ["tn TermianlNote"]="kitty -e notes"

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
			rofi -dmenu -config ~/.config/rofi/config.rasi \
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
