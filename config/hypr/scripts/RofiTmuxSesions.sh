#!/bin/bash

function tmux_sessions() {
    tmux list-sessions | sed 's/: /| /' | column -t -s'|' -o' | '
}

ROFI_THEME="$HOME/.config/rofi/config.rasi"
ADD="  Add new session"
DELETE="󰆴  Delete a session"
QUIT="󰗼  Quit"

TMUX_SESSION=$(
    (printf "%s\n" "$ADD" "$DELETE" "$QUIT"; tmux_sessions) |
        rofi -theme "$ROFI_THEME" -dmenu -p "   Tmux" -no-show-icons
)

if [[ "$ADD" = "$TMUX_SESSION" ]]; then
    kitty -e tmux new-session &
elif [[ "$DELETE" = "$TMUX_SESSION" ]]; then
    SESSION_TO_DELETE=$(tmux_sessions | rofi -dmenu -p "Select session to delete" | awk '{print $1}')
    [ -n "$SESSION_TO_DELETE" ] && tmux kill-session -t "$SESSION_TO_DELETE"
elif [[ "$QUIT" = "$TMUX_SESSION" ]]; then
    exit
elif [[ -n "$TMUX_SESSION" ]]; then
    SESSION=$(echo "$TMUX_SESSION" | cut -d\  -f1)
    kitty -e tmux attach -t "$SESSION" &
fi
