#!/bin/bash

# Source the configuration file.
CONFIG_FILE=~/.config/hypr/scripts/Ref.sh
source "$CONFIG_FILE"


# Change blur (SUPER SHIFT Q)
blur (){
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


rainbowborder() {
  function random_hex() {
    random_hex=("0xff$(openssl rand -hex 3)")
    echo $random_hex
}

hyprctl keyword general:col.active_border $(random_hex)  $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex)  270deg

hyprctl keyword general:col.inactive_border $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex)  270deg
}

# Change layout to master & dwindle (SUPER SPACE)
layout() {
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


# Script for Random Wallpaper ( SHIFT ALT W)

randomwall() {
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


# Change Wallpaper automatically after 30min

autowall() {
  INTERVAL=1800   # This controls (in seconds) when to switch to the next image

  while true; do
    find "$wallDIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \) -print0 \
      | shuf -z -n 1 \
      | xargs -0 -I {} swww img "{}" ${SWWW_PARAMS} && $linker

    sleep $INTERVAL
  done
}



# selecting wallpapers (SUPER W)
selectwall() {
    build_theme() {
        rows="$1"
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

# Waybar Layout (ALT W)
waybarl() {
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

# Toggle animations (SUPER SHIFT A)
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

enable_opaque() {
	sleep 0.2
	hyprctl setprop address:$(hyprctl -j activewindow | jq -r -c ".address") forceopaque 0 lock
}
disable_opaque() {
	sleep 0.2
	hyprctl setprop address:$(hyprctl -j activewindow | jq -r -c ".address") forceopaque 1 lock
}

welcome() {
sleep 1

name=$(whoami)

notify-send "Hello" "${name}?,you're back? welcome what will we do today!"
}

# Switch Keyboard Layout (ALT F1)
kb() {
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

# Symbolic link for wallpaper
linker() {
  # Define the path to the swww cache directory
cache_dir="$HOME/.cache/swww/"

# Get a list of monitor outputs
monitor_outputs=("$cache_dir"/*)

# Initialize a flag to determine if the ln command was executed
ln_success=false

# Loop through monitor outputs
for cache_file in "${monitor_outputs[@]}"; do
    # Check if the cache file exists for the current monitor output
    if [ -f "$cache_file" ]; then
        # Get the wallpaper path from the cache file
        wallpaper_path=$(<"$cache_file")

        # Copy the wallpaper to the location Rofi can access
        if ln -sf "$wallpaper_path" "$HOME/.config/rofi/.current_wallpaper"; then
            ln_success=true  # Set the flag to true upon successful execution
            break  # Exit the loop after processing the first found monitor output
        fi
    fi
done

# Add a message indicating whether the ln command was successful
if $ln_success; then
    echo "Wallpaper linked successfully."
else
    echo "Failed to link wallpaper."
fi
}
