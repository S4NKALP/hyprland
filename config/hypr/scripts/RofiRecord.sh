#!/usr/bin/env bash

# A bash script to record screen using rofi

# Kill if any other rofi instance is running
if pgrep -x "rofi"; then
    killall rofi
    exit
fi

OUTPUT_DIR="$HOME/Videos/ScreenRecord/"
OUTPUT_FILE="$OUTPUT_DIR$(date +%Y-%m-%d_%I-%M-%p).mp4"

record_screen_with_audio="󰽟   Record screen with audio"
record_screen_without_audio="󰽠   Record screen without audio"
record_selection_with_audio="󰒉   Record selection with audio"
record_selection_without_audio="󱟃   Record selection without audio"
stop_recording="   Stop recording"

chosen=$(printf "%s\n%s\n%s\n%s\n%s\n" "$record_screen_with_audio" "$record_screen_without_audio" "$record_selection_with_audio" "$record_selection_without_audio" "$stop_recording"\
        | rofi -dmenu  -config ~/.config/rofi/config-record.rasi \
    )

function stop_recording(){
    pkill wf-recorder --signal SIGINT && notify-send "🛑 Recording stopped" && pkill -RTMIN+8 waybar
    exit
}

function count_down(){
    COUNT_DOWN=3
    while [[ $COUNT_DOWN -ne 0 ]]; do
        echo "$COUNT_DOWN"
        notify-send -t 450 "⏺️ Recording in $COUNT_DOWN"
        (( COUNT_DOWN-- ))
        sleep 0.5
    done
    if [[ ! -d "$OUTPUT_DIR" ]]; then
        mkdir -p "$OUTPUT_DIR"
    fi
    notify-send -t 450 "🎥 Starting recording"
    sleep 0.5
}

function start_recording(){
    if [[ "$chosen" == "$record_screen_with_audio" ]]; then
        count_down
        pkill -RTMIN+8 waybar
        wf-recorder --force-yuv -c libx264rgb -t -f "$OUTPUT_FILE" --audio=alsa_output.pci-0000_03_00.6.analog-stereo.monitor
    elif [[ "$chosen" == "$record_screen_without_audio" ]]; then
        count_down
        pkill -RTMIN+8 waybar
        wf-recorder --force-yuv -c libx264rgb -t -f "$OUTPUT_FILE"
    elif [[ "$chosen" == "$record_selection_with_audio" ]]; then
        geometry="$(slurp)"
        count_down
        pkill -RTMIN+8 waybar
        wf-recorder --force-yuv -c libx264rgb -t -g "$geometry" -f "$OUTPUT_FILE" --audio=alsa_output.pci-0000_03_00.6.analog-stereo.monitor
    elif [[ "$chosen" == "$record_selection_without_audio" ]]; then
        geometry="$(slurp)"
        count_down
        pkill -RTMIN+8 waybar
        wf-recorder --force-yuv -c libx264rgb -t -g "$geometry" -f "$OUTPUT_FILE"
    elif [[ "$chosen" == "$stop_recording" ]]; then
        stop_recording
    fi
}

if [[ ! -z $chosen ]]; then
    start_recording
fi
