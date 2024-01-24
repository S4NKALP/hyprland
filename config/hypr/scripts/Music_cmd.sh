#!/usr/bin/env bash

iDIR="$HOME/.config/swaync/icons"
LOFI_STREAM="https://www.youtube.com/watch?v=jfKfPfyJRdk"
NEPALI_OLD_SONG="https://youtube.com/playlist?list=PLXuVG9D9JQ8RAhpH2TyISgBgEmXONIhGY&si=SLyxb2vxaE0XuXsz"
BOLLYWOOD_LOVE_SONG="https://youtube.com/playlist?list=PL9bw4S5ePsEEqCMJSiYZ-KTtEjzVy0YvK&si=J0gPvKL4R4fIlPz9"
TOP_50_BOLLYWOOD="https://youtube.com/playlist?list=PLHuHXHyLu7BEnMJNeVvkXpxapvDSp5UdI&si=-TBeeNJ28NqVcnKu"
BHAJAN="https://youtube.com/playlist?list=PLwIh-QEhrDJDM8IF3gLUgnEyZm6dBgr_n&si=_RDHngYobHlcxaJW"

play="  Play music"
pause="  Pause music"
stop="  Stop music"
next_track="  Next track"
prev_track="  Previous track"
increase_volume="󰝝  Increase volume"
decrease_volume="󰝞  Decrease volume"

play_bhajan="󰥳 Play Bhajan"
play_lofi="  Play lofi girl"
play_old_nepali="1.   Play Nepali Old Song"
play_bollywood_love="2.   Play BollyWood Love"
play_TOP_50_BOLLYWOOD="3.   Play Top 50 BollyWood"

notify() { notify-send -u normal -i "$iDIR/music.png" "$1"; }

music() {
    if pgrep -x "mpv" > /dev/null; then
        controls
    else
        local chosen=$(printf "%s\n%s\n%s\n%s\n" "$play_bhajan" "$play_lofi" "$play_old_nepali" "$play_bollywood_love" "$play_TOP_50_BOLLYWOOD" | rofi -dmenu -i -l 5 -p "Music Time:" -config ~/.config/rofi/config.rasi)

        case "$chosen" in
            "$play_bhajan") notify "Playing Bhajan"; exec -a "rofi-music" mpv --no-video "$BHAJAN" --shuffle --no-resume-playback ;;
            "$play_lofi") notify "🎹 Playing lofi girl"; exec -a "rofi-music" mpv --no-video "$LOFI_STREAM" --no-resume-playback ;;
            "$play_old_nepali") notify "🎹 Playing nepali old song"; exec -a "rofi-music" mpv --no-video "$NEPALI_OLD_SONG" --shuffle --no-resume-playback ;;
            "$play_bollywood_love") notify "🎹 Playing bollywood love"; exec -a "rofi-music" mpv --no-video "$BOLLYWOOD_LOVE_SONG" --shuffle --no-resume-playback ;;
            "$play_TOP_50_BOLLYWOOD") notify "🎹 Playing top 50 bollywood"; exec -a "rofi-music" mpv --no-video "$TOP_50_BOLLYWOOD" --shuffle --no-resume-playback ;;
        esac
    fi
}

controls() {
    local chosen=$(printf "%s\n%s\n%s\n%s\n%s\n%s\n%s\n" "$play" "$pause" "$stop" "$next_track" "$prev_track" "$increase_volume" "$decrease_volume" | rofi -dmenu -i -l 7 -p "Music Controls:" -config ~/.config/rofi/config.rasi)

    case "$chosen" in
        "$play") playerctl --player=mpv play && notify-send -u normal -i "$1" "▶️  Resuming music" ;;
        "$pause") playerctl --player=mpv pause && notify-send -u normal -i "$1" "⏸️ Music paused" ;;
        "$stop") pkill mpv && notify-send -u normal -i "$1" "🛑 Music stopped" ;;
        "$next_track") playerctl --player=mpv next && notify-send -u normal -i "$1" "⏭️  Next track playing" ;;
        "$prev_track") playerctl --player=mpv previous && notify-send -u normal -i "$1" "⏮️  Previous track playing" ;;
        "$increase_volume") adjust_volume 0.1 "🔊 Increasing track volume" ;;
        "$decrease_volume") adjust_volume -0.1 "🔉 Decreasing track volume" ;;
    esac
}

adjust_volume() {
    current_volume=$(playerctl --player=mpv volume)
    new_volume=$(echo "$current_volume + $1" | bc)
    playerctl --player=mpv volume "$new_volume"
    notify-send -u normal -i "$iDIR/music.png" "$2"
}

while getopts midnpks flag; do
    case "${flag}" in
        m) music ;;
        i) adjust_volume 0.1 "🔊 Increasing track volume" ;;
        d) adjust_volume -0.1 "🔉 Decreasing track volume" ;;
        s) kill $(pidof "rofi-music") && notify-send "🛑 Music stopped" ;;
        n) playerctl --player=mpv next && notify-send "⏭️  Next track playing" ;;
        p) playerctl --player=mpv previous && notify-send "⏮️  Previous track playing" ;;
        k) play_pause ;;
    esac
done
