#!/usr/bin/env bash

# Source the configuration file.
CONFIG_FILE=~/.config/hypr/scripts/Ref.sh
source "$CONFIG_FILE"

panel(){
# Theme Elements
prompt='Panel'

list_col='2'
list_row='2'
win_width='450px'

# Options
bluetooth_status=$(bluetoothctl show | awk '/Powered:/ {print $2}')
bluetooth_icon=""
[ "$bluetooth_status" = "yes" ] && bluetooth_icon=""

wifi_status=$(nmcli radio wifi)
wifi_icon=""
[ "$wifi_status" = "enabled" ] && wifi_icon=""

layout=$(grep 'USE_ICON' "$theme" | cut -d'=' -f2)
if [[ "$layout" == 'NO' ]]; then
  option_1=""
  option_2=""
  option_3=""
  option_4=""
else
  option_1="  ${wifi_icon}" # Wifi
  option_2=" ⏸"               # Play pause
  option_3=" ${bluetooth_icon}" # Bluetooth
  option_4=""                   # Settings
fi

# Rofi CMD
rofi_cmd() {
  rofi -theme-str "window {width: $win_width;}" \
       -theme-str "listview {columns: $list_col; lines: $list_row;}" \
       -theme-str 'textbox-prompt-colon {str: " ";}' \
       -dmenu -p "$prompt" -markup-rows -theme "$theme" -hover-select
}

# Pass variables to rofi dmenu
run_rofi() {
  echo -e "$option_1\n$option_2\n$option_3\n$option_4" | rofi_cmd
}

# Execute Command
run_cmd() {
  case $1 in
    '--opt1') $SCRIPTSDIR/RunCMD.sh wifi ;;
    '--opt2') playerctl play-pause ;;
    '--opt3') $SCRIPTSDIR/RunCMD.sh bluetooth ;;
    '--opt4') $SCRIPTSDIR/RunCMD.sh panelsetting ;;
  esac
}

# Actions
chosen=$(run_rofi)
case $chosen in
  $option_1) run_cmd --opt1 ;;
  $option_2) run_cmd --opt2 ;;
  $option_3) run_cmd --opt3 ;;
  $option_4) run_cmd --opt4 ;;
esac
}

panelsetting(){
# Theme Elements
prompt='Panel Settings'


list_col='2'
list_row='2'
win_width='450px'

# Options

layout=`cat ${theme} | grep 'USE_ICON' | cut -d'=' -f2`
if [[ "$layout" == 'NO' ]]; then
	option_1=""
	option_2=""
	option_3=""
	option_4=""
else
	option_1="" # Wifi
	option_2="" # Back
	option_3="" # Bluetooth
	option_4="" # Hyprconf
fi

# Rofi CMD
rofi_cmd() {
	rofi \
		-theme-str "window {width: $win_width;}" \
		-theme-str "listview {columns: $list_col; lines: $list_row;}" \
		-theme-str 'textbox-prompt-colon {str: " ";}' \
		-dmenu \
		-p "$prompt" \
		-markup-rows \
		-theme ${theme} \
		-hover-select
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$option_1\n$option_2\n$option_3\n$option_4" | rofi_cmd
}

# Execute Command
run_cmd() {
	if [[ "$1" == '--opt1' ]]; then
		kitty nmtui
	elif [[ "$1" == '--opt2' ]]; then
		$SCRIPTSDIR/RunCMD.sh panel
	elif [[ "$1" == '--opt3' ]]; then
		blueberry
	elif [[ "$1" == '--opt4' ]]; then
		$SCRIPTSDIR/RunCMD.sh edit
	fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $option_1)
		run_cmd --opt1
        ;;
    $option_2)
		run_cmd --opt2
        ;;
    $option_3)
		run_cmd --opt3
        ;;
    $option_4)
		run_cmd --opt4
        ;;
esac
}
