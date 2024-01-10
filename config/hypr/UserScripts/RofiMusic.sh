#!/usr/bin/env bash

# Directory for icons
iDIR="$HOME/.config/swaync/icons"


LOFI_STREAM="https://www.youtube.com/watch?v=jfKfPfyJRdk"
NEPALI_OLD_SONG="https://youtube.com/playlist?list=PLXuVG9D9JQ8RAhpH2TyISgBgEmXONIhGY&si=SLyxb2vxaE0XuXsz"
BOLLYWOOD_LOVE_SONG="https://youtube.com/playlist?list=PL9bw4S5ePsEEqCMJSiYZ-KTtEjzVy0YvK&si=J0gPvKL4R4fIlPz9"
TOP_50_BOLLYWOOD="https://youtube.com/playlist?list=PLHuHXHyLu7BEnMJNeVvkXpxapvDSp5UdI&si=-TBeeNJ28NqVcnKu"
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
play_old_nepali="1.   Play Nepali Old Song"
play_bollywood_love="2.   Play BollyWood Love"
play_TOP_50_BOLLYWOOD="3.   Play Top 50 BollyWood"

function notify() {
    notify-send -u normal -i "$iDIR/music.png" "$1"
}

function music() {
    local chosen=$(printf "%s\n%s\n%s\n%s\n" "$play_bhajan" "$play_lofi" "$play_old_nepali" "$play_bollywood_love" "$play_TOP_50_BOLLYWOOD" | rofi -dmenu -i -l 5 -p "Music Time:" -config ~/.config/rofi/config.rasi)


    if [[ "$chosen" == "$play_bhajan" ]]; then
        notify "Playing Bhajan"
        exec -a "rofi-music" mpv --no-video "$BHAJAN" --shuffle --no-resume-playback
    elif [[ "$chosen" == "$play_lofi" ]]; then
        notify "🎹 Playing lofi girl"
        exec -a "rofi-music" mpv --no-video "$LOFI_STREAM" --no-resume-playback
    elif [[ "$chosen" == "$play_old_nepali" ]]; then
        notify "🎹 Playing nepali old song"
        exec -a "rofi-music" mpv --no-video "$NEPALI_OLD_SONG" --shuffle --no-resume-playback
    elif [[ "$chosen" == "$play_bollywood_love" ]]; then
        notify "🎹 Playing bollywood love"
        exec -a "rofi-music" mpv --no-video "$BOLLYWOOD_LOVE_SONG" --shuffle --no-resume-playback
    elif [[ "$chosen" == "$play_TOP_50_BOLLYWOOD" ]]; then
        notify "🎹 Playing top 50 bollywood"
        exec -a "rofi-music" mpv --no-video "$TOP_50_BOLLYWOOD" --shuffle --no-resume-playback
    fi
}

function controls() {
    local chosen=$(printf "%s\n%s\n%s\n%s\n%s\n%s\n%s\n" "$play" "$pause" "$stop" "$next_track" "$prev_track" "$increase_volume" "$decrease_volume" | rofi -dmenu -i -l 7 -p "Music Controls:" -config ~/.config/rofi/config.rasi)

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
