#!/bin/zsh
# Dotfiles initialization script
# Sets up symlinks and checks dependencies

set -e

# Helper function to create symlink idempotently
# Usage: link_file <source> <target> <name>
link_file() {
  local src="$1"
  local dst="$2"
  local name="$3"
  
  if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
    print "  ✓ $name (already linked)"
    return 0
  fi
  
  ln -sf "$src" "$dst"
  print "  ✓ $name"
}

print "Setting up dotfiles..."
print ""

# Create backup directory with timestamp
local BACKUP_DIR="$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
print "📁 Backup directory: $BACKUP_DIR"
print ""

# Create necessary directories
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.config/zsh.local"
mkdir -p "$HOME/.config/zsh.local/alias"
mkdir -p "$HOME/.config/zsh.local/completions"

# Link neovim configuration
if [[ -d "$HOME/.config/nvim" ]] && [[ ! -L "$HOME/.config/nvim" ]]; then
  mv "$HOME/.config/nvim" "$BACKUP_DIR/nvim"
  print "  📦 Backed up existing nvim config"
fi
rm -rf "$HOME/.config/nvim"
link_file "$PWD/nvim" "$HOME/.config/nvim" "nvim"

# Link tmux configuration
link_file "$PWD/tmux/tmux.conf" "$HOME/.tmux.conf" "tmux"

# Link ghostty configuration
if [[ -d "$HOME/.config/ghostty" ]] && [[ ! -L "$HOME/.config/ghostty" ]]; then
  mv "$HOME/.config/ghostty" "$BACKUP_DIR/ghostty"
  print "  📦 Backed up existing ghostty config"
fi
rm -rf "$HOME/.config/ghostty"
link_file "$PWD/ghostty" "$HOME/.config/ghostty" "ghostty"

# Link zsh configuration (map friendly repo names to standard dotfile names)
link_file "$PWD/zsh/env.zsh" "$HOME/.zshenv" "zshenv"
link_file "$PWD/zsh/profile.zsh" "$HOME/.zprofile" "zprofile"
link_file "$PWD/zsh/rc.zsh" "$HOME/.zshrc" "zshrc"

if [[ -d "$HOME/.config/zsh" ]] && [[ ! -L "$HOME/.config/zsh" ]]; then
  mv "$HOME/.config/zsh" "$BACKUP_DIR/zsh"
  print "  📦 Backed up existing zsh config"
fi
rm -rf "$HOME/.config/zsh"
link_file "$PWD/zsh" "$HOME/.config/zsh" "zsh"

# Link git configuration
if [[ -r "$PWD/git/gitconfig" ]]; then
  link_file "$PWD/git/gitconfig" "$HOME/.gitconfig" "git"
  
  # Check if local gitconfig exists
  if [[ ! -r "$HOME/.config/git/config.local" ]]; then
    print ""
    print "⚠️  Local git config not found. Run this to set it up:"
    print "  setup-git-local"
    print ""
  fi
fi

# Link gpg configuration
mkdir -p "$HOME/.gnupg"
chmod 700 "$HOME/.gnupg"
if [[ -r "$PWD/git/gpg.conf" ]]; then
  link_file "$PWD/git/gpg.conf" "$HOME/.gnupg/gpg.conf" "gpg"
fi

# Link helper scripts
link_file "$PWD/bin/wb" "$HOME/.local/bin/wb" "wb"
link_file "$PWD/bin/dotfiles-doctor" "$HOME/.local/bin/dotfiles-doctor" "dotfiles-doctor"
link_file "$PWD/bin/dotfiles-uninstall" "$HOME/.local/bin/dotfiles-uninstall" "dotfiles-uninstall"
link_file "$PWD/scripts/zsh-dotfiles" "$HOME/.local/bin/zsh-dotfiles" "zsh-dotfiles"
link_file "$PWD/scripts/check-deps" "$HOME/.local/bin/check-deps" "check-deps"
link_file "$PWD/scripts/macos-defaults" "$HOME/.local/bin/macos-defaults" "macos-defaults"
link_file "$PWD/scripts/setup-git-local" "$HOME/.local/bin/setup-git-local" "setup-git-local"
link_file "$PWD/scripts/setup-ssh" "$HOME/.local/bin/setup-ssh" "setup-ssh"

# Check if SSH keys are set up
if [[ ! -f "$HOME/.ssh/id_rsa" ]]; then
  print ""
  print "⚠️  SSH keys not found. Run this to set them up:"
  print "  setup-ssh"
  print ""
fi

# Check and install dependencies
print ""
if [[ -x "$PWD/scripts/check-deps" ]]; then
  if ! zsh "$PWD/scripts/check-deps" "$PWD/Brewfile" 2>/dev/null; then
    print ""
    print "Installing missing dependencies..."
    if command -v brew &>/dev/null; then
      brew bundle install --file="$PWD/Brewfile"
    else
      print "Error: Homebrew not found. Please install Homebrew first."
      print "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
      exit 1
    fi
  fi
else
  print "Warning: check-deps script not found"
fi

# macOS-specific: apply system defaults
if [[ "$(uname)" == "Darwin" ]] && [[ -x "$PWD/scripts/macos-defaults" ]]; then
  print ""
  zsh "$PWD/scripts/macos-defaults" 2>/dev/null | grep -E "^✅|^Configuring" | sed 's/^/  /' | sed 's/✅/✓/' || true
fi

print ""
print "✓ Setup complete!"
print ""

# Check 1Password status and show next steps
print "Checking 1Password integration..."
print ""

local op_ready=0
local setup_needed=()

# Check if 1Password CLI is installed
if ! command -v op &> /dev/null; then
  print "⚠️  1Password CLI not found"
  print "   Run: brew install --cask 1password 1password-cli"
  print ""
  print "   Then:"
  print "   1. Open 1Password app"
  print "   2. Unlock with your password/biometrics"
  print "   3. Run setup-ssh and setup-git-local"
  print ""
else
  # Check if signed in (requires 1Password app to be unlocked)
  if ! op account list &> /dev/null; then
    print "⚠️  1Password CLI installed but not authenticated"
    print ""
    print "   To use secrets from 1Password:"
    print "   1. Open 1Password app"
    print "   2. Unlock with your password/biometrics"
    print "   3. Run: op signin"
    print "   4. Then run: setup-ssh and setup-git-local"
    print ""
  else
    print "✓ 1Password CLI ready"
    op_ready=1
  fi
fi

# Check if secrets need to be set up
if [[ $op_ready -eq 1 ]]; then
  if [[ ! -f "$HOME/.ssh/id_rsa" ]]; then
    setup_needed+=("setup-ssh")
  fi
  
  if [[ ! -f "$HOME/.config/git/config.local" ]]; then
    setup_needed+=("setup-git-local")
  fi
  
  if [[ ${#setup_needed[@]} -gt 0 ]]; then
    print ""
    print "🔐 Setting up secrets from 1Password..."
    for script in $setup_needed; do
      print ""
      print "▶️  Running $script..."
      $script || print "   ⚠️  $script failed - you can run it manually later"
    done
    print ""
    print "✅ Secret setup complete!"
  fi
else
  print ""
  print "💡 After setting up 1Password, run:"
  [[ ! -f "$HOME/.ssh/id_rsa" ]] && print "   setup-ssh"
  [[ ! -f "$HOME/.config/git/config.local" ]] && print "   setup-git-local"
fi

print ""
print "Reloading shell with new configuration..."
print ""

# Reload the shell to pick up new configuration
exec zsh -l
