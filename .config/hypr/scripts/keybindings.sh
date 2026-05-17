#!/bin/bash
source ~/.cache/wal/colors.sh
KEYBINDINGS_FILE="$HOME/.config/hypr/keybindings.conf"
ROFI_THEME="$HOME/.config/rofi/keybindings/keybindings.rasi"

# Mappa descrizioni per i comandi exec
describe_exec() {
  local cmd="$1"
  echo "$cmd" >>/tmp/keybinding_debug.txt
  case "$cmd" in
  *kitty*) echo "Terminale" ;;
  *firefox*) echo "Browser" ;;
  *thunar*) echo "File manager" ;;
  *launcher*) echo "App launcher" ;;
  *powermenu*) echo "Power menu" ;;
  *wallpaper_selector*) echo "Wallpaper selector" ;;
  *wifi*) echo "WiFi" ;;
  *bluetooth*) echo "Bluetooth" ;;
  *volume*) echo "Volume" ;;
  *screenshot*) echo "Screenshot schermo" ;;
  *hyprctl\ reload*) echo "Ricarica Hyprland" ;;
  *waybarcontrol*toggle*) echo "Nascondi/Mostra Waybar" ;;
  *waybarcontrol*reload*) echo "Ricarica Waybar" ;;
  *hyprshade*) echo "Blue light filter" ;;
  *hyprctl*exit*) echo "Esci da Hyprland" ;;
  *brightnessctl*+*) echo "Luminosità +" ;;
  *brightnessctl*-*) echo "Luminosità -" ;;
  *pactl*+*) echo "Volume +" ;;
  *pactl*-*) echo "Volume -" ;;
  *pactl*mute*) echo "Mute toggle" ;;
  *playerctl*play*) echo "Play/Pause" ;;
  *playerctl*next*) echo "Traccia successiva" ;;
  *playerctl*prev*) echo "Traccia precedente" ;;
  *keybindings*) echo "Mostra keybindings" ;;
  *rofi-run*) echo "Lancia applicazioni" ;;
  *rofi-clipboard*) echo "Mostra clipboard" ;;
  *rofi-window*) echo "Mostra finestre aperte" ;;
  *swaync*)      echo "Centro notifiche" ;;
  *) echo "$(basename $cmd)" ;;
  esac
}

section="Generale"

while IFS= read -r line; do
  # Aggiorna sezione
  if echo "$line" | grep -qE '^#.*──.*──'; then
    section=$(echo "$line" | sed 's/^#[[:space:]]*──[[:space:]]*//' | sed 's/[[:space:]]*─.*$//' | xargs)
    continue
  fi

  # Salta non-bind
  echo "$line" | grep -qE '^bind' || continue

  # Parsa con awk
  mods=$(echo "$line" | awk -F',' '{print $1}' | awk -F'=' '{print $2}' |
    sed 's/\$mod/Super/g; s/SHIFT/Shift/g; s/CTRL/Ctrl/g' | xargs)
  key=$(echo "$line" | awk -F',' '{print $2}' | xargs)
  action=$(echo "$line" | awk -F',' '{print $3}' | xargs)
  # ARG = tutto dopo il 3° campo (gestisce path con slash)
  arg=$(echo "$line" | cut -d',' -f4- | xargs)

  # Formatta combo
  [[ -n "$mods" ]] && combo="$mods + $key" || combo="$key"

  # Descrizione
  if [[ "$action" == "exec" ]]; then
    desc=$(describe_exec "$arg")
  else
    case "$action" in
    killactive) desc="Chiudi finestra" ;;
    fullscreen) desc="Fullscreen" ;;
    togglefloating) desc="Toggle floating" ;;
    togglesplit) desc="Toggle split" ;;
    movefocus) desc="Focus $(echo $arg | sed 's/l/←/;s/r/→/;s/u/↑/;s/d/↓/')" ;;
    movewindow) desc="Sposta finestra $(echo $arg | sed 's/l/←/;s/r/→/;s/u/↑/;s/d/↓/')" ;;
    resizeactive) desc="Ridimensiona ($arg)" ;;
    workspace) desc="Workspace $arg" ;;
    movetoworkspace) desc="Sposta a workspace $arg" ;;
    togglespecialworkspace) desc="Special workspace" ;;
    exit) desc="Esci da Hyprland" ;;
    *) desc="$action $arg" ;;
    esac
  fi

  printf "<span fgcolor='%s'>%-14s</span>  <b><span fgcolor='%s'>%-26s</span></b>  <span fgcolor='%s'>%s</span>\n" \
    "$color2" "[$section]" \
    "$color6" "$combo" \
    "$foreground" "$desc"

done <"$KEYBINDINGS_FILE" | rofi \
  -dmenu \
  -p "Keybindings" \
  -no-custom \
  -i \
  -mesg "  SEZIONE              COMBINAZIONE               AZIONE" \
  -theme "$ROFI_THEME" \
  -theme-str "listview {lines: 20;}"
