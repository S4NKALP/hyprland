#!/bin/bash

# Source the configuration file.
CONFIG_FILE=~/.config/hypr/scripts/Ref.sh
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
  swww query || swww init
  PICS=("${wallDIR}"/*.{jpg,jpeg,png,gif})  # Array of image files in wallDIR

  if [[ ${#PICS[@]} -gt 0 ]]; then
    RANDOMPICS=${PICS[RANDOM % ${#PICS[@]}]}  # Select a random image
    swww img "${RANDOMPICS}" ${SWWW_PARAMS}   # Set the randomly selected wallpaper
    $linker
  else
    echo "No images found in ${wallDIR}"
  fi
}


######################################
#                                    #
#       Auto Wallpaper Changer       #
#                                    #
######################################

auto_wall() {
  INTERVAL=1800   # This controls (in seconds) when to switch to the next image
  while true; do
    find "$wallDIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \) -print0 \
      | shuf -z -n 1 \
      | xargs -0 -I {} swww img "{}" ${SWWW_PARAMS} && $linker
    sleep $INTERVAL
  done
}

######################################
#                                    #
#        Wallpaper Selector          #
#                                    #
######################################

select_wall() {
    build_theme() {
        rows="$2"
        cols="$1"
        icon_size="$3"
        echo "element{orientation:vertical;}element-text{horizontal-align:0.5;}element-icon{size:${icon_size}.0000em;}listview{lines:${rows};columns:${cols};}"
    }
    if [ ! -d "$wallDIR" ]; then
        echo "Error: Wallpaper directory not found." >&2
        exit 1
    fi
    images=$(find "$wallDIR" -maxdepth 1 -type f -printf "%f\x00icon\x1f$wallDIR/%f\n" | sort -n)
    choice=$(echo -en "$images\nRandom Choice" | rofi -dmenu -i -show-icons -theme-str "$(build_theme 3 5 6)" -config ~/.config/rofi/config-wallpaper.rasi)
    if [ -n "$choice" ]; then
        if [ "$choice" = "Random Choice" ]; then
            choice=$(find "$wallDIR" -type f -maxdepth 1 -printf "%f\n" | shuf -n1)
        fi
        wallpaper="$wallDIR/${choice#*icon\x1f}"
        swww img $SWWW_PARAMS1 "$wallpaper" && $linker
    else
        echo "No wallpaper selected. Exiting."
        exit 0
    fi
}

######################################
#                                    #
#            Waybar Layout           #
#                                    #
######################################

waybar_layout() {
    menu() {
        find "$config_dir" -maxdepth 1 -type f -exec basename {} \; | sort
    }
    apply_config() {
        ln -sf "$config_dir/$1" "$waybar_config"
        restart_waybar_if_needed
    }
restart_waybar_if_needed() {
    if pgrep -x "waybar" >/dev/null; then
        pkill waybar
        sleep 0.1
    fi
    $RunCMD reload_waybar &
}
    main() {
        choice=$(menu | rofi -dmenu -p "  Choose Waybar Layout")

        [[ -z "$choice" ]] && { echo "No option selected. Exiting."; exit 0; }

        case $choice in
            "no panel") pkill -x waybar || true ;;
            *) apply_config "$choice" ;;
        esac
    }
    pgrep -x rofi && { pkill rofi; exit 0; }
    main
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
        swww init && swww img "$HOME/.config/rofi/.current_wallpaper"
    fi
}

######################################
#                                    #
#            Toggle Opaque           #
#                                    #
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
#     Keyboard Layout Switcher       #
#                                    #
######################################

kb_changer() {
if [ ! -f "$layout_f" ]; then
  default_layout=$(grep 'kb_layout=' "$settings_file" | cut -d '=' -f 2 | cut -d ',' -f 1 2>/dev/null)
  if [ -z "$default_layout" ]; then
    default_layout="us" # Default to 'us' layout if Settings.conf or 'kb_layout' is not found
  fi
  echo "$default_layout" > "$layout_f"
fi
current_layout=$(cat "$layout_f")
if [ -f "$settings_file" ]; then   # Read keyboard layout settings from Settings.conf
  kb_layout_line=$(grep 'kb_layout=' "$settings_file" | cut -d '=' -f 2)
  IFS=',' read -ra layout_mapping <<< "$kb_layout_line"
fi
layout_count=${#layout_mapping[@]}
for ((i = 0; i < layout_count; i++)); do  # Find the index of the current layout in the mapping
  if [ "$current_layout" == "${layout_mapping[i]}" ]; then
    current_index=$i
    break
  fi
done
next_index=$(( (current_index + 1) % layout_count ))  # Calculate the index of the next layout
new_layout="${layout_mapping[next_index]}"
hyprctl keyword input:kb_layout "$new_layout"   # Update the keyboard layout
echo "$new_layout" > "$layout_f"
notify-send -u low -i "$notif" "Keyboad Layout Changed to $new_layout"
}

######################################
#                                    #
#   Symbolic Linker for Wallpaper    #
#                                    #
######################################

linker() {
cache_dir="$HOME/.cache/swww/"   # Define the path to the swww cache directory
monitor_outputs=("$cache_dir"/*)          # Get a list of monitor outputs
ln_success=false  # Initialize a flag to determine if the ln command was executed
for cache_file in "${monitor_outputs[@]}"; do    # Loop through monitor outputs
    if [ -f "$cache_file" ]; then     # Check if the cache file exists for the current monitor output
        wallpaper_path=$(<"$cache_file")   # Get the wallpaper path from the cache file
        if ln -sf "$wallpaper_path" "$HOME/dotfiles/rofi/.current_wallpaper"; then         # Copy the wallpaper to the location Rofi can access
            ln_success=true  # Set the flag to true upon successful execution
            break  # Exit the loop after processing the first found monitor output
        fi
    fi
done
if $ln_success; then # Add a message indicating whether the ln command was successful
    echo "Wallpaper linked successfully."
else
    echo "Failed to link wallpaper."
fi
}


######################################
#                                    #
#          Cava visulizer            #
#                                    #
######################################

caway() {

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM
BARS=8;
FRAMERATE=60;
EQUILIZER=1;
# Get script options
while getopts 'b:f:m:eh' flag; do
    case "${flag}" in
        b) BARS="${OPTARG}" ;;
        f) FRAMERATE="${OPTARG}" ;;
        e) EQUILIZER=0 ;;
        h)
            echo "caway usage: caway [ options ... ]"
            echo "where options include:"
            echo
            echo "  -b <integer>  (Number of bars to display. Default 8)"
            echo "  -f <integer>  (Framerate of the equilizer. Default 60)"
            echo "  -e            (Disable equilizer. Default enabled)"
            echo "  -h            (Show help message)"
            exit 0
            ;;
    esac
done
bar="▁▂▃▄▅▆▇█"
dict="s/;//g;"
i=0  # creating "dictionary" to replace char with bar + thin space " "
while [ $i -lt ${#bar} ]
do
    dict="${dict}s/$i/${bar:$i:1} /g;"
    i=$((i=i+1))
done
dict="${dict}s/.$//;"       # Remove last extra thin space
clean_create_pipe() {
    if [ -p $1 ]; then
        unlink $1
    fi
    mkfifo $1
}
kill_pid_file() {
    if [[ -f $1 ]]; then
        while read pid; do
            { kill "$pid" && wait "$pid"; } 2>/dev/null
        done < $1
    fi
}
cava_waybar_pid="/tmp/cava_waybar_pid"     # PID of the cava process and while loop launched from the script
cava_waybar_pipe="/tmp/cava_waybar.fifo"   # Clean pipe for cava
clean_create_pipe $cava_waybar_pipe
cava_waybar_config="/tmp/cava_waybar_config"     # Custom cava config
echo "
[general]
mode = normal
framerate = $FRAMERATE
bars = $BARS

[output]
method = raw
raw_target = $cava_waybar_pipe
data_format = ascii
ascii_max_range = 7
" > $cava_waybar_config

playerctl_waybar_pipe="/tmp/playerctl_waybar.fifo"   # Clean pipe for playerctl
clean_create_pipe $playerctl_waybar_pipe
playerctl -a metadata --format '{"tooltip": "{{playerName}} : {{markup_escape(artist)}} - {{markup_escape(title)}}", "alt": "{{status}}", "class": "{{status}}"}' -F > "$playerctl_waybar_pipe" &          # playerctl output into playerctl_waybar_pipe
while read -r line; do   # Read the playerctl o/p via its fifo pipe
    kill_pid_file $cava_waybar_pid    # Kill the cava process to stop the input to cava_waybar_pipe
    echo "$line" | jq --unbuffered --compact-output
    # If the class says "Playing" and equilizer is enabled
    # then show the cava equilizer
    if [[ $EQUILIZER == 1 && $(echo $line | jq -r '.class') == 'Playing' ]]; then
        sleep 2  # Show the playing title for 2 seconds
        cava -p $cava_waybar_config >$cava_waybar_pipe &     # cava output into cava_waybar_pipe
        echo $! > $cava_waybar_pid          # Save the PID of child process
        while read -r cmd2; do                # Read the cava o/p via its fifo pipe
            echo "$line" | jq --arg a $(echo $cmd2 | sed "$dict") '.text = $a' --unbuffered --compact-output        # Change the "text" key to bars
        done < $cava_waybar_pipe & # Do this fifo read in background
        echo $! >> $cava_waybar_pid         # Save the while loop PID into the file as well
    fi
done < $playerctl_waybar_pipe
}


######################################
#                                    #
#            Cursor Zoom             #
#                                    #
######################################

cz() {
if [ $(hyprctl -j getoption misc:cursor_zoom_factor | jq '.float' | sed 's/\..*$//') == 1 ]; then
  $(hyprctl keyword misc:cursor_zoom_factor 2) &> /dev/null
else
  $(hyprctl keyword misc:cursor_zoom_factor 1) &> /dev/null
fi
}
