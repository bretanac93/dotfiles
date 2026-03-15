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
ln -sf "$PWD/tmux.conf" "$HOME/.tmux.conf"
print "  ✓ tmux"

# Link ghostty configuration
rm -rf "$HOME/.config/ghostty"
ln -sf "$PWD/ghostty" "$HOME/.config/ghostty"
print "  ✓ ghostty"

# Link zsh configuration (map friendly repo names to standard dotfile names)
ln -sf "$PWD/env.zsh" "$HOME/.zshenv"
ln -sf "$PWD/profile.zsh" "$HOME/.zprofile"
ln -sf "$PWD/rc.zsh" "$HOME/.zshrc"
rm -rf "$HOME/.config/zsh"
ln -sf "$PWD/zsh" "$HOME/.config/zsh"
print "  ✓ zsh"

# Link git configuration
if [[ -r "$PWD/gitconfig" ]]; then
  ln -sf "$PWD/gitconfig" "$HOME/.gitconfig"
  print "  ✓ git"
  
  # Check for encrypted personal gitconfig
  if [[ -r "$PWD/gitconfig.personal.enc" ]]; then
    print ""
    print "🔐 Encrypted personal gitconfig found."
    printf "Enter password to decrypt: "
    read -s password
    print ""
    
    if echo "$password" | openssl enc -aes-256-cbc -salt -pbkdf2 -d -in "$PWD/gitconfig.personal.enc" -out "$HOME/.gitconfig.personal" -pass stdin 2>/dev/null; then
      cat "$HOME/.gitconfig.personal" >> "$HOME/.gitconfig"
      rm "$HOME/.gitconfig.personal"
      print "  ✓ personal gitconfig added"
    else
      print "  ⚠️  Failed to decrypt personal gitconfig (wrong password?)"
    fi
  fi
fi

# Link helper scripts
ln -sf "$PWD/scripts/wb" "$HOME/.local/bin/wb"
ln -sf "$PWD/scripts/zsh-dotfiles" "$HOME/.local/bin/zsh-dotfiles"
ln -sf "$PWD/scripts/check-deps" "$HOME/.local/bin/check-deps"
ln -sf "$PWD/scripts/macos-defaults" "$HOME/.local/bin/macos-defaults"
print "  ✓ scripts"

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
print "Reloading shell with new configuration..."
print ""

# Reload the shell to pick up new configuration
exec zsh -l
