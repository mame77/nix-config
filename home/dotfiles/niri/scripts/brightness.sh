#!/bin/bash
brightnessctl set "$1"
CURRENT=$(brightnessctl get)
MAX=$(brightnessctl max)
BRIGHTNESS_PERCENT=$(awk "BEGIN {printf \"%.0f\", $CURRENT * 100 / $MAX}")
notify-send -t 1500 -h string:x-canonical-private-synchronous:brightness -h int:value:$BRIGHTNESS_PERCENT "bright: ${BRIGHTNESS_PERCENT}%" "☀️"
