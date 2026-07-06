#!/bin/bash
set -euo pipefail

REMOTE_HOST="server-raw"
REMOTE_PATH="~/ghq/github.com/mame77/obsidian-vault/"
MOUNT_POINT="/home/mame/mnt/obsidian-vault"

mkdir -p "$MOUNT_POINT"

if ! findmnt "$MOUNT_POINT" >/dev/null 2>&1; then
    sshfs "${REMOTE_HOST}:${REMOTE_PATH}" "$MOUNT_POINT" \
        -o reconnect \
        -o ServerAliveInterval=15 \
        -o ServerAliveCountMax=3
fi

exec obsidian "$MOUNT_POINT"
