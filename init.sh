#!/bin/zsh
# Dotfiles initialization script
# Sets up symlinks and checks dependencies

set -e

# Create necessary directories
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.config/zsh.local"
mkdir -p "$HOME/.config/zsh.local/alias"
mkdir -p "$HOME/.config/zsh.local/completions"

# Link neovim configuration
rm -rf "$HOME/.config/nvim"
ln -sf "$PWD/nvim" "$HOME/.config/nvim"
echo "✓ nvim configured"

# Link tmux configuration
ln -sf "$PWD/.tmux.conf" "$HOME/.tmux.conf"
echo "✓ tmux configured"

# Link ghostty configuration
rm -rf "$HOME/.config/ghostty"
ln -sf "$PWD/ghostty" "$HOME/.config/ghostty"
echo "✓ ghostty configured"

# Link zsh configuration
ln -sf "$PWD/.zshenv" "$HOME/.zshenv"
ln -sf "$PWD/.zprofile" "$HOME/.zprofile"
ln -sf "$PWD/.zshrc" "$HOME/.zshrc"
rm -rf "$HOME/.config/zsh"
ln -sf "$PWD/zsh" "$HOME/.config/zsh"
echo "✓ zsh configured"

# Link helper scripts
ln -sf "$PWD/scripts/tmux-code-layout" "$HOME/.local/bin/tmux-code-layout"
ln -sf "$PWD/scripts/wb" "$HOME/.local/bin/wb"
ln -sf "$PWD/scripts/zsh-dotfiles" "$HOME/.local/bin/zsh-dotfiles"
ln -sf "$PWD/scripts/check-deps" "$HOME/.local/bin/check-deps"
echo "✓ scripts configured"

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
  zsh "$PWD/scripts/macos-defaults"
fi

print ""
print "Setup complete! Open a new terminal to use the new configuration."
