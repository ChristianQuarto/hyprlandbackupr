#!/bin/bash
# ── WALLPAPER + PYWAL ─────────────────────────────────────────────────
WALL_DIR="$HOME/.config/hypr/wallpapers"
CACHE_FILE="$HOME/.cache/current_wallpaper"
OBSIDIAN_VAULT="$HOME/Obsidian"
SCRIPTS_DIR="$HOME/.config/hypr/scripts"
# ── Usa argomento o ultima wallpaper ─────────────────────────────────
if [[ -n "$1" ]]; then
  WALL="$1"
  #elif [[ -f "$CACHE_FILE" ]]; then
  #    WALL=$(cat "$CACHE_FILE")
  # Verifica che il file esista ancora
  #  [[ ! -f "$WALL" ]] && WALL=""
fi

# Fallback: prima wallpaper disponibile
if [[ -z "$WALL" ]]; then
  WALL=$(find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \
    -o -iname "*.gif" -o -iname "*.mp4" -o -iname "*.webm" \) | shuf -n 1)
fi

[[ -z "$WALL" ]] && {
  echo "Nessuna wallpaper trovata in $WALL_DIR"
  exit 1
}

# Salva in cache
echo "$WALL" >"$CACHE_FILE"

echo "Applicando: $WALL"

# ── Applica wallpaper ─────────────────────────────────────────────────
EXT="${WALL##*.}"
EXT="${EXT,,}"

case "$EXT" in
mp4 | webm | mkv)
  pkill mpvpaper 2>/dev/null
  pkill awww 2>/dev/null
  mpvpaper -o "no-audio loop" '*' "$WALL" &
  FRAME="/tmp/wallpaper_frame.png"
  ffmpeg -i "$WALL" -vframes 1 -q:v 2 "$FRAME" -y 2>/dev/null
  WAL_INPUT="$FRAME"
  ;;
gif)
 pkill mpvpaper 2>/dev/null
  pkill awww-daemon 2>/dev/null  # ← aggiungi questo
  pkill awww 2>/dev/null         # ← e questo
  sleep 0.5
  awww-daemon &
  sleep 0.3
  awww img "$WALL" --transition-type fade --transition-duration 1
  FRAME="/tmp/wallpaper_frame.png"
  convert "$WALL[0]" "$FRAME" 2>/dev/null
  WAL_INPUT="$FRAME"
  ;;
jpg | jpeg | png | webp)
 pkill mpvpaper 2>/dev/null
  pkill awww-daemon 2>/dev/null
  pkill awww 2>/dev/null
  sleep 0.5  # aspetta che rilascino il display

  # Rilancia pulito
  awww-daemon &
  sleep 0.3  # dagli tempo di avviarsi

  awww img "$WALL" --transition-type fade --transition-duration 1
  WAL_INPUT="$WALL"
  ;;
*)
  echo "Formato non supportato: $EXT"
  exit 1
  ;;
esac

# ── Genera colori con pywal ───────────────────────────────────────────
rm -rf ~/.cache/wal/schemes
wpg -s "$WAL_INPUT" -n 2>/dev/null || wal -i "$WAL_INPUT" -n 2>/dev/null
gsettings set org.gnome.desktop.interface gtk-theme 'FlatColor'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# ── Aggiorna colori hyprland ──────────────────────────────────────────
sleep 0.1
"$SCRIPTS_DIR/hypr_theme.sh"
hyprctl reload
# ── Ricarica waybar e aggiorna ───────────────────────────────────────────────────
quickshell ipc call reload colors 2>/dev/null || true
pkill quickshell
quickshell &


# ── Aggiorna colori rofi ────────────────────────────────────────────────────
if [[ -f "$HOME/.cache/wal/colors.sh" ]]; then
  "$SCRIPTS_DIR/rofi/rofi_theme.sh" "$WAL_INPUT"
fi
#source ~/.zshrc
"$SCRIPTS_DIR/starship_theme.sh"
# Manda segnale a tutte le zsh aperte
# Manda USR1 a tutti i zsh tranne la catena parent di questo script
_zsh_pids=$(pgrep -x zsh)
_pid=$$
while [[ $_pid -gt 1 ]]; do
    _zsh_pids=$(echo "$_zsh_pids" | grep -v "^$_pid$")
    _pid=$(ps -o ppid= -p $_pid 2>/dev/null | tr -d ' ')
done
echo "$_zsh_pids" | xargs -r kill -USR1 2>/dev/null || true

"$SCRIPTS_DIR/obsidian/obsidian.sh" "$OBSIDIAN_VAULT"
"$SCRIPTS_DIR/hypr_theme.sh"
#wpg -s "$WAL_INPUT"
# Nel wallpaper.sh, dopo wal:

rm -rf ~/.cache/wal/schemes

echo "✓ Wallpaper applicata: $WALL"
