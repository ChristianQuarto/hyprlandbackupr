#!/bin/bash

case "$1" in
    "toggle"|"hide")
        # Toggle visibilità (SIGUSR1)
        killall -SIGUSR1 waybar
        ;;
    "reload"|"restart")
        # Ricarica completa
     killall waybar 
     waybar &
        ;;
    *)
        echo "Uso: $0 {toggle|reload}"
        ;;
esac
