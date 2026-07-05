#!/bin/bash

if [ "$1" = "muted" ]; then
    wpctl set-mute "@DEFAULT_AUDIO_SINK@" toggle
else
    wpctl set-volume "@DEFAULT_AUDIO_SINK@" "$1"
fi
VOLUME=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')
VOLUME_PERCENT=$(awk "BEGIN {printf \"%.0f\", $VOLUME * 100}")
MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -o "MUTED")
if [ -n "$MUTED" ]; then
    notify-send -t 2000 -h string:x-canonical-private-synchronous:volume "valume: mute" "🔇"
else
    notify-send -t 2000 -h string:x-canonical-private-synchronous:volume -h int:value:$VOLUME_PERCENT "valume: ${VOLUME_PERCENT}%" "🔊"
fi
