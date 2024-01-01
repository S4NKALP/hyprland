#!/usr/bin/env bash

# Directory for icons
iDIR="$HOME/.config/swaync/icons"


LOFI_STREAM="https://www.youtube.com/watch?v=jfKfPfyJRdk"
ALL_TIME_CHILL_HITS="https://www.youtube.com/playlist?list=PL1FPWPLPHKhysG2trm9RKV8FG3eQ7J4VN"
ALL_TIME_MALAYALAM_HITS="https://www.youtube.com/playlist?list=PL1FPWPLPHKhyZeoBv-Ws_eRiWiUYKkuDz"
HAND_PICKED_HITS="https://music.youtube.com/playlist?list=PLAj6caR1_EYHevz9nP5CzbE-z8viVAyI3&feature=share"
BHAJAN="https://youtube.com/playlist?list=PLwIh-QEhrDJDM8IF3gLUgnEyZm6dBgr_n&si=_RDHngYobHlcxaJW"

# Player menu controls
play="  Play music"
pause="  Pause music"
stop="  Stop music"
next_track="  Next track"
prev_track="  Previous track"
increase_volume="󰝝  Increase volume"
decrease_volume="󰝞  Decrease volume"

# Music menu controls
play_bhajan="󰥳 Play Bhajan"
play_lofi="  Play lofi girl"
play_chill_hits="1.   Play All time chill hits"
play_malayalam_hits="2.   Play All time malayalam hits"
play_hand_picked_hits="3.   Play hand picked hits"

function notify() {
    notify-send -u normal -i "$iDIR/music.png" "$1"
}

function music() {
    local chosen=$(printf "%s\n%s\n%s\n%s\n" "$play_bhajan" "$play_lofi" "$play_chill_hits" "$play_malayalam_hits" "$play_hand_picked_hits" | rofi -dmenu -i -l 6  -config ~/.config/rofi/config-rofi-music.rasi)


    if [[ "$chosen" == "$play_bhajan" ]]; then
        notify "Playing Bhajan"
        exec -a "rofi-music" mpv --no-video "$BHAJAN" --shuffle --no-resume-playback
    elif [[ "$chosen" == "$play_lofi" ]]; then
        notify "🎹 Playing lofi girl"
        exec -a "rofi-music" mpv --no-video "$LOFI_STREAM" --no-resume-playback
    elif [[ "$chosen" == "$play_chill_hits" ]]; then
        notify "🎹 Playing all time chill hits"
        exec -a "rofi-music" mpv --no-video "$ALL_TIME_CHILL_HITS" --shuffle --no-resume-playback
    elif [[ "$chosen" == "$play_malayalam_hits" ]]; then
        notify "🎹 Playing malayalam hits"
        exec -a "rofi-music" mpv --no-video "$ALL_TIME_MALAYALAM_HITS" --shuffle --no-resume-playback
    elif [[ "$chosen" == "$play_hand_picked_hits" ]]; then
        notify "🎹 Playing hand picked hits"
        exec -a "rofi-music" mpv --no-video "$HAND_PICKED_HITS" --shuffle --no-resume-playback
    fi
}

function controls() {
    local chosen=$(printf "%s\n%s\n%s\n%s\n%s\n%s\n%s\n" "$play" "$pause" "$stop" "$next_track" "$prev_track" "$increase_volume" "$decrease_volume" | rofi -dmenu -i -l 7 -config ~/.config/rofi/config-rofi-music.rasi)

    if [[ "$chosen" == "$play" ]]; then
        playerctl --player=mpv play && notify-send -u normal -i "$1" "▶️  Resuming music"
    elif [[ "$chosen" == "$pause" ]]; then
        playerctl --player=mpv pause && notify-send -u normal -i "$1" "⏸️ Music paused"
    elif [[ "$chosen" == "$stop" ]]; then
        kill $(pidof "rofi-music") && notify-send -u normal -i "$1" "🛑 Music stopped"
    elif [[ "$chosen" == "$next_track" ]]; then
        playerctl --player=mpv next && notify-send -u normal -i "$1" "⏭️  Next track playing"
    elif [[ "$chosen" == "$prev_track" ]]; then
        playerctl --player=mpv previous && notify-send -u normal -i "$1" "⏮️  Previous track playing"
    elif [[ "$chosen" == "$increase_volume" ]]; then
        current_volume=$(playerctl --player=mpv volume)
        new_volume=$(echo "$current_volume + 0.1" | bc)
        playerctl --player=mpv volume $new_volume && notify-send -u normal -i "$1" "🔊 Increasing track volume"
    elif [[ "$chosen" == "$decrease_volume" ]]; then
        current_volume=$(playerctl --player=mpv volume)
        new_volume=$(echo "$current_volume - 0.1" | bc)
        playerctl --player=mpv volume $new_volume && notify-send -u normal -i "$1" "🔉 Decreasing track volume"
    fi
}

# Check if music is running
if pidof "rofi-music" > /dev/null; then
    controls
else
    music
fi
