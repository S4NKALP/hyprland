#! /usr/bin/env bash

# Control moosic using keyboard

# SUPER + M should open a submap
# M should open the rofi-music menu
# i should increase volume
# u should decrease volume
# n should trigger next track
# p should trigger previous track
# k should pause resume music
# s should stop music

function open_rofi_music(){
    exec $HOME/.config/hypr/scripts/RofiMusic.sh
}

function increase_volume(){
    current_volume=$(playerctl --player=mpv volume)
    new_volume=$(echo "$current_volume + 0.1" | bc)
    playerctl --player=mpv volume $new_volume && notify-send "🔊 Increasing track volume"
}

function decrease_volume(){
    current_volume=$(playerctl --player=mpv volume)
    new_volume=$(echo "$current_volume - 0.1" | bc)
    playerctl --player=mpv volume $new_volume && notify-send "🔉 Decreasing track volume"
}

function next_track(){
    playerctl --player=mpv next && notify-send "⏭️  Next track playing"
}

function prev_track(){
    playerctl --player=mpv previous && notify-send "⏮️  Previous track playing"
}

function play_pause(){
    status=$(playerctl --player=mpv status)
    if [[ "$status" == "Playing" ]]
    then
        playerctl --player=mpv pause && notify-send "⏸️ Music paused"
    else
        playerctl --player=mpv play && notify-send "▶️  Resuming music"
    fi
}

function stop_music(){
    kill $(pidof "rofi-music") && notify-send "🛑 Music stopped"
}

while getopts midnpks flag
do
    case "${flag}" in
        m) open_rofi_music ;;
        i) increase_volume ;;
        d) decrease_volume ;;
        s) stop_music ;;
        n) next_track ;;
        p) prev_track ;;
        k) play_pause ;;
    esac
done
