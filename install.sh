#!/usr/bin/env bash
set -euo pipefail

purple() { printf "\033[35m%s\033[0m\n" "$*"; }
green()  { printf "\033[32m%s\033[0m\n" "$*"; }
warn()   { printf "\033[33m%s\033[0m\n" "$*"; }

# ----- Xcode CLT -----
purple "Checking Xcode Command Line Tools…"
xcode-select -p >/dev/null 2>&1 || xcode-select --install || true

# ----- Homebrew -----
purple "Ensuring Homebrew is installed…"
if ! command -v brew >/dev/null 2>&1; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"

# Persist to .zprofile
grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null || {
  {
    echo ''
    echo '# Homebrew'
    echo 'eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"'
  } >> "$HOME/.zprofile"
}

# ----- Brew bundle -----
purple "Running Brew Bundle…"
brew update
if [[ -f ./Brewfile ]]; then
  brew bundle --file="./Brewfile"
else
  warn "No Brewfile found in current directory. Skipping brew bundle."
fi

# fzf keybindings (guarded)
if [[ -x "$(brew --prefix)/opt/fzf/install" ]]; then
  "$(brew --prefix)"/opt/fzf/install --all --no-bash --no-fish --no-update-rc
fi

# ----- Node + Bun -----
purple "Setting up Node (Volta LTS) and Bun…"
if command -v volta >/dev/null 2>&1; then
  volta install node@lts || true
fi
command -v corepack >/dev/null 2>&1 && corepack enable || true
# Bun is installed via Brewfile

# ----- Python (uv) -----
purple "Installing uv…"
if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi
uv python install 3.12 >/dev/null 2>&1 || true
grep -q '# >>> uv init >>>' "$HOME/.zshrc" 2>/dev/null || {
  {
    echo ''
    echo '# >>> uv init >>>'
    echo 'export PATH="$HOME/.local/bin:$PATH"'
    echo '# <<< uv init <<<'
  } >> "$HOME/.zshrc"
}

# ----- Zsh config (managed block) -----
purple "Configuring Zsh…"
ZSHRC="$HOME/.zshrc"
if ! grep -q '# >>> dotfiles managed >>>' "$ZSHRC" 2>/dev/null; then
  cat >> "$ZSHRC" <<'ZRC'
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
ZRC
fi

# ----- Git sane defaults -----
purple "Setting Git defaults…"
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global push.default simple
git config --global core.editor "cursor -w"
git config --global color.ui auto
git config --global rebase.autosquash true
git config --global rerere.enabled true
git config --global user.name "Prathik"
git config --global user.email "prathikmalireddy@gmail.com"

# If git-delta is installed, wire it up
if command -v delta >/dev/null 2>&1; then
  git config --global core.pager "delta"
  git config --global delta.navigate true
  git config --global interactive.diffFilter "delta --color-only"
fi

# ----- Ghostty config -----
purple "Writing Ghostty config…"
GHOSTTY_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
mkdir -p "$GHOSTTY_DIR"
cat > "$GHOSTTY_DIR/config" <<'CFG'
theme = "Catppuccin Mocha"
font-family = "JetBrainsMonoNL Nerd Font"
font-size = 13
background-opacity = 0.9
background-blur = 24
cursor-style = "beam"
window-padding-x = 8
window-padding-y = 8
macos-option-as-alt = true
copy-on-select = false

# Warp-style quick nav
keybind = ctrl+left=esc:b
keybind = ctrl+right=esc:f
keybind = cmd+left=text:\x01
keybind = cmd+right=text:\x05

