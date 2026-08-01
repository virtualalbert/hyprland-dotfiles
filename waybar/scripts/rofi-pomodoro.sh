#!/usr/bin/env bash
# Plain text rofi menu to control the counter. Uses your existing rofi
# theme (dmenu mode, no icons) so it matches the rest of your setup.

POMO="$HOME/.config/waybar/scripts/pomodoro.sh"

options="Start 25 (work)\nStart 5 (break)\nStart custom\nPause / Resume\nAdd 5 min\nStop"

# No -theme-str override — inherits whatever rofi theme/config.rasi
# you already have set up (the plain borderless text-list one).
chosen=$(echo -e "$options" | rofi -dmenu -p "counter")

case "$chosen" in
    "Start 25 (work)")
        "$POMO" start 25 WORK
        ;;
    "Start 5 (break)")
        "$POMO" start 5 BREAK
        ;;
    "Start custom")
        mins=$(echo "" | rofi -dmenu -p "minutes")
        [ -n "$mins" ] && "$POMO" start "$mins" TIMER
        ;;
    "Pause / Resume")
        "$POMO" toggle
        ;;
    "Add 5 min")
        "$POMO" add 5
        ;;
    "Stop")
        "$POMO" stop
        ;;
esac
