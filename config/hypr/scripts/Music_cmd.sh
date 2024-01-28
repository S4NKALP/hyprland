#!/bin/bash

music(){
# Directory for icons
iDIR="$HOME/.config/swaync/icons"

# Note: You can add more options below with the following format:
# ["TITLE"]="link"

# Define menu options as an associative array
declare -A menu_options=(
  ["Play Bhajan"]="https://youtube.com/playlist?list=PLwIh-QEhrDJDM8IF3gLUgnEyZm6dBgr_n&si=_RDHngYobHlcxaJW"
  ["Play lofi girl"]="https://www.youtube.com/watch?v=jfKfPfyJRdk"
  ["Play Nepali Old Song"]="https://youtube.com/playlist?list=PLXuVG9D9JQ8RAhpH2TyISgBgEmXONIhGY&si=SLyxb2vxaE0XuXsz"
  ["Play BollyWood Love"]="https://youtube.com/playlist?list=PL9bw4S5ePsEEqCMJSiYZ-KTtEjzVy0YvK&si=J0gPvKL4R4fIlPz9"
  ["Play Top 50 BollyWood"]="https://youtube.com/playlist?list=PLHuHXHyLu7BEnMJNeVvkXpxapvDSp5UdI&si=-TBeeNJ28NqVcnKu"
)

# Function for displaying notifications
notification() {
  notify-send -u normal -i "$iDIR/music.png" "$1"
}

# Function to play music
play_music() {
  local choice="$1"
  local link="${menu_options[$choice]}"

  # Check if the link is a playlist
  if [[ $link == *playlist* ]]; then
    mpv --shuffle --vid=no --no-resume-playback "$link"
    notification "Playing now: $choice"
  elif [[ -n $link ]]; then
    mpv "$link"
    notification "Playing now: $choice"
  fi
}

# Function for music controls
music_controls() {
  local choice="$1"

  case "$choice" in
    "Play") playerctl --player=mpv play && notify-send -u low "▶️  Resuming music" ;;
    "Pause") playerctl --player=mpv pause && notify-send -u low "⏸️ Music paused" ;;
    "Stop") pkill mpv && notify-send -u low "🛑 Music stopped" ;;
    "Next track") playerctl --player=mpv next && notify-send -u low "⏭️  Next track playing" ;;
    "Previous track") playerctl --player=mpv previous && notify-send -u low "⏮️  Previous track playing" ;;
    "Increase volume") adjust_volume 0.1 "🔊 Increasing track volume" ;;
    "Decrease volume") adjust_volume -0.1 "🔉 Decreasing track volume" ;;
  esac
}

# Function to adjust volume
adjust_volume() {
  local change="$1"
  local message="$2"

  current_volume=$(playerctl --player=mpv volume)
  new_volume=$(echo "$current_volume + $change" | bc)
  playerctl --player=mpv volume "$new_volume"
  notify-send -u low "$message"
}

# Function to play/pause music
play_pause() {
  playerctl --player=mpv play-pause
  if playerctl --player=mpv status | grep -q "Playing"; then
    notify-send -u low "▶️  Resuming music"
  else
    notify-send -u low "⏸️ Music paused"
  fi
}

# Main function
main() {
  local is_music_playing=$(pgrep -x "mpv")
  local streaming_options=("Play Bhajan" "Play lofi girl" "Play Nepali Old Song" "Play BollyWood Love" "Play Top 50 BollyWood")

  if [ -n "$is_music_playing" ]; then
    local controls=("Play" "Pause" "Stop" "Next track" "Previous track" "Increase volume" "Decrease volume")
    choice=$(printf "%s\n" "${controls[@]}" | rofi -dmenu -i -p "Music Controls:")
    music_controls "$choice"
  else
    choice=$(printf "%s\n" "${streaming_options[@]}" | rofi -dmenu -i -p "Music Time:")
    play_music "$choice"
  fi
}

while getopts "midnpks" flag; do
    case "${flag}" in
        m) main ;;
        i) adjust_volume 0.1  "🔊 Increasing track volume" ;;
        d) adjust_volume -0.1 "🔉 Decreasing track volume" ;;
        n) playerctl --player=mpv next && notify-send -u low "⏭️  Next track playing" ;;
        p) playerctl --player=mpv previous && notify-send -u low "⏮️  Previous track playing" ;;
        k) play_pause ;;
        s) pkill mpv && notify-send -u low "🛑 Music stopped" ;;
    esac
done
}
