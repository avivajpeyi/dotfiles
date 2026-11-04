# macOS already includes Zsh. Keep the shell small and quick to start.
[[ -o interactive ]] || return 0

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY
setopt AUTO_CD

autoload -Uz compinit
compinit

[[ -f "$HOME/.zsh_aliases" ]] && source "$HOME/.zsh_aliases"
[[ -f "$HOME/.zsh_functions" ]] && source "$HOME/.zsh_functions"

if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
fi
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
if command -v uv >/dev/null 2>&1; then
  eval "$(uv generate-shell-completion zsh)"
fi
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
