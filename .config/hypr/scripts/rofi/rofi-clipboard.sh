#!/bin/bash
rofi -show clipboard -modi "drun,run,clipboard:cliphist list | rofi -dmenu | cliphist decode | wl-copy,window" -theme ~/.config/rofi/launcher/launcher.rasi