# Tabs
keybind = cmd+t=new_tab
keybind = shift+cmd+]=next_tab
keybind = shift+cmd+[=prev_tab
CFG

# ----- Cursor settings -----
purple "Configuring Cursor…"
CURSOR_USER="$HOME/Library/Application Support/Cursor/User"
mkdir -p "$CURSOR_USER"

# Backup existing settings if they exist
if [[ -f "$CURSOR_USER/settings.json" ]]; then
  warn "Backing up existing Cursor settings to settings.json.backup"
  cp "$CURSOR_USER/settings.json" "$CURSOR_USER/settings.json.backup"
fi

cat > "$CURSOR_USER/settings.json" <<'SET'
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "biomejs.biome",
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "workbench.iconTheme": "bearded-icons",

  "[python]": { "editor.defaultFormatter": "charliermarsh.ruff" },
  "ruff.lint.enable": true,
  "ruff.organizeImports": true,
  "ruff.importStrategy": "fromEnvironment",

  "[javascript]": { "editor.defaultFormatter": "biomejs.biome" },
  "[typescript]":  { "editor.defaultFormatter": "biomejs.biome" },
  "[json]":        { "editor.defaultFormatter": "biomejs.biome" }
}
SET

cat > "$CURSOR_USER/extensions.json" <<'EXT'
{
  "recommendations": [
    "biomejs.biome",
    "charliermarsh.ruff",
    "BeardedBear.beardedicons"
  ]
}
EXT

if command -v cursor >/dev/null 2>&1; then
  purple "Installing Cursor extensions (best-effort)…"
  cursor --install-extension biomejs.biome || true
  cursor --install-extension charliermarsh.ruff || true
  cursor --install-extension BeardedBear.beardedicons || true
else
  warn "Cursor CLI not found; skipped extension installs."
fi

# ----- Starship config -----
purple "Writing starship config…"
mkdir -p "$HOME/.config"
cat > "$HOME/.config/starship.toml" <<'STAR'
format = "$all"
add_newline = false
palette = "catppuccin_mocha"

[character]
success_symbol = "[❯](lavender)"
error_symbol   = "[❯](red)"
vimcmd_symbol  = "[❮](green)"

[directory]
truncation_length = 3
truncate_to_repo = true
style = "bold sapphire"

[git_branch]
symbol = " "
style = "mauve"
format = "[$symbol$branch]($style) "

[git_status]
style = "overlay0"
format = "([$all_status$ahead_behind]($style) )"

[nodejs]
symbol = " "
format = "[$symbol$version]($style) "
style = "green"
detect_files = ["package.json", "pnpm-workspace.yaml", "bun.lockb"]

[python]
symbol = " "
style = "yellow"
format = "[$symbol$version(\($virtualenv\))]($style) "

[bun]
symbol = " "
format = "[$symbol$version]($style) "
style = "teal"

[time]
disabled = false
time_format = "%H:%M"
format = "[$time]($style) "
style = "overlay0"

[palettes.catppuccin_mocha]
rosewater = "#f5e0dc"
flamingo  = "#f2cdcd"
pink      = "#f5c2e7"
mauve     = "#cba6f7"
red       = "#f38ba8"
maroon    = "#eba0ac"
peach     = "#fab387"
yellow    = "#f9e2af"
green     = "#a6e3a1"
teal      = "#94e2d5"
sky       = "#89dceb"
sapphire  = "#74c7ec"
blue      = "#89b4fa"
lavender  = "#b4befe"
text      = "#cdd6f4"
subtext0  = "#a6adc8"
overlay0  = "#6c7086"
surface0  = "#313244"
base      = "#1e1e2e"
mantle    = "#181825"
crust     = "#11111b"
STAR

# ----- tmux config -----
purple "Writing tmux config…"
cat > "$HOME/.tmux.conf" <<'TMUX'
set -g default-terminal "tmux-256color"
set -as terminal-overrides ',xterm-256color:RGB'
set -g mouse on
set -g history-limit 100000
set-option -g set-clipboard on

# Prefix to Ctrl-a; keep Ctrl-b as secondary
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Splits
bind | split-window -h
bind - split-window -v
unbind '"'
unbind %

# Navigation
bind -n M-Left  select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up    select-pane -U
bind -n M-Down  select-pane -D
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Resize
bind -n M-S-Left  resize-pane -L 5
bind -n M-S-Right resize-pane -R 5
bind -n M-S-Up    resize-pane -U 2
bind -n M-S-Down  resize-pane -D 2

