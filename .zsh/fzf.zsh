# fzf config
export FZF_DEFAULT_OPTS="--height 70% --layout=reverse --border"

# preview directory
zstyle ':fzf-tab:complete:cd:*' fzf-preview \
'eza --color=always --tree --level=2 $realpath'

# preview file
zstyle ':fzf-tab:complete:cat:*' fzf-preview \
'bat --color=always $realpath'

# preview ls
zstyle ':fzf-tab:complete:ls:*' fzf-preview \
'eza --color=always $realpath'

# preview git
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
'git log --oneline -20 $word'

# key
bindkey '^I' fzf-tab-complete

