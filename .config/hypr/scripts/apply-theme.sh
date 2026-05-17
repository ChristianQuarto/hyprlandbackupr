#!/bin/bash
# Monitora settings.ini di GTK3 e sincronizza cursore/tema su Hyprland

SETTINGS="$HOME/.config/gtk-3.0/settings.ini"

sync_to_hyprland() {
    CURSOR=$(grep 'gtk-cursor-theme-name' "$SETTINGS" | cut -d= -f2 | tr -d ' ')
    CURSOR_SIZE=$(grep 'gtk-cursor-theme-size' "$SETTINGS" | cut -d= -f2 | tr -d ' ')
    GTK_THEME=$(grep 'gtk-theme-name' "$SETTINGS" | cut -d= -f2 | tr -d ' ')
    ICON_THEME=$(grep 'gtk-icon-theme-name' "$SETTINGS" | cut -d= -f2 | tr -d ' ')

    hyprctl setcursor "$CURSOR" "${CURSOR_SIZE:-24}"

    gsettings set org.gnome.desktop.interface cursor-theme  "$CURSOR"
    gsettings set org.gnome.desktop.interface cursor-size   "${CURSOR_SIZE:-24}"
    gsettings set org.gnome.desktop.interface gtk-theme     "$GTK_THEME"
    gsettings set org.gnome.desktop.interface icon-theme    "$ICON_THEME"
    gsettings set org.gnome.desktop.interface color-scheme  'prefer-dark'

    # Riavvia xsettingsd per propagare i cambiamenti alle app aperte
   

    sed -i "s/^env = XCURSOR_THEME.*/env = XCURSOR_THEME, ${CURSOR}/" ~/.config/hypr/hyprland.conf
    sed -i "s/^env = HYPRCURSOR_THEME.*/env = HYPRCURSOR_THEME, ${CURSOR}/" ~/.config/hypr/hyprland.conf
 pkill xsettingsd 2>/dev/null
    sleep 0.2
    xsettingsd &
}

# Prima sincronizzazione immediata
sync_to_hyprland

# Poi monitora i cambiamenti (inotifywait)
while inotifywait -e close_write "$SETTINGS" 2>/dev/null; do
    sleep 0.3   # piccola pausa per evitare race condition
    sync_to_hyprland
done
