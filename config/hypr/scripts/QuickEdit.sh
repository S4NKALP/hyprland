#!/bin/bash

userDir="$HOME/.config/hypr/configs"


menu(){
  printf "1. view Env-variables\n"
  printf "2. view Window-Rules\n"
  printf "3. view Startup_Apps\n"
  printf "4. view Keybinds\n"
  printf "5. view Monitors\n"
  printf "6. view Laptop-Keybinds\n"
  printf "7. view Settings\n"
}

main() {
    choice=$(menu | rofi -dmenu -config ~/.config/rofi/config-quickedit.rasi | cut -d. -f1)
    case $choice in
        1)
            kitty -e nano "$userDir/ENVariables.conf"
            ;;
        2)
            kitty -e nano "$userDir/WindowRules.conf"
            ;;
        3)
            kitty -e nano "$userDir/Startup_Apps.conf"
            ;;
        4)
            kitty -e nano "$userDir/Keybinds.conf"
            ;;
        5)
            kitty -e nano "$userDir/Monitors.conf"
            ;;
        6)
            kitty -e nano "$userDir/Laptops.conf"
            ;;
        7)
            kitty -e nano "$userDir/Settings.conf"
            ;;

        *)
            ;;
    esac
}

main
