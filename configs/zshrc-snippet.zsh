# >>> dotfiles managed >>>

# Ensure login profile is sourced (for PATH/Homebrew on macOS)
[[ -f ~/.zprofile ]] && source ~/.zprofile

# Keymap & colors
bindkey -e
autoload -U colors && colors
autoload -U compinit && compinit

# PATH priority
export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:$HOME/.volta/bin:$PATH"

# Prompt
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# Plugins (install via Homebrew: zsh-autosuggestions, zsh-syntax-highlighting)
if [[ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
if [[ -f "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# fzf, zoxide, direnv
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v direnv  >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# History
setopt AUTO_CD HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

# Aliases
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias cat='bat'
alias grep='rg'
alias ..='cd ..'
alias ...='cd ../..'
alias gs='git status -sb'
alias lg='lazygit'

# Editor
export EDITOR="cursor -w"

# fzf enhancements
if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_R_OPTS="--reverse --border"
fi

# Optional: uv auto-activate if .python-version exists
if [[ -f .python-version && -x "$(command -v uv)" ]]; then
  eval "$(uv activate zsh 2>/dev/null || true)"
fi

# Optional: Volta pin if .node-version exists
if [[ -f .node-version && -x "$(command -v volta)" ]]; then
  volta pin node@"$(cat .node-version)" >/dev/null 2>&1 || true
fi

# <<< dotfiles managed <<<

