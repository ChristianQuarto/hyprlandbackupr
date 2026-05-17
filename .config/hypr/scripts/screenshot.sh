#!/usr/bin/env bash

THEME="$HOME/.config/rofi/screenshot/screenshot.rasi"
PICS="$HOME/Pictures/Screenshots"

option_0="󰹑  Schermo intero"
option_1="󰆞  Area / Annotazioni"
option_2="󰖯  Finestra attiva"

chosen=$(printf '%s\n' "$option_0" "$option_1" "$option_2" "$option_3" | rofi \
	-dmenu \
	-p "Screenshot" \
	-theme "$THEME" \
	-theme-str "listview {lines: 3;}")

NAME="Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"

case "$chosen" in
"$option_0")
	sleep 0.5
	if flameshot full -p "$PICS"; then
		notify-send "Screenshot eseguito!" "$NAME"
	fi

	;;
"$option_1")
	if flameshot gui -p "$PICS"; then
		notify-send "Screenshot eseguito!" "$NAME"
	fi
	;;
"$option_2")
	sleep 0.5
	if flameshot screen -p "$PICS"; then
		notify-send "Screenshot eseguito!" "$NAME"
	fi
	;;
esac
