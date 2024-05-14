#!/bin/bash

######################################
#                                    #
#                 Music              #
#                                    #
######################################

music(){
# Directory for icons
iDIR="$HOME/dotfiles/hypr/assets"

# Note: You can add more options below with the following format:
# ["TITLE"]="link"

# Define menu options as an associative array
declare -A menu_options=(
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
  elif [[ -n $link ]]; then
    mpv "$link"
  fi

  # Check if mpv is running to ensure music is playing
  if pgrep -x "mpv" >/dev/null; then
    notification "Playing now: $choice"
  fi
}


######################################
#                                    #
#            Music Control           #
#                                    #
######################################

music_controls() {
  local choice="$1"

  case "$choice" in
    "Play") playerctl --player=mpv play && notify-send -u low "▶️  Resuming music" ;;
    "Pause") playerctl --player=mpv pause && notify-send -u low "⏸️ Music paused" ;;
    "Stop") pkill mpv && notify-send -u low "🛑 Music stopped" ;;
    "Next track") playerctl --player=mpv next && notify-send -u low "⏭️  Next track playing" ;;
    "Previous track") playerctl --player=mpv previous && notify-send -u low "⏮️  Previous track playing" ;;
    "Increase volume") adjust_volume 0.1 && notify-send -u low "🔊 Increasing track volume" ;;
    "Decrease volume") adjust_volume -0.1 && notify-send -u low "🔉 Decreasing track volume" ;;
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
  local is_music_playing=$(playerctl --player=mpv status 2>/dev/null)

  if [ "$is_music_playing" == "Playing" ]; then
    local controls=("Play" "Pause" "Stop" "Next track" "Previous track" "Increase volume" "Decrease volume")
    choice=$(printf "%s\n" "${controls[@]}" | rofi -dmenu -i -p "Music Controls:")
    music_controls "$choice"
  else
    local options=("Play from Playlist" "Play from Folder")
    choice=$(printf "%s\n" "${options[@]}" | rofi -dmenu -i -p "Music Time:")

case "$choice" in
    "Play from Playlist")
        playlist_choice=$(printf "%s\n" "${!menu_options[@]}" | rofi -dmenu -i -p "Choose playlist:")
        play_music "$playlist_choice"
        ;;
    "Play from Folder")
        local music_files=$(find ~/Music -type f \( -iname \*.mp3 -o -iname \*.flac -o -iname \*.wav -o -iname \*.ogg -o -iname \*.aac -o -iname \*.m4a -o -iname \*.wma -o -iname \*.opus \) -exec basename {} \; | rofi -dmenu -i -p "Choose music file:")
        if [ -n "$music_files" ]; then
            notification "Playing now: $music_files"  # Moved the notification here
            local full_path=$(find ~/Music -type f \( -iname \*.mp3 -o -iname \*.flac -o -iname \*.wav -o -iname \*.ogg -o -iname \*.aac -o -iname \*.m4a -o -iname \*.wma -o -iname \*.opus \) -exec realpath {} \; | grep "$music_files")
            mpv "$full_path"
        fi
        ;;
esac


  fi
}



######################################
#                                    #
#                 Usage              #
#                                    #
######################################

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
