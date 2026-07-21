#!/usr/bin/env bash
set -uo pipefail

active=false

cleanup() {
    keyd bind reset 2>/dev/null || true
}
trap cleanup EXIT INT TERM HUP

while true; do
    app_id=$(niri msg -j focused-window 2>/dev/null | \
        python3 -c 'import json,sys; w=json.load(sys.stdin); print((w or {}).get("app_id",""))' 2>/dev/null || true)

    if [[ "$app_id" == "google-chrome" ]]; then
        if [[ "$active" != true ]]; then
            active=true
            keyd bind reset 'control.j=C-tab' 'control.k=C-S-tab' 2>/dev/null || true
        fi
    else
        if [[ "$active" != false ]]; then
            active=false
            keyd bind reset 2>/dev/null || true
        fi
    fi

    sleep 0.2
done
