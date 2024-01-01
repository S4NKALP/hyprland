#! /usr/bin/env bash

# Control Tmux Session using rofi

TERMINAL="kitty"

function tmux_sessions() {
    tmux list-session -F '#S'
}

theme=~/.config/rofi/config-tmux.rasi

TMUX_SESSION=$( (echo new; tmux_sessions) | rofi -dmenu -p "󰆍  Tmux" -theme $theme)

if [[ x"new" = x"${TMUX_SESSION}" ]]; then
    $TERMINAL -e tmux new-session &
	exit 0
elif [[ -z "${TMUX_SESSION}" ]]; then
    exit 1
else
    $TERMINAL -e tmux attach -t "${TMUX_SESSION}" &
	exit 0
fi
