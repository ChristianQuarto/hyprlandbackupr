#!/usr/bin/env bash

theme="$HOME/.config/rofi/mediaplayer/mediaplayer.rasi"
CACHE_DIR="$HOME/.cache/rofi-mediaplayer"
mkdir -p "$CACHE_DIR"

get_meta() {
    PLAYER=$(playerctl --list-all 2>/dev/null | head -1)
    [[ -z "$PLAYER" ]] && return
    TITLE=$(playerctl -p "$PLAYER" metadata --format '{{xesam:title}}' 2>/dev/null)
    ARTIST=$(playerctl -p "$PLAYER" metadata --format '{{xesam:artist}}' 2>/dev/null)
    ALBUM=$(playerctl -p "$PLAYER" metadata --format '{{xesam:album}}' 2>/dev/null)
    ART_URL=$(playerctl -p "$PLAYER" metadata --format '{{mpris:artUrl}}' 2>/dev/null)
    STATUS=$(playerctl -p "$PLAYER" status 2>/dev/null)
    POS=$(playerctl -p "$PLAYER" metadata --format '{{duration(position)}}' 2>/dev/null)
    DUR=$(playerctl -p "$PLAYER" metadata --format '{{duration(mpris:length)}}' 2>/dev/null)
    POS_SEC=$(playerctl -p "$PLAYER" position 2>/dev/null | cut -d'.' -f1)
    DUR_SEC=$(( $(playerctl -p "$PLAYER" metadata mpris:length 2>/dev/null) / 1000000 ))
}

get_progress_bar() {
    local pos=$1
    local dur=$2
    local width=30

    [[ -z "$pos" || -z "$dur" || "$dur" -eq 0 ]] && printf '▱%.0s' $(seq 1 $width) && return
    [[ "$pos" -ge "$dur" ]] && pos=$dur

    local filled=$(( pos * width / dur ))
    local empty=$(( width - filled ))
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="▰"; done
    for ((i=0; i<empty; i++)); do bar+="▱"; done
    echo "$bar"
}

get_cover() {
    COVER="$CACHE_DIR/cover.png"
    local prev_url_file="$CACHE_DIR/last_url"
    local prev_url=""
    [[ -f "$prev_url_file" ]] && prev_url=$(cat "$prev_url_file")

    if [[ "$ART_URL" != "$prev_url" ]] || [[ ! -f "$COVER" ]]; then
        echo "$ART_URL" > "$prev_url_file"
        if [[ "$ART_URL" == file://* ]]; then
            convert "${ART_URL#file://}" -resize 396x180^ -gravity Center -extent 396x180 "$COVER" 2>/dev/null
        elif [[ "$ART_URL" == http* ]]; then
            curl -s "$ART_URL" -o "$CACHE_DIR/raw.jpg" 2>/dev/null
            convert "$CACHE_DIR/raw.jpg" -resize 396x180^ -gravity Center -extent 396x180 "$COVER" 2>/dev/null
        else
            convert -size 396x180 xc:'#1e1e2e' -fill '#cba6f7' -pointsize 60 -gravity center -annotate 0 '󰎁' "$COVER" 2>/dev/null
        fi
    fi
}

show_menu() {
    get_meta
    [[ -z "$PLAYER" ]] && rofi -e "󰝛 Nessun player attivo" -theme "$theme" && return

    get_cover

    [[ "$STATUS" == "Playing" ]] && status_icon="" || status_icon=""
    [[ -n "$ALBUM" ]] && album_info="󰀥 $ALBUM" || album_info=" Singolo"
    [[ ${#TITLE} -gt 38 ]] && TITLE="${TITLE:0:38}..."

    PROGRESS=$(get_progress_bar "$POS_SEC" "$DUR_SEC")

    # mesg su righe separate con printf
    MESG=$(printf "%s\n%s\n%s\n%s\n%s / %s" \
        " $TITLE" \
        "󰋎 $ARTIST" \
        "$album_info" \
        "$PROGRESS" \
        "$POS" "$DUR")

    option_0="󰒮"
    option_1="$status_icon"
    option_2="󰒭"
    option_3=""
   
    option_4="󰍰"

    chosen=$(printf '%s\n' "$option_0" "$option_1" "$option_2" "$option_3" "$option_4" | \
        rofi \
            -dmenu \
            -p "" \
            -mesg "$MESG" \
            -theme "$theme" \
            -theme-str "listview {columns: 5; lines: 1;}" \
            -theme-str "window {width: 400px;}")

    case "$chosen" in
        "$option_0") playerctl -p "$PLAYER" previous   ; show_menu ;;
        "$option_1") playerctl -p "$PLAYER" play-pause ; show_menu ;;
        "$option_2") playerctl -p "$PLAYER" next        ; show_menu ;;
        "$option_3") playerctl -p "$PLAYER" stop ;;
        "$option_4") show_lyrics ;;
    esac
}

show_lyrics() {
    get_meta
    QUERY=$(echo "$ARTIST $TITLE" | sed 's/ /+/g')
    xdg-open "https://genius.com/search?q=$QUERY" &
    show_menu
}

show_menu
