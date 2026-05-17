#!/usr/bin/env bash
theme='~/.config/rofi/launcher/launcher.rasi'

# Usa colori pywal se disponibili
if [[ -f "$HOME/.cache/wal/colors-rofi.rasi" ]]; then
    # Override colori nel theme con pywal
    COLORS="$HOME/.cache/wal/colors-rofi.rasi"
else
    COLORS="$HOME/.config/rofi/colors/shared.rasi"
fi

rofi \
    -show drun \
    -theme "${theme}" \
    -theme-str "@import \"${COLORS}\""
