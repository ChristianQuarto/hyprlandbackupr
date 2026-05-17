#!/bin/bash

STATUS=$(playerctl status 2>/dev/null)

if [[ -z "$STATUS" || "$STATUS" == "No players found" ]]; then
    echo "󰝛 Nothing playing..."
    exit 0
fi

TITLE=$(playerctl metadata title 2>/dev/null)
ARTIST=$(playerctl metadata artist 2>/dev/null)
PLAYER=$(playerctl metadata --format '{{playerName}}' 2>/dev/null)

case "$PLAYER" in
    spotify)   ICON="" ;;
    firefox)   ICON="" ;;
    *)         ICON="▶" ;;
esac

if [[ "$STATUS" == "Paused" ]]; then
    ICON=""
fi

if [[ -z "$TITLE" ]]; then
    echo "󰝛 Nothing playing..."
else
    echo "$ICON $TITLE $ARTIST"
fi
