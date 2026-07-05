#!/bin/bash

output_dir="/home/mame/Videos"
screenrecording() {
  filename="$output_dir/recording-$(date +'%y-%m-%d_%H-%M-%S').mp4"
  notify-send "recording starting" -t 1000
  sleep 1

  if command -v wf-recorder >/dev/null && command -v wl-screenrec >/dev/null; then
    if lspci | grep -Eqi 'nvidia|intel.*graphics'; then
      wf-recorder -f "$filename" -c libx264 -p crf=23 -p preset=medium -p movflags=+faststart "$@"
    else
      wl-screenrec -f "$filename" --ffmpeg-encoder-options="-c:v libx264 -crf 23 -preset medium -movflags +faststart" "$@"
    fi
  elif command -v wf-recorder >/dev/null; then
    wf-recorder -f "$filename" -c libx264 -p crf=23 -p preset=medium -p movflags=+faststart "$@"
  elif command -v wl-screenrec >/dev/null; then
    wl-screenrec -f "$filename" --ffmpeg-encoder-options="-c:v libx264 -crf 23 -preset medium -movflags +faststart" "$@"
  else
    notify-send "screen recording failed: wf-recorder/wl-screenrec not found" -t 2000
    exit 1
  fi
}
if pgrep -x wl-screenrec >/dev/null || pgrep -x wf-recorder >/dev/null; then
  pkill -x wl-screenrec
  pkill -x wf-recorder
  notify-send "recording saved!" -t 2000
else
  screenrecording
fi
