#!/usr/bin/env bash


# Import Theme
theme="$HOME/.config/rofi/config-quicklink.rasi"

# Theme Elements
prompt="Quick Links: Using '$BROWSER' as web browser"

# Check if the theme variable is not empty
if [ -n "$theme" ]; then
    list_col='6'
    list_row='1'
fi

# Options
if [ -z "$BROWSER" ]; then
    BROWSER="firefox"  # Set your default browser here
    prompt="Quick Links: Using '$BROWSER' as web browser"
else
    prompt="Quick Links: Using '$BROWSER' as web browser"
fi

layout=$(grep 'USE_ICON' "$theme" | cut -d'=' -f2)
if [ "$layout" == 'NO' ]; then
    option_1=" Google"
    option_2=" Gmail"
    option_3=" Youtube"
    option_4=" Github"
    option_5=" Reddit"
    option_6="󰈌 Facebook"
else
    option_1=""
    option_2=""
    option_3=""
    option_4=""
    option_5=""
    option_6="󰈌"
fi

# Define the font variable
efonts="Fira Code SemiBold 28"

# Rofi CMD
rofi_cmd() {
    rofi -theme-str "listview {columns: $list_col; lines: $list_row;}" \
        -theme-str 'textbox-prompt-colon {str: "";}' \
        -theme-str "element-text {font: \"$efonts\";}" \
        -dmenu \
        -p "$prompt" \
        -markup-rows \
        -theme "$theme"
}

# Pass variables to rofi dmenu
run_rofi() {
    echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5\n$option_6" | rofi_cmd
}

# Execute Command
run_cmd() {
    if [ "$1" == '--opt1' ]; then
        xdg-open 'https://www.google.com/'
    elif [ "$1" == '--opt2' ]; then
        xdg-open 'https://mail.google.com/'
    elif [ "$1" == '--opt3' ]; then
        xdg-open 'https://www.youtube.com/'
    elif [ "$1" == '--opt4' ]; then
        xdg-open 'https://www.github.com/'
    elif [ "$1" == '--opt5' ]; then
        xdg-open 'https://www.reddit.com/'
    elif [ "$1" == '--opt6' ]; then
        xdg-open 'https://www.facebook.com/'
    fi
}

# Actions
chosen="$(run_rofi)"
case $chosen in
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
    $option_5)
        run_cmd --opt5
        ;;
    $option_6)
        run_cmd --opt6
        ;;
esac
