#!/bin/zsh
# Dotfiles initialization script
# Sets up symlinks and checks dependencies

set -e

print "Setting up dotfiles..."
print ""

# Create necessary directories
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.config/zsh.local"
mkdir -p "$HOME/.config/zsh.local/alias"
mkdir -p "$HOME/.config/zsh.local/completions"

# Link neovim configuration
rm -rf "$HOME/.config/nvim"
ln -sf "$PWD/nvim" "$HOME/.config/nvim"
print "  ✓ nvim"

# Link tmux configuration
ln -sf "$PWD/tmux/tmux.conf" "$HOME/.tmux.conf"
print "  ✓ tmux"

# Link ghostty configuration
rm -rf "$HOME/.config/ghostty"
ln -sf "$PWD/ghostty" "$HOME/.config/ghostty"
print "  ✓ ghostty"

# Link zsh configuration (map friendly repo names to standard dotfile names)
ln -sf "$PWD/zsh/env.zsh" "$HOME/.zshenv"
ln -sf "$PWD/zsh/profile.zsh" "$HOME/.zprofile"
ln -sf "$PWD/zsh/rc.zsh" "$HOME/.zshrc"
rm -rf "$HOME/.config/zsh"
ln -sf "$PWD/zsh" "$HOME/.config/zsh"
print "  ✓ zsh"

# Link git configuration
if [[ -r "$PWD/git/gitconfig" ]]; then
  ln -sf "$PWD/git/gitconfig" "$HOME/.gitconfig"
  print "  ✓ git"
  
  # Check if local gitconfig exists
  if [[ ! -r "$HOME/.config/git/config.local" ]]; then
    print ""
    print "⚠️  Local git config not found. Run this to set it up:"
    print "  $PWD/scripts/setup-git-local"
    print ""
  fi
fi

# Link gpg configuration
mkdir -p "$HOME/.gnupg"
chmod 700 "$HOME/.gnupg"
if [[ -r "$PWD/git/gpg.conf" ]]; then
  ln -sf "$PWD/git/gpg.conf" "$HOME/.gnupg/gpg.conf"
  print "  ✓ gpg"
fi

# Link helper scripts
ln -sf "$PWD/scripts/wb" "$HOME/.local/bin/wb"
ln -sf "$PWD/scripts/zsh-dotfiles" "$HOME/.local/bin/zsh-dotfiles"
ln -sf "$PWD/scripts/check-deps" "$HOME/.local/bin/check-deps"
ln -sf "$PWD/scripts/macos-defaults" "$HOME/.local/bin/macos-defaults"
ln -sf "$PWD/scripts/setup-git-local" "$HOME/.local/bin/setup-git-local"
ln -sf "$PWD/scripts/setup-ssh" "$HOME/.local/bin/setup-ssh"
print "  ✓ scripts"

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
  print "   Install it: brew install --cask 1password-cli"
  print "   Or download from: https://1password.com/downloads/command-line/"
  print ""
else
  # Check if signed in
  if ! op account list &> /dev/null; then
    print "⚠️  1Password CLI installed but not signed in"
    print "   Run: op signin"
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
    print "🔐 Next steps - export secrets from 1Password:"
    for script in $setup_needed; do
      print "   $script"
    done
  fi
fi

print ""
print "Reloading shell with new configuration..."
print ""

# Reload the shell to pick up new configuration
exec zsh -l
