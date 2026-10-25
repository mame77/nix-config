#!/bin/bash

set -euo pipefail

focus_codex_window() {
    local window_id

    window_id="$(
        niri msg -j windows 2>/dev/null | python3 -c '
import json, sys
for window in json.load(sys.stdin):
    app_id = window.get("app_id", "")
    if app_id == "codex-desktop":
        print(window["id"])
        break
'
    )"

    if [ -n "$window_id" ]; then
        niri msg action focus-window --id "$window_id"
        return 0
    fi

    return 1
}

if focus_codex_window; then
    exit 0
fi

unset APPDIR GTK_IM_MODULE
export NIXOS_OZONE_WL=1
export CODEX_OZONE_PLATFORM=wayland
exec codex-desktop --new-window "$@"
