#!/usr/bin/env bash
set -uo pipefail

# Colors
green()  { printf "\033[32m✓ %s\033[0m\n" "$*"; }
red()    { printf "\033[31m✗ %s\033[0m\n" "$*"; }
blue()   { printf "\033[34m→ %s\033[0m\n" "$*"; }
yellow() { printf "\033[33m⚠ %s\033[0m\n" "$*"; }

FAILED=0

check_cmd() {
  if command -v "$1" >/dev/null 2>&1; then
    green "$1 is installed"
    return 0
  else
    red "$1 is NOT installed"
    FAILED=1
    return 1
  fi
}

check_file() {
  if [[ -f "$1" ]]; then
    green "File exists: $1"
    return 0
  else
    red "File missing: $1"
    FAILED=1
    return 1
  fi
}

check_dir() {
  if [[ -d "$1" ]]; then
    green "Directory exists: $1"
    return 0
  else
    red "Directory missing: $1"
    FAILED=1
    return 1
  fi
}

echo ""
blue "=== Homebrew & Core Tools ==="
check_cmd brew
check_cmd git
check_cmd fzf
check_cmd zoxide
check_cmd rg
check_cmd fd
check_cmd eza
check_cmd bat
check_cmd jq
check_cmd yq
check_cmd direnv
check_cmd gh
check_cmd lazygit
check_cmd tmux
check_cmd btop
check_cmd starship

echo ""
blue "=== Node/Bun ==="
check_cmd volta
check_cmd node
check_cmd bun

echo ""
blue "=== Python ==="
check_cmd uv
if command -v uv >/dev/null 2>&1; then
  if uv python list | grep -q "3.12"; then
    green "Python 3.12 available via uv"
  else
    yellow "Python 3.12 not found via uv"
  fi
fi

echo ""
blue "=== Docker ==="
check_cmd docker
if docker version >/dev/null 2>&1; then
  green "Docker daemon is running"
else
  yellow "Docker daemon not running (OrbStack may need to start)"
fi

echo ""
blue "=== Terraform Tools ==="
check_cmd terraform
check_cmd tflint
check_cmd terraform-docs
check_cmd tfsec
check_cmd terragrunt
check_file "$HOME/.terraformrc"
check_dir "$HOME/.terraform.d/plugin-cache"

echo ""
blue "=== Applications ==="
[[ -d "/Applications/Ghostty.app" ]] && green "Ghostty installed" || yellow "Ghostty not found"
[[ -d "/Applications/Cursor.app" ]] && green "Cursor installed" || yellow "Cursor not found"
[[ -d "/Applications/Raycast.app" ]] && green "Raycast installed" || yellow "Raycast not found"
[[ -d "/Applications/OrbStack.app" ]] && green "OrbStack installed" || yellow "OrbStack not found"

echo ""
blue "=== Config Files ==="
check_file "$HOME/.zshrc"
check_file "$HOME/.zprofile"
check_file "$HOME/.tmux.conf"
check_file "$HOME/.gitignore_global"
check_file "$HOME/.editorconfig"
check_file "$HOME/.config/starship.toml"
check_file "$HOME/Library/Application Support/com.mitchellh.ghostty/config"

echo ""
blue "=== Cursor Configuration ==="
check_dir "$HOME/Library/Application Support/Cursor/User"
check_file "$HOME/Library/Application Support/Cursor/User/settings.json"
check_file "$HOME/Library/Application Support/Cursor/User/extensions.json"

echo ""
blue "=== Git Configuration ==="
GIT_NAME=$(git config --global user.name)
GIT_EMAIL=$(git config --global user.email)
if [[ "$GIT_NAME" == "Your Name" ]] || [[ -z "$GIT_NAME" ]]; then
  red "Git user.name not configured properly: '$GIT_NAME'"
  FAILED=1
else
  green "Git user.name: $GIT_NAME"
fi

if [[ "$GIT_EMAIL" == "you@example.com" ]] || [[ -z "$GIT_EMAIL" ]]; then
  red "Git user.email not configured properly: '$GIT_EMAIL'"
  FAILED=1
else
  green "Git user.email: $GIT_EMAIL"
fi

echo ""
blue "=== Zsh Configuration ==="
if grep -q '# >>> dotfiles managed >>>' "$HOME/.zshrc" 2>/dev/null; then
  green ".zshrc has managed block"
else
  red ".zshrc missing managed block"
  FAILED=1
fi

if grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
  green ".zprofile has Homebrew init"
else
  yellow ".zprofile missing Homebrew init"
fi

echo ""
blue "=== Zsh Plugins ==="
if [[ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  green "zsh-autosuggestions installed"
else
  red "zsh-autosuggestions missing"
  FAILED=1
fi

if [[ -f "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  green "zsh-syntax-highlighting installed"
else
  red "zsh-syntax-highlighting missing"
  FAILED=1
fi

echo ""
blue "=== PATH Check ==="
if [[ ":$PATH:" == *":/opt/homebrew/bin:"* ]] || [[ ":$PATH:" == *":/usr/local/bin:"* ]]; then
  green "Homebrew is in PATH"
else
  red "Homebrew NOT in PATH"
  FAILED=1
fi

if [[ ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
  green "~/.local/bin is in PATH (uv)"
else
  yellow "~/.local/bin NOT in PATH"
fi

if [[ ":$PATH:" == *":$HOME/.volta/bin:"* ]]; then
  green "~/.volta/bin is in PATH"
else
  yellow "~/.volta/bin NOT in PATH"
fi

echo ""
if [[ $FAILED -eq 0 ]]; then
  green "==================================="
  green "All checks passed! 🎉"
  green "==================================="
  echo ""
  echo "Next steps:"
  echo "  1. Restart your terminal (or run: source ~/.zshrc)"
  echo "  2. If Git user is still placeholder, run:"
  echo "     git config --global user.name 'Your Name'"
  echo "     git config --global user.email 'your@email.com'"
  echo ""
  exit 0
else
  red "==================================="
  red "Some checks failed!"
  red "==================================="
  echo ""
  echo "Try running the install script again:"
  echo "  ./install.sh"
  echo ""
  exit 1
fi

