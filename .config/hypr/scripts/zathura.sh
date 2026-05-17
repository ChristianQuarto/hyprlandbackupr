#!/bin/bash
# Script per generare zathurarc dai colori pywal

# Source del file colors.sh generato da pywal
source ~/.cache/wal/colors.sh

# Crea il file di configurazione per Zathura
cat > ~/.config/zathura/zathurarc.d/colors << EOF
# Colori generati da pywal - $(date)
# Zathura configuration with pywal colors
# This file will be generated from template
# General options
set adjust-open "best"
set pages-per-row 1
set scroll-page-aware "true"
set scroll-full-overlap 0.01
set scroll-step 100
set zoom-min 10
set guioptions ""
set window-title-home-tilde true
set window-height 800
set window-width 600

# Statusbar
set statusbar-bg "{color0}"
set statusbar-fg "{color7}"
set statusbar-home-tilde true
set statusbar-h-padding 2
set statusbar-v-padding 2

# Inputbar
set inputbar-bg "{color0}"
set inputbar-fg "{color7}"

# Notifications
set notification-bg "{color0}"
set notification-fg "{color7}"
set notification-error-bg "{color1}"
set notification-error-fg "{color7}"
set notification-warning-bg "{color3}"
set notification-warning-fg "{color0}"

# Completion (for search and command mode)
set completion-bg "{color0}"
set completion-fg "{color7}"
set completion-group-bg "{color8}"
set completion-group-fg "{color7}"
set completion-highlight-bg "{color2}"
set completion-highlight-fg "{color0}"

# Index (table of contents)
set index-bg "{color0}"
set index-fg "{color7}"
set index-active-bg "{color2}"
set index-active-fg "{color0}"

# Highlighting
set highlight-color "{color2}"
set highlight-active-color "{color4}"

# Recoloring (for dark mode)
set recolor "true"
set recolor-lightcolor "{background}"
set recolor-darkcolor "{foreground}"
set recolor-keephue "false"
set recolor-reverse-video "true"

# Rendering
set render-loading "true"
set font "Monospace 10"
set default-bg "{background}"
set default-fg "{foreground}"

# Rendering DPI
adjust-open dpi 120

EOF

echo "✅ Colori Zathura aggiornati!"
