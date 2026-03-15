#!/bin/zsh



mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.config/zsh.local"
mkdir -p "$HOME/.config/zsh.local/alias"
mkdir -p "$HOME/.config/zsh.local/completions"

# Link neovim configuration to `$HOME/.config`
rm -rf "$HOME/.config/nvim"
ln -sf "$PWD/nvim" "$HOME/.config/nvim"
echo "nvim configured"

# Link the tmux configuration and install the tmux plugin manager
ln -sf "$PWD/.tmux.conf" "$HOME/.tmux.conf"
echo "tmux configured"

# Link the ghostty configuration
rm -rf "$HOME/.config/ghostty"
ln -sf "$PWD/ghostty" "$HOME/.config/ghostty"
echo "ghostty configured"

# Link zsh configuration
ln -sf "$PWD/.zshenv" "$HOME/.zshenv"
ln -sf "$PWD/.zprofile" "$HOME/.zprofile"
ln -sf "$PWD/.zshrc" "$HOME/.zshrc"
rm -rf "$HOME/.config/zsh"
ln -sf "$PWD/zsh" "$HOME/.config/zsh"
echo "zsh configured"

# Link helper scripts into a directory already on PATH
ln -sf "$PWD/scripts/tmux-code-layout" "$HOME/.local/bin/tmux-code-layout"
ln -sf "$PWD/scripts/wb" "$HOME/.local/bin/wb"
ln -sf "$PWD/scripts/zsh-dotfiles" "$HOME/.local/bin/zsh-dotfiles"
echo "scripts configured"

# Check for essential Homebrew dependencies from Brewfile
print ""
print "Checking dependencies..."

local missing_deps=()
local brewfile="$PWD/Brewfile"

# Parse Brewfile and check each dependency
while IFS= read -r line; do
  # Extract package name from brew "package" lines
  if [[ "$line" =~ ^brew[[:space:]]+\"([^\"]+)\" ]]; then
    local pkg="${match[1]}"
    
    # Skip comment lines
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    
    # Check if package is installed
    # Special case: zsh-fast-syntax-highlighting is a plugin, not a command
    if [[ "$pkg" == "zsh-fast-syntax-highlighting" ]]; then
      local fsh_found=0
      local -a fsh_paths=(
        "/opt/homebrew/share/zsh-fast-syntax-highlighting"
        "/usr/local/share/zsh-fast-syntax-highlighting"
        "${HOMEBREW_PREFIX:-}/share/zsh-fast-syntax-highlighting"
      )
      for fsh_path in $fsh_paths; do
        if [[ -r "$fsh_path/fast-syntax-highlighting.plugin.zsh" ]]; then
          fsh_found=1
          break
        fi
      done
      (( ! fsh_found )) && missing_deps+=("$pkg")
    # Special case: neovim can be 'nvim' or 'vim' command
    elif [[ "$pkg" == "neovim" ]]; then
      if ! command -v nvim &>/dev/null; then
        missing_deps+=("$pkg")
      fi
    # Special case: ripgrep is 'rg' command
    elif [[ "$pkg" == "ripgrep" ]]; then
      if ! command -v rg &>/dev/null; then
        missing_deps+=("$pkg")
      fi
    # Standard case: package name matches command name
    else
      if ! command -v "$pkg" &>/dev/null; then
        missing_deps+=("$pkg")
      fi
    fi
  fi
done < "$brewfile"

if (( ${#missing_deps} > 0 )); then
  print ""
  print "⚠️  Missing dependencies from Brewfile:"
  for dep in $missing_deps; do
    print "  - $dep"
  done
  print ""
  print "Install them with:"
  print "  brew bundle install --file=$brewfile"
else
  print "✅ All dependencies from Brewfile installed"
fi
