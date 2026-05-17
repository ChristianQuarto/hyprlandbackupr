autoload -Uz compinit
compinit

# gruppi
zstyle ':completion:*' group-name ''

# descrizioni
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '[%d]'

# menu
zstyle ':completion:*' menu select

# fuzzy match
zstyle ':completion:*' matcher-list \
'm:{a-z}={A-Za-z}' \
'r:|=*' \
'l:|=* r:|=*'

# colori
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh

