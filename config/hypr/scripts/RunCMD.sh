#!/bin/bash

source ~/.config/hypr/scripts/Ui_cmd.sh
source ~/.config/hypr/scripts/Device_cmd.sh
source ~/.config/hypr/scripts/Rofi_cmd.sh
source ~/.config/hypr/scripts/System_cmd.sh
source ~/.config/hypr/scripts/Music_cmd.sh

help() {
  declare -F
}
if [[ ! -z "$1" ]]; then
	$1 "${@:2}"
fi
