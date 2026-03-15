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

# Check dependencies
print ""
if [[ -x "$PWD/scripts/check-deps" ]]; then
  zsh "$PWD/scripts/check-deps" "$PWD/Brewfile"
else
  print "Warning: check-deps script not found"
fi

print ""
print "Setup complete! Open a new terminal to use the new configuration."

# macOS-specific reminder
if [[ "$(uname)" == "Darwin" ]] && [[ -x "$PWD/scripts/macos-defaults.sh" ]]; then
  print ""
  print "💡 macOS detected. To apply system defaults (dock, keyboard speed, etc.):"
  print "   $PWD/scripts/macos-defaults.sh"
  print ""
  print "   Preview changes first with:"
  print "   $PWD/scripts/macos-defaults.sh --check"
fi
