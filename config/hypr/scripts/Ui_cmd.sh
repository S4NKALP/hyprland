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

sr() {
  if pgrep -x "wf-recorder" > /dev/null; then
    pkill -SIGTERM wf-recorder
    wait "$(pgrep -o wf-recorder)" || true
    notify-send "Screen recording stopped."
  else
    wf-recorder --force-yuv -c libx264rgb -t -f "$HOME/Videos/sr--$(date +'%I:%M:%S_%p_%d-%m-%Y.mp4')" --audio=alsa_output.pci-0000_03_00.6.analog-stereo.monitor &
    disown
    notify-send "Screen recording started."
  fi
}

# Waybar Layout (ALT W)
waybarl() {
    menu() {
        find "$config_dir" -maxdepth 1 -type f -exec basename {} \; | sort
    }
    apply_config() {
        ln -sf "$config_dir/$1" "$waybar_config"
        pkill -x waybar && sleep 0.1
        $CMD &
    }
    main() {
        choice=$(menu | rofi -dmenu -p " Choose Waybar Layout")

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



