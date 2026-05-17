#!/bin/bash
SOCK="/tmp/mpv-wallpaper.sock"
NEW_WALL="$1"
FADE_FRAMES=30  # 30 frame @ 30fps = 1 secondo

mpv_cmd() {
  echo "$1" | socat - "$SOCK" 2>/dev/null
}

# Se mpvpaper è già attivo → transizione via socket
if [[ -S "$SOCK" ]]; then
  # Fade out
  mpv_cmd '{ "command": ["set_property", "vf", "lavfi=[fade=out:0:'"$FADE_FRAMES"']"] }'
  sleep 0.6

  # Carica nuovo file
  mpv_cmd '{"command": ["loadfile", "'"$NEW_WALL"'", "replace"]}'
  sleep 0.3

  # Fade in
  mpv_cmd '{ "command": ["set_property", "vf", "lavfi=[fade=in:0:'"$FADE_FRAMES"']"] }'

else
  # Prima volta — avvia da zero
  pkill mpvpaper 2>/dev/null
  sleep 0.2
  mpvpaper -o "no-audio loop input-ipc-server=$SOCK" '*' "$NEW_WALL" &
fi