# Reload
bind r source-file ~/.tmux.conf \; display-message "tmux reloaded"

# Catppuccin Mocha palette
set -g @rosewater '#f5e0dc'
set -g @flamingo  '#f2cdcd'
set -g @pink      '#f5c2e7'
set -g @mauve     '#cba6f7'
set -g @red       '#f38ba8'
set -g @maroon    '#eba0ac'
set -g @peach     '#fab387'
set -g @yellow    '#f9e2af'
set -g @green     '#a6e3a1'
set -g @teal      '#94e2d5'
set -g @sky       '#89dceb'
set -g @sapphire  '#74c7ec'
set -g @blue      '#89b4fa'
set -g @lavender  '#b4befe'
set -g @text      '#cdd6f4'
set -g @subtext0  '#a6adc8'
set -g @overlay0  '#6c7086'
set -g @surface0  '#313244'
set -g @base      '#1e1e2e'
set -g @mantle    '#181825'
set -g @crust     '#11111b'

# Statusline
set -g status on
set -g status-position bottom
set -g status-interval 5
set -g status-justify centre
set -g status-style "bg=#{@mantle},fg=#{@subtext0}"

set -g status-left-length 40
set -g status-right-length 120
set -g status-left  "#[fg=#{@mauve},bold]#S #[fg=#{@overlay0}]• #[fg=#{@sky}]#I:#P "
set -g status-right "#[fg=#{@overlay0}]#(whoami) #[fg=#{@overlay0}]• #[fg=#{@green}]#(tmux display -p '#{session_attached}'):att #[fg=#{@overlay0}]• #[fg=#{@peach}]#(date '+%H:%M') #[fg=#{@overlay0}]• #[fg=#{@blue}]#(uname -sr)"

setw -g window-status-format           " #[fg=#{@overlay0}]#I #[fg=#{@subtext0}]#W "
setw -g window-status-current-format   " #[bg=#{@surface0},fg=#{@lavender},bold] #I #[fg=#{@text}]#W #[default]"
setw -g window-status-separator ""

# Borders & messages
set -g pane-border-style "fg=#{@surface0}"
set -g pane-active-border-style "fg=#{@lavender}"
set -g message-style "bg=#{@surface0},fg=#{@text}"
set -g mode-style    "bg=#{@surface0},fg=#{@mauve}"
TMUX

# ----- OrbStack -----
purple "Launching OrbStack…"
open -gj "/Applications/OrbStack.app" || true
if ! docker version >/dev/null 2>&1; then
  warn "Docker CLI not connected yet. After OrbStack starts, 'docker ps' should work."
fi

# ----- Global gitignore -----
purple "Writing global gitignore…"
cat > "$HOME/.gitignore_global" <<'GIT'
# OS / Editor cruft
.DS_Store
.AppleDouble
.LSOverride
Thumbs.db
ehthumbs.db
Icon?
*.swp
*.swo
*.tmp
*.bak
*~

# Node / Bun
node_modules/
bun.lockb
.pnpm-store/
.npm/
dist/
build/
.cache/
.next/
out/
coverage/
.env
.env.local
.env.*.local

# Python / uv
__pycache__/
*.py[cod]
*.egg-info/
.env/
.venv/
venv/
.uv/

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
bun-debug.log*
pids/
*.pid

# IDEs
.vscode/
.idea/
.cursor/
.history/
*.code-workspace

# Temp & metadata
tmp/
temp/
._*
.Trashes
GIT

git config --global core.excludesfile "$HOME/.gitignore_global"

# ----- EditorConfig -----
purple "Writing .editorconfig…"
cat > "$HOME/.editorconfig" <<'ECONF'
root = true

[*]
charset = utf-8
indent_style = space
indent_size = 2
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.py]
indent_size = 4
max_line_length = 88

[*.json]
indent_size = 2

[*.yml]
indent_size = 2

[*.md]
trim_trailing_whitespace = false

[Makefile]
indent_style = tab
ECONF

green "✅ Finished. Open a new terminal or run: source ~/.zshrc"
