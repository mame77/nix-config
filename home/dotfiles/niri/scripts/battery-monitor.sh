#!/bin/bash

FLAG_FILE="/tmp/battery_warned"
while true; do
    BATTERY_PATH="/sys/class/power_supply/BAT0"
    if [ ! -d "$BATTERY_PATH" ]; then
        BATTERY_PATH="/sys/class/power_supply/BAT1"
    fi
    if [ -d "$BATTERY_PATH" ]; then
        CAPACITY=$(cat "$BATTERY_PATH/capacity")
        STATUS=$(cat "$BATTERY_PATH/status")
        if [ "$STATUS" = "Charging" ] || [ "$STATUS" = "Full" ]; then
            rm -f "$FLAG_FILE"
        elif [ "$CAPACITY" -le 15 ] && [ "$STATUS" = "Discharging" ]; then
            if [ ! -f "$FLAG_FILE" ]; then
                if [ "$CAPACITY" -le 5 ]; then
                    notify-send -u critical "🔋 BatteryCapacity: ${CAPACITY}%" "batteryChargingNow!" -t 10000
                elif [ "$CAPACITY" -le 10 ]; then
                    notify-send -u critical "🔋 BatteryCapacity: ${CAPACITY}%" "Worning!LowBattery" -t 5000
                else
                    notify-send -u normal "🔋 BatteryCapacity: ${CAPACITY}%" "LowBattery" -t 3000
                fi
                touch "$FLAG_FILE"
            fi
        elif [ "$CAPACITY" -gt 16 ]; then
            rm -f "$FLAG_FILE"
        fi
    fi
    sleep 60
done
