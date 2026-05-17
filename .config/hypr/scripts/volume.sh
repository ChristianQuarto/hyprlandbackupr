#!/usr/bin/env bash

theme="$HOME/.config/rofi/volume/volume.rasi"

get_volume()     { wpctl get-volume @DEFAULT_AUDIO_SINK@   | awk '{printf "%d", $2*100}'; }
get_mic_volume() { wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{printf "%d", $2*100}'; }
is_muted()       { wpctl get-volume @DEFAULT_AUDIO_SINK@   | grep -q MUTED && echo "yes" || echo "no"; }
is_mic_muted()   { wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED && echo "yes" || echo "no"; }

show_menu() {
    vol=$(get_volume)
    mic=$(get_mic_volume)
    active=""
    urgent=""

    if [[ "$(is_muted)" == "no" ]]; then
        [ -n "$active" ] && active+=",0" || active="-a 0"
        sicon="󰕾"
    else
        [ -n "$urgent" ] && urgent+=",0" || urgent="-u 0"
        sicon="󰝟"
    fi

    if [[ "$(is_mic_muted)" == "no" ]]; then
        [ -n "$active" ] && active+=",3" || active="-a 3"
        micon=""
    else
        [ -n "$urgent" ] && urgent+=",3" || urgent="-u 3"
        micon=""
    fi

    mesg="🔊 Out: $vol%   🎙 Mic: $mic%"
    option_0="󰝟  Speaker Mute"
    option_1="󰝝  Speaker +5%"
    option_2="󰝞  Speaker -5%"
    option_3="󰍭  Mic Mute"
    option_4="󰢴  Mic +5%"
    option_5="󰢳  Mic -5%"
    option_6="󰒓  Output Device..."
    option_7="󰒓  Input Device..."

    chosen=$(echo -e "$option_0\n$option_1\n$option_2\n$option_3\n$option_4\n$option_5\n$option_6\n$option_7" | \
        rofi \
            -theme-str "listview {columns: 1; lines: 8;}" \
            -theme-str 'textbox-prompt-colon {str: "󰕾";}' \
            -dmenu \
            -p "Volume" \
            -mesg "$mesg" \
            ${active} ${urgent} \
            -theme "$theme")

    case "$chosen" in
        "$option_0")
            wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
            show_menu ;;
        "$option_1")
            wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
            show_menu ;;
        "$option_2")
            wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
            show_menu ;;
        "$option_3")
            wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
            show_menu ;;
        "$option_4")
            wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%+
            show_menu ;;
        "$option_5")
            wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-
            show_menu ;;
        "$option_6")
            select_sink ;;
        "$option_7")
            select_source ;;
    esac
}

select_sink() {
    local tmpfile=$(mktemp)

    pactl list sinks short | while IFS= read -r line; do
        name=$(echo "$line" | awk '{print $2}')
        # Nome leggibile
        case "$name" in
            *bluez*) label="AirPods Pro" ;;
            *hdmi*)  label="HDMI/DP Audio" ;;
            *analog*) label="Ryzen Analog Stereo" ;;
            *) label="$name" ;;
        esac
        echo "$name|$label"
    done > "$tmpfile"

    chosen=$(awk -F'|' '{print $2}' "$tmpfile" | rofi \
        -dmenu \
        -p "Output Device" \
        -theme "$theme" \
        -theme-str "listview {lines: 5;}")

    if [[ -n "$chosen" ]]; then
        sink_name=$(grep -F "|$chosen" "$tmpfile" | cut -d'|' -f1)
        [[ -n "$sink_name" ]] && pactl set-default-sink "$sink_name"
    fi

    rm -f "$tmpfile"
    show_menu
}
select_source() {
    local tmpfile=$(mktemp)

    pactl list sources short | grep -v monitor | while IFS= read -r line; do
        name=$(echo "$line" | awk '{print $2}')
        case "$name" in
            *bluez*)  label="AirPods Pro (Mic)" ;;
            *hdmi*)   label="HDMI Audio (Mic)" ;;
            *analog*) label="Ryzen Analog (Mic)" ;;
            *)        label="$name" ;;
        esac
        echo "$name|$label"
    done > "$tmpfile"

    [[ ! -s "$tmpfile" ]] && notify-send "Volume" "Nessun input trovato" && rm -f "$tmpfile" && show_menu && return

    chosen=$(awk -F'|' '{print $2}' "$tmpfile" | rofi \
        -dmenu \
        -p "Input Device" \
        -theme "$theme" \
        -theme-str "listview {lines: 5;}")

    if [[ -n "$chosen" ]]; then
        source_name=$(grep -F "|$chosen" "$tmpfile" | cut -d'|' -f1)
        [[ -n "$source_name" ]] && pactl set-default-source "$source_name"
    fi

    rm -f "$tmpfile"
    show_menu
}
show_menu
