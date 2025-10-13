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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if ! grep -q '# >>> dotfiles managed >>>' "$ZSHRC" 2>/dev/null; then
  if [[ -f "$SCRIPT_DIR/configs/zshrc-snippet.zsh" ]]; then
    cat "$SCRIPT_DIR/configs/zshrc-snippet.zsh" >> "$ZSHRC"
  else
    warn "configs/zshrc-snippet.zsh not found, skipping zsh config"
  fi
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
if [[ -f "$SCRIPT_DIR/configs/ghostty.config" ]]; then
  cp "$SCRIPT_DIR/configs/ghostty.config" "$GHOSTTY_DIR/config"
else
  warn "configs/ghostty.config not found, skipping ghostty config"
fi

# ----- Cursor settings -----
purple "Configuring Cursor…"
CURSOR_USER="$HOME/Library/Application Support/Cursor/User"
mkdir -p "$CURSOR_USER"

# Backup existing settings if they exist
if [[ -f "$CURSOR_USER/settings.json" ]]; then
  warn "Backing up existing Cursor settings to settings.json.backup"
  cp "$CURSOR_USER/settings.json" "$CURSOR_USER/settings.json.backup"
fi

if [[ -f "$SCRIPT_DIR/configs/cursor-settings.json" ]]; then
  cp "$SCRIPT_DIR/configs/cursor-settings.json" "$CURSOR_USER/settings.json"
else
  warn "configs/cursor-settings.json not found, skipping cursor settings"
fi

if [[ -f "$SCRIPT_DIR/configs/cursor-extensions.json" ]]; then
  cp "$SCRIPT_DIR/configs/cursor-extensions.json" "$CURSOR_USER/extensions.json"
else
  warn "configs/cursor-extensions.json not found, skipping cursor extensions"
fi

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
if [[ -f "$SCRIPT_DIR/configs/starship.toml" ]]; then
  cp "$SCRIPT_DIR/configs/starship.toml" "$HOME/.config/starship.toml"
else
  warn "configs/starship.toml not found, skipping starship config"
fi

# ----- tmux config -----
purple "Writing tmux config…"
if [[ -f "$SCRIPT_DIR/configs/tmux.conf" ]]; then
  cp "$SCRIPT_DIR/configs/tmux.conf" "$HOME/.tmux.conf"
else
  warn "configs/tmux.conf not found, skipping tmux config"
fi

# ----- OrbStack -----
purple "Launching OrbStack…"
open -gj "/Applications/OrbStack.app" || true
if ! docker version >/dev/null 2>&1; then
  warn "Docker CLI not connected yet. After OrbStack starts, 'docker ps' should work."
fi

# ----- Global gitignore -----
purple "Writing global gitignore…"
if [[ -f "$SCRIPT_DIR/configs/gitignore_global" ]]; then
  cp "$SCRIPT_DIR/configs/gitignore_global" "$HOME/.gitignore_global"
  git config --global core.excludesfile "$HOME/.gitignore_global"
else
  warn "configs/gitignore_global not found, skipping global gitignore"
fi

# ----- EditorConfig -----
purple "Writing .editorconfig…"
if [[ -f "$SCRIPT_DIR/configs/editorconfig" ]]; then
  cp "$SCRIPT_DIR/configs/editorconfig" "$HOME/.editorconfig"
else
  warn "configs/editorconfig not found, skipping editorconfig"
fi

green "✅ Finished. Open a new terminal or run: source ~/.zshrc"
