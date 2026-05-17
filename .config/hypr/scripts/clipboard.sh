#!/usr/bin/env bash

THEME="$HOME/.config/rofi/clipboard/clipboard.rasi"

if [ "$(ps aux | grep -c "cliphist")" -lt 2 ]; then
    notify-send "Clipboard" "cliphist non è in esecuzione"
    exit 1
fi

cliphist list | rofi \
    -dmenu \
    -i \
    -p "Clipboard" \
    -theme "$THEME" \
    -theme-str "listview {lines: 10;}" | \
    cliphist decode | wl-copy
