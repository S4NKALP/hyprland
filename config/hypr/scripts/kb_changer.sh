#!/bin/bash

layout_f="$HOME/.cache/kb_layout"
settings_file="$HOME/dotfiles/hypr/UserConfigs/UserSettings.conf"
current_layout=$(cat "$layout_f")

[ -f "$settings_file" ] && IFS=',' read -ra layout_mapping <<<"$(grep 'kb_layout=' "$settings_file" | cut -d '=' -f 2)"

for i in "${!layout_mapping[@]}"; do
	[ "$current_layout" == "${layout_mapping[i]}" ] && new_layout="${layout_mapping[((i + 1) % ${#layout_mapping[@]})]}" && break
done

hyprctl switchxkblayout "at-translated-set-2-keyboard" "$new_layout" && echo "$new_layout" >"$layout_f"

hyprctl devices -j | jq -r '.keyboards[].name' | while read -r name; do
	hyprctl switchxkblayout "$name" next || {
		notify-send -u low -t 2000 'Keyboard layout' 'Error: Layout change failed'
		exit 1
	}
done

notify-send -u low "Kb_layout" "Changed"
