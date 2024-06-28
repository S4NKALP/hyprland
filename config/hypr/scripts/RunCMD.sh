#!/bin/bash

source ~/dotfiles/hypr/scripts/Ui_cmd.sh
source ~/dotfiles/hypr/scripts/Music_cmd.sh


help() {
  declare -F
}
if [[ ! -z "$1" ]]; then
	$1 "${@:2}"
fi
