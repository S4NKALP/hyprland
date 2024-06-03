#!/bin/bash

# Source the configuration file.
CONFIG_FILE=~/dotfiles/hypr/scripts/Ref.sh
source "$CONFIG_FILE"


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

######################################
#                                    #
#           Rainbow Border           #
#                                    #
######################################

rainbow_border() {
  function random_hex() {
    random_hex=("0xff$(openssl rand -hex 3)")
    echo $random_hex
}
hyprctl keyword general:col.active_border $(random_hex)  $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex)  270deg

hyprctl keyword general:col.inactive_border $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex)  270deg
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
#         Random Wallpaper           #
#                                    #
######################################

random_wall() {
focused_monitor=$(hyprctl monitors | awk '/^Monitor/{name=$2} /focused: yes/{print name}')

PICS=($(find ${wallDIR} -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \)))
RANDOMPICS=${PICS[ $RANDOM % ${#PICS[@]} ]}

swww query || swww-daemon --format xrgb && swww img -o $focused_monitor ${RANDOMPICS} $SWWW_PARAMS
$RunCMD symlink
}


######################################
#                                    #
#       Auto Wallpaper Changer       #
#                                    #
######################################

auto_wall() {
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
#        Wallpaper Selector          #
#                                    #
######################################

select_wall() {
    focused_monitor=$(hyprctl monitors | awk '/^Monitor/{name=$2} /focused: yes/{print name}')
    build_theme() {
        rows="$1"
        cols="$2"
        icon_size="$2"
        echo "element{orientation:vertical;}element-text{horizontal-align:0.5;}element-icon{size:${icon_size}.0000em;}listview{lines:${rows};columns:${cols};}"
    }
    if [ ! -d "$wallDIR" ]; then
        echo "Error: Wallpaper directory not found." >&2
        exit 1
    fi
    images=$(find "$wallDIR" -maxdepth 1 -type f -printf "%f\x00icon\x1f$wallDIR/%f\n" | sort -n)
    choice=$(echo -en "$images\nRandom Choice" | rofi -dmenu -i -show-icons -theme-str "$(build_theme 3 5 6)" -p "󰸉  Wallpaper")
    if [ -n "$choice" ]; then
        if [ "$choice" = "Random Choice" ]; then
            choice=$(find "$wallDIR" -type f -maxdepth 1 -printf "%f\n" | shuf -n1)
        fi
        wallpaper="$wallDIR/${choice#*icon\x1f}"
        swww img -o $focused_monitor $SWWW_PARAMS1 "$wallpaper"
        $RunCMD symlink
    else
        echo "No wallpaper selected. Exiting."
        exit 0
    fi
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

