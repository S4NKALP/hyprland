#!/bin/bash
#
theme=~/.config/rofi/config-todo.rasi

rofi -modi TODO:$HOME/.config/hypr/scripts/TodoList.sh -show TODO -theme $theme

exit 0
