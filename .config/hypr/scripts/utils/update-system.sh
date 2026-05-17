#!/bin/bash
source /etc/profile
source ~/.zshrc
sudo pacman -Syu
pkill -SIGRTMIN+8 waybar
