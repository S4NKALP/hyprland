#!/bin/bash

######################################
#                                                                                          #
#                 Music                                                               #
#                                                                                          #
######################################

music(){

# Directory local music folder
mDIR="$HOME/Music/"

# Directory for icons
iDIR="$HOME/dotfiles/hypr/assets"

# Online Stations. Edit as required
declare -A online_music=(
    ["ʙʜᴀᴊᴀɴ 🚩"]="https://youtube.com/playlist?list=PLwIh-QEhrDJDM8IF3gLUgnEyZm6dBgr_n&si=_RDHngYobHlcxaJW"
    ["ʟᴏꜰɪ ɢɪʀʟ 📻🎶"]="https://www.youtube.com/watch?v=jfKfPfyJRdk"
    ["ɴᴇᴘᴀʟɪ ᴏʟᴅ ꜱᴏɴɢ 📻🎶"]="https://youtube.com/playlist?list=PLXuVG9D9JQ8RAhpH2TyISgBgEmXONIhGY&si=SLyxb2vxaE0XuXsz"
    ["ʙᴏʟʟʏᴡᴏᴏᴅ 📻🎶"]="https://youtube.com/playlist?list=PL9bw4S5ePsEEqCMJSiYZ-KTtEjzVy0YvK&si=J0gPvKL4R4fIlPz9"
    ["ᴛᴏᴘ 50 ʙᴏʟʟʏᴡᴏᴏᴅ 📻🎶"]="https://youtube.com/playlist?list=PLHuHXHyLu7BEnMJNeVvkXpxapvDSp5UdI&si=-TBeeNJ28NqVcnKu"
    ["ʜɪɴᴅɪ ᴅᴊ 🔊🎶"]="https://youtube.com/playlist?list=PLuVudh8_zaHsZKa76lLfirUazcMZWzodb&si=14t1wkmsHiREB71u"
    ["ʜɪɴᴅɪ ʀᴇᴍɪx 📻🎶"]="https://youtube.com/playlist?list=PLuVudh8_zaHvhUe3kLBrq5H3DeTY0bjN2&si=9dzEcnR3n5j1It3S"
    ["ᴍɪx 🔊🎶"]="https://youtube.com/playlist?list=PLwIh-QEhrDJCPrtNv-r0swKWG-onndWjg&si=37SGSalBVz7kwhso"
    ["ᴀʟʟ ᴛɪᴍᴇ ɴᴇᴘᴀʟɪ ʙᴇꜱᴛ 📻🎶"]="https://youtube.com/playlist?list=PLMRKdK25AuPX9eE1G1W6-xBAYGDvKRX6H&si=pAmEK2fV6bLLN8Ss"
  )


# Populate local_music array with files from music directory and subdirectories
populate_local_music() {
  local_music=()
  filenames=()
  while IFS= read -r file; do
    local_music+=("$file")
    filenames+=("$(basename "$file")")
  done < <(find "$mDIR" -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.wav" -o -iname "*.ogg" -o -iname "*.mp4" \))
}

# Function for displaying notifications
notification() {
  notify-send -u normal -i "$iDIR/music.png" "Playing: $@"
}

# Main function for playing local music
play_local_music() {
  populate_local_music

  # Prompt the user to select a song
  choice=$(printf "%s\n" "${filenames[@]}" | rofi -i -dmenu -p "Local Music")

  if [ -z "$choice" ]; then
    exit 1
  fi

  # Find the corresponding file path based on user's choice and set that to play the song then continue on the list
  for (( i=0; i<"${#filenames[@]}"; ++i )); do
    if [ "${filenames[$i]}" = "$choice" ]; then

	    notification "$choice"

      # For some reason wont start playlist at 0
mpv --playlist-start="$i" --loop-playlist --vid=no "${local_music[@]}"
      break
    fi
  done
}

# Main function for shuffling local music
shuffle_local_music() {
  notification "Shuffle local music"

  # Play music in $mDIR on shuffle
  mpv --shuffle --loop-playlist --vid=no "$mDIR"
}

# Main function for playing online music
play_online_music() {
  choice=$(printf "%s\n" "${!online_music[@]}" | rofi -i -dmenu -p "Online Music")

  if [ -z "$choice" ]; then
    exit 1
  fi

  link="${online_music[$choice]}"

  notification "$choice"

  # Play the selected online music using mpv
  mpv --shuffle --vid=no "$link"
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

# Function to adjust volume
adjust_volume() {
  local change="$1"
  local message="$2"

  current_volume=$(playerctl --player=mpv volume)
  new_volume=$(echo "$current_volume + $change" | bc)
  playerctl --player=mpv volume "$new_volume"
  notify-send -u low "$message"
}

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

# Main function
main_menu() {
    if playerctl --player=mpv status | grep -q "Playing"; then
        local controls=("Pause" "Stop" "Next track" "Previous track" "Increase volume" "Decrease volume")
        choice=$(printf "%s\n" "${controls[@]}" | rofi -dmenu -i -p "Music Controls")
        music_controls "$choice"
    else
        local controls=("Play from Music Folder" "Play from Online Stations" "Shuffle Play from Music Folder")
        choice=$(printf "%s\n" "${controls[@]}" | rofi -dmenu -i -p "Select music source")
        case "$choice" in
            "Play from Music Folder") play_local_music ;;
            "Play from Online Stations") play_online_music ;;
            "Shuffle Play from Music Folder") shuffle_local_music ;;
            *) echo "Invalid choice" ;;
        esac
    fi
}

# usage
usage() {
    echo "Usage: $0 [-m] [-i] [-d] [-n] [-p] [-k] [-s]"
    echo "  -m  Main menu"
    echo "  -i  Increase volume"
    echo "  -d  Decrease volume"
    echo "  -n  Next track"
    echo "  -p  Previous track"
    echo "  -k  Play/pause"
    echo "  -s  Stop music"
    exit 1
}

while getopts "midnpks" flag; do
    case "${flag}" in
        m) main_menu ;;
        i) adjust_volume 0.1 "🔊 Increasing track volume" ;;
        d) adjust_volume -0.1 "🔉 Decreasing track volume" ;;
        n) playerctl --player=mpv next && notify-send -u low "⏭️  Next track playing" ;;
        p) playerctl --player=mpv previous && notify-send -u low "⏮️  Previous track playing" ;;
        k) play_pause ;;
        s) pkill mpv && notify-send -u low "🛑 Music stopped" ;;
        *) usage ;;
    esac
done
}
