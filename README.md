# macOS Development Setup

Automated setup script for a modern macOS development environment with beautiful terminal, modern tooling, and sane defaults.

## 🚀 Quick Start

```bash
git clone <your-repo-url> ~/setup
cd ~/setup
export GIT_NAME="Your Name"
export GIT_EMAIL="your@email.com"
./install.sh
```

After installation:
```bash
./verify.sh  # Check everything installed correctly
source ~/.zshrc  # Or restart your terminal
```

## 📦 What Gets Installed

### Development Tools
- **Homebrew** - Package manager
- **Git** + git-delta - Version control with beautiful diffs
- **Node.js** (via Volta) - JavaScript runtime with version management
- **Bun** - Fast JavaScript runtime and package manager
- **Python** (via uv) - Python version and package management
- **Docker** (via OrbStack) - Container runtime
- **Terraform** - Infrastructure as Code with full toolchain:
  - `terraform` - Core IaC tool for provisioning infrastructure
  - `tflint` - Linter for catching errors and enforcing best practices
  - `terraform-docs` - Generate documentation from Terraform modules
  - `tfsec` - Static analysis security scanner
  - `terragrunt` - DRY wrapper for managing multiple Terraform modules
  - Global plugin caching configured to speed up `terraform init`

### Command Line Tools
- **fzf** - Fuzzy finder (Ctrl+R for history search)
- **zoxide** - Smart cd replacement
- **ripgrep** (rg) - Fast grep alternative
- **fd** - Fast find alternative
- **eza** - Modern ls replacement with icons
- **bat** - cat with syntax highlighting
- **lazygit** - Beautiful git TUI
- **tmux** - Terminal multiplexer
- **btop** - System monitor
- **direnv** - Directory-based environment variables

### Applications
- **Ghostty** - Fast, feature-rich terminal with GPU acceleration
- **Cursor** - AI-powered code editor
- **Raycast** - Spotlight replacement
- **OrbStack** - Lightweight Docker & Linux machines

### Shell Enhancement
- **Starship** - Beautiful, fast prompt
- **zsh-autosuggestions** - Fish-like autosuggestions
- **zsh-syntax-highlighting** - Real-time syntax highlighting

## 🎨 Configuration

All configuration files are in the `configs/` directory:

```
configs/
├── zshrc-snippet.zsh      # Zsh configuration
├── starship.toml          # Prompt configuration
├── ghostty.config         # Terminal configuration
├── tmux.conf              # Terminal multiplexer
├── cursor-settings.json   # Editor settings
├── cursor-extensions.json # Editor extensions
├── gitignore_global       # Global git ignores
├── editorconfig           # Editor formatting rules
└── terraformrc            # Terraform plugin caching config
```

### Customizing

Edit any file in `configs/` and rerun `./install.sh` to apply changes. The script is idempotent (safe to run multiple times).

## ⌨️ Key Features

### Ghostty Terminal Keybindings

- **Navigation:**
  - `Ctrl+←/→` - Jump by word
  - `Cmd+←/→` - Jump to line start/end
  - `Ctrl+Shift+←/→` - Select by word
  - `Cmd+Shift+←/→` - Select to line start/end
  - `Cmd+↑/↓` - Scroll to top/bottom

- **Tabs:**
  - `Cmd+T` - New tab
  - `Cmd+Shift+]` - Next tab
  - `Cmd+Shift+[` - Previous tab

### Zsh Enhancements

- **`Ctrl+R`** - Fuzzy search command history (fzf)
- **`z <dir>`** - Jump to frequently used directories (zoxide)
- **Auto-suggestions** - Type to see suggestions from history
- **Syntax highlighting** - Commands turn green when valid

### Git Configuration

- Default branch: `main`
- Editor: Cursor
- Diff viewer: delta (if installed)
- Auto-squash and rerere enabled

## 🔧 Maintenance

### Update Homebrew Packages
```bash
brew update && brew upgrade
```

### Add New Packages
Edit `Brewfile`, then run:
```bash
brew bundle --file=./Brewfile
```

### Modify Shell Configuration
Edit `configs/zshrc-snippet.zsh`, then:
```bash
./install.sh  # Applies to new shells
source ~/.zshrc  # Apply to current shell
```

## 📋 Verify Installation

Run the verification script to check all components:
```bash
./verify.sh
```

This checks:
- ✅ All tools installed
- ✅ Config files in place
- ✅ PATH configured correctly
- ✅ Git identity set
- ✅ Applications installed

## 🎯 Design Principles

- **Idempotent** - Safe to run multiple times
- **Modular** - Easy to add/remove components
- **Modern** - Latest tools and best practices
- **Beautiful** - Catppuccin Mocha theme throughout
- **Fast** - Optimized for performance

## 📝 Notes

- First run may take 15-30 minutes depending on internet speed
- Xcode Command Line Tools will prompt for installation if needed
- OrbStack will launch but may take a moment to start Docker daemon
- Cursor extensions install best-effort (may require manual install)

## 🛠️ Troubleshooting

### Git identity not set
```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

### Docker not working
```bash
open -a OrbStack  # Ensure OrbStack is running
docker ps  # Test connection
```

### Cursor settings were overwritten
```bash
cp "$HOME/Library/Application Support/Cursor/User/settings.json.backup" \
   "$HOME/Library/Application Support/Cursor/User/settings.json"
```

## 🎨 Theme

Everything uses **Catppuccin Mocha** color scheme for consistency:
- Terminal (Ghostty)
- Prompt (Starship)
- Terminal multiplexer (tmux)
- Code editor (Cursor - via extensions)

## 📚 Resources

- [Ghostty Documentation](https://mitchellh.github.io/ghostty/)
- [Starship Configuration](https://starship.rs/config/)
- [Homebrew Formula Search](https://formulae.brew.sh/)
- [Catppuccin Theme](https://github.com/catppuccin)

