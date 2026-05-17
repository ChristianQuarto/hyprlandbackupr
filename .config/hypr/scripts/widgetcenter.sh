#!/usr/bin/env bash

THEME="$HOME/.config/rofi/widgetcenter/widgetcenter.rasi"
CACHE="$HOME/.cache/widgetcenter"
mkdir -p "$CACHE"

# ── Meteo ─────────────────────────────────────────────────────────────
get_weather() {
    local cache="$CACHE/weather.json"
    local cache_age=1800
    if [[ ! -f "$cache" ]] || [[ $(( $(date +%s) - $(stat -c %Y "$cache") )) -gt $cache_age ]]; then
        curl -s --max-time 5 "wttr.in/?format=j1" -o "$cache" 2>/dev/null &
    fi
    if [[ -f "$cache" ]]; then
        local temp=$(jq -r '.current_condition[0].temp_C' "$cache" 2>/dev/null)
        local desc=$(jq -r '.current_condition[0].weatherDesc[0].value' "$cache" 2>/dev/null)
        local feels=$(jq -r '.current_condition[0].FeelsLikeC' "$cache" 2>/dev/null)
        local humidity=$(jq -r '.current_condition[0].humidity' "$cache" 2>/dev/null)
        local city=$(jq -r '.nearest_area[0].areaName[0].value' "$cache" 2>/dev/null)
        local icon="󰖔"
        case "$desc" in
            *Sun*|*Clear*|*sunny*)      icon="󰖙" ;;
            *Cloud*|*Overcast*|*cloud*) icon="󰖐" ;;
            *Rain*|*Drizzle*|*rain*)    icon="󰖗" ;;
            *Snow*|*snow*)              icon="󰖘" ;;
            *Thunder*|*thunder*)        icon="󰖓" ;;
            *Fog*|*Mist*|*fog*)         icon="󰖑" ;;
        esac
        echo "$icon  $temp°C  ·  $desc  ·  Percepita $feels°C  ·  Umidità $humidity%  ·  $city"
    else
        echo "󰖔  Caricamento meteo..."
    fi
}

get_cpu() {
    local cpu=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$3+$4+$5)} END {printf "%.0f", usage}')
    local temp=$(sensors 2>/dev/null | grep "Tctl" | head -1 | awk '{print $2}' | tr -d '+°C' | cut -d'.' -f1)
    [[ -z "$temp" ]] && temp="N/A"
    echo "󰻠  CPU: ${cpu}%  ·  Temp: ${temp}°C"
}

get_ram() {
    local total=$(LC_ALL=C free -h | awk '/^Mem:/{print $2}')
    local used=$(LC_ALL=C free -h | awk '/^Mem:/{print $3}')
    local percent=$(LC_ALL=C free | awk '/^Mem:/{printf "%.0f", $3/$2*100}')
    echo "󰍛  RAM: $used / $total  ($percent%)"
}

get_disk() {
    local used=$(LC_ALL=C df -h / | awk 'NR==2{print $3}')
    local total=$(LC_ALL=C df -h / | awk 'NR==2{print $2}')
    local percent=$(LC_ALL=C df / | awk 'NR==2{print $5}')
    echo "󰋊  Disco: $used / $total  ($percent)"
}

get_uptime() {
    local up=$(uptime -p | sed 's/up //')
    echo "󰅐  Uptime: $up"
}

get_datetime() {
    echo "󰃰  $(date '+%A, %d %B %Y  ·  %H:%M')"
}

get_dnd() {
    local dnd=$(timeout 2 swaync-client -D 2>/dev/null)
    [[ "$dnd" == "true" ]] && echo "󰂛  Non disturbare: ON  →  Click per disattivare" || echo "󰂜  Non disturbare: OFF  →  Click per attivare"
}

get_notifications() {
    echo "󰂚  Notifiche  →  Apri pannello"
}

# ── Costruisci menu ───────────────────────────────────────────────────
WEATHER=$(get_weather)
CPU=$(get_cpu)
RAM=$(get_ram)
DISK=$(get_disk)
UPTIME=$(get_uptime)
DATETIME=$(get_datetime)
NOTIF=$(get_notifications)
DND=$(get_dnd)

SEP="──────────────────────────────────────────"

chosen=$(printf '%s\n' \
    "$DATETIME" \
    "$SEP" \
    "$WEATHER" \
    "$SEP" \
    "$CPU" \
    "$RAM" \
    "$DISK" \
    "$UPTIME" \
    "$SEP" \
    "$NOTIF" \
    "$DND" | rofi \
    -dmenu \
    -p "Widget Center" \
    -no-custom \
    -i \
    -theme "$THEME")

case "$chosen" in
    "$NOTIF") swaync-client --open-panel ;;
    "$DND")   swaync-client --toggle-dnd ;;
esac
