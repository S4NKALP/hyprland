#!/bin/bash

notif="$HOME/dotfiles/hypr/assets/bell.png"



# For Keyboard Layout Switcher


######################################
#                                    #
#             Toggle Blur            #
#                                    #
######################################

toggle_blur (){
  STATE=$(hyprctl -j getoption decoration:blur:passes | jq ".int")

  if [ "${STATE}" == "2" ]; then
	   hyprctl keyword decoration:blur:size 2
	   hyprctl keyword decoration:blur:passes 1
 	   notify-send -e -u low -i "$notif" "Less blur"
  else
       hyprctl keyword decoration:blur:size 5
	   hyprctl keyword decoration:blur:passes 2
       notify-send -e -u low -i "$notif" "Normal blur"
  fi
}

######################################
#                                    #
#        Toggle Animation            #
#                                    #
######################################

toggle_animation() {
	STATE=$(hyprctl -j getoption animations:enabled | jq ".int")
	if [ "${STATE}" = "1" ]; then
		hyprctl keyword animations:enabled 0
		noti_n "Disable animation"
	else
		hyprctl keyword animations:enabled 1
		noti_n "Enable animation"
	fi

}

################################################
#                                              #
#      Change Layout Master to Dwindle         #
#                                              #
################################################

change_layout() {
  LAYOUT=$(hyprctl -j getoption general:layout | jq -r '.str')
  case $LAYOUT in
    "master")
      hyprctl keyword general:layout dwindle
      hyprctl keyword unbind SUPER,J
      hyprctl keyword unbind SUPER,K
      hyprctl keyword bind SUPER,J,cyclenext
      hyprctl keyword bind SUPER,K,cyclenext,prev
      hyprctl keyword bind SUPER,O,togglesplit
      notify-send -u low -i "$notif" "Dwindle Layout"
      ;;
    "dwindle")
      hyprctl keyword general:layout master
      hyprctl keyword unbind SUPER,J
      hyprctl keyword unbind SUPER,K
      hyprctl keyword unbind SUPER,O
      hyprctl keyword bind SUPER,J,layoutmsg,cyclenext
      hyprctl keyword bind SUPER,K,layoutmsg,cycleprev
      notify-send -u low -i "$notif" "Master Layout"
      ;;
    *) ;;
  esac
}


######################################
#                                    #
#       Auto Wallpaper Changer       #
#                                    #
######################################

auto_wall() {
  wallDIR="$HOME/Pictures/wallpapers"
  FPS=60
  TYPE="random"
  DURATION=1
  BEZIER=".43,1.19,1,.4"
  SWWW_PARAMS="--transition-fps ${FPS} --transition-type ${TYPE} --transition-duration ${DURATION} --transition-bezier ${BEZIER}"
  focused_monitor=$(hyprctl monitors | awk '/^Monitor/{name=$2} /focused: yes/{print name}')
  INTERVAL=1800   # This controls (in seconds) when to switch to the next image
 while true; do
    find "$wallDIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \) -print0 \
      | shuf -z -n 1 \
      | xargs -0 -I {} swww img -o $focused_monitor "{}" ${SWWW_PARAMS} &&
            $RunCMD symlink
			sleep $INTERVAL
		done
}



######################################
#                                    #
#             GameMode               #
#                                    #
######################################)
gamemode() {
    status=$(hyprctl getoption animations:enabled -j | jq ".int")
    if [[ $status -eq 1 ]]; then
        notify-send -e -u low -i "$notif" "All animations off"
        hyprctl keyword animations:enabled 0
        swww kill
    else
        notify-send -e -u normal -i "$notif" "All animations normal"
        hyprctl keyword animations:enabled 1
        swww query || swww init && $random_wall
    fi
}

######################################
#                                                                                           #
#                                       Toggle Opaque                        #
#                                                                                          #
######################################

enable_opaque() {
	sleep 0.2
	hyprctl setprop address:$(hyprctl -j activewindow | jq -r -c ".address") forceopaque 0 lock
}
disable_opaque() {
	sleep 0.2
	hyprctl setprop address:$(hyprctl -j activewindow | jq -r -c ".address") forceopaque 1 lock
}

######################################
#                       Keyboard Layout Switcher                   #
#                                                                                          #
######################################

kb_changer() {
    layout_f="$HOME/.cache/kb_layout"
    settings_file="$HOME/dotfiles/hypr/UserConfigs/UserSettings.conf"
    current_layout=$(cat "$layout_f")

    [ -f "$settings_file" ] && IFS=',' read -ra layout_mapping <<< "$(grep 'kb_layout=' "$settings_file" | cut -d '=' -f 2)"

    for i in "${!layout_mapping[@]}"; do
        [ "$current_layout" == "${layout_mapping[i]}" ] && new_layout="${layout_mapping[((i + 1) % ${#layout_mapping[@]})]}" && break
    done

    hyprctl switchxkblayout "at-translated-set-2-keyboard" "$new_layout" && echo "$new_layout" > "$layout_f"

    hyprctl devices -j | jq -r '.keyboards[].name' | while read -r name; do
        hyprctl switchxkblayout "$name" next || { notify-send -u low -t 2000 'Keyboard layout' 'Error: Layout change failed'; exit 1; }
    done

    notify-send -u low -i "$notif" "Keyboard language changed to $new_layout"
}

