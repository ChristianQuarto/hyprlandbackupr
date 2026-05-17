#!/bin/bash

# Aspetta che pywal abbia generato i colori
sleep 0.5

source ~/.cache/wal/colors.sh

IMAGE="${1:-$HOME/.cache/current_wallpaper}"

cat >~/.config/rofi/colors/shared.rasi <<RASI
* {
    background:     ${background};
    background-alt: ${color8};
    foreground:     ${foreground};
    selected:       ${color1};
    active:         ${color2};
    urgent:         ${color3};
}
RASI

cat >~/.config/rofi/colors/shared_image.rasi <<RASI
imagebox {
    padding: 20px;
    background-color: transparent;
    background-image: url("${IMAGE}", height);
    orientation: vertical;
    children: [ "inputbar", "dummy", "mode-switcher" ];
}
RASI

echo "✓ Rofi colors aggiornati"
