#!/bin/bash


 yad --width=850 --height=950 \
    --center \
    --title="Keybindings" \
    --no-buttons \
    --list \
    --column=Key: \
    --column=Description: \
    --column=Command: \
"ESC" "close this app" "" "=" "SUPER KEY" "(SUPER KEY)" \
" ENTER" "Terminal" "(kitty)" \
"ALT ENTeR" "FullScreen Terminal" "(all_kitty)" \
"ALT SHIFT enter" "Float Terminal" "(kitty_float)" \
" D" "App Launcher" "(rofi)" \
" "  "App Launcher" "(rofi)" \
" E" "Open File Manager" "(Thunar)" \
" C" "close focused app" "(kill)" \
" SHIFT W" "Wallpaper Select" "(swww)" \
"ALT SHIFT W" "Random Wallpaper" "(swww)" \
"CTRL E" "RofiEmoji" "" \
" N" "ROfiNotes" "" \
" T" "RofiTmux" "" \
"ALT M" "RofiMusic" "" \
"  SHIFT T" "RofiTodo" ""\
"ALT S" "Stop" "(ROfi Music)" \
"ALT N" "Next track" "(ROfi Music)" \
"ALT P" "Previous Track" "(ROfi Music)" \
"ALT R" "Resume" "(ROfi Music)" \
"ALT W" "Choose waybar layout" "(waybar layout)" \
"PRINT" "screenshot now" "(grim)" \
" Z" "screenshot area" "(grim + slurp)" \
"CTRL PRINT" "screenshot win" "(grim)" \
" X" "power-menu" "(rofi)" \
"CTRL ALT Del" "Hyprland Exit" "(SAVE YOUR WORK!!!)" \
" SHIFT SPACE" "Fullscreen" "(Toggles to full screen)" \
" A" "Toggle Dwindle | Master Layout" "(Hyprland Layout)" \
" P" "Toggle Dwindle" "(Pseudo)" \
" F" "Toggle float" "(single window)" \
" SHIFT F" "Toggle all windows to float" "(all windows)" \
"CTRL 1" "cava" "(fly_is_kitty)" \
"CTRL 2" "donut" "(donut_is_kitty)" \
"CTRL 3" "tty-clock" "(clock_is_kitty)" \
" SHIFT A" "All animations off" "" \
" Shift Q" "Toggle Blur" "normal or less blur" \
" R" "Record Screen" "(wf-recorder)" \
" SHIFT R" "Stop Recording" "" \
" SHIFT O" "Opaque" "" \
" G" "Toggle Group" "" \
" U" "Toggle Special Workspace" "" \
" SHIFT U" "Move Toward Special" "" \
" F1" "Launch this app" "" \
"ALT E" "View or EDIT Keybinds, Settings, Monitor" "" \
"" "" "" \
"" "For other you can find in ~/.config/hypr/configs/keybind.conf" ""\

