#!/usr/bin/env bash
ACTION="$1"
case "$ACTION" in
    up)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
        ;;
    down)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        ;;
    mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ;;
esac
VOLUME=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
PERCENT=$(echo "$VOLUME" | awk '{printf "%.0f", $2 * 100}')
MUTE_STATE=$(echo "$VOLUME" | grep -o MUTED)
if [ "$ACTION" = "mute" ]; then
    if [ -n "$MUTE_STATE" ]; then
        notify-send -t 1500 -h string:x-canonical-private-synchronous:volume "volume: muted"
    else
        notify-send -t 1500 -h string:x-canonical-private-synchronous:volume "volume: ${PERCENT}%" "🔊"
    fi
else
    notify-send -t 1500 -h string:x-canonical-private-synchronous:volume "volume: ${PERCENT}%" "🔊"
fi
