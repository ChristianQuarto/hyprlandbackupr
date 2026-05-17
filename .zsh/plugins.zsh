# path plugin personalizzati
ZSH_CUSTOM_PLUGINS="$HOME/.zsh/plugins"

# aggiungi completions
fpath+=("$ZSH_CUSTOM_PLUGINS/zsh-completions/src")

# autosuggestions
source "$ZSH_CUSTOM_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"

# syntax highlighting (DEVE essere l'ultimo)
source "$ZSH_CUSTOM_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh"

# history substring
source "$ZSH_CUSTOM_PLUGINS/zsh-history-substring-search/zsh-history-substring-search.plugin.zsh"

# fzf-tab
source "$ZSH_CUSTOM_PLUGINS/fzf-tab/fzf-tab.plugin.zsh"

# alias tips
#source "$ZSH_CUSTOM_PLUGINS/alias-tips/alias-tips.plugin.zsh"

plugins=(
git
sudo
extract
z
zsh-autosuggestions
zsh-syntax-highlighting
history-substring-search
zsh-completions
fzf-tab
alias-tips
colored-man-pages
)

