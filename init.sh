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

# Check for essential Homebrew dependencies
print ""
print "Checking dependencies..."
local missing_deps=()

for dep in fzf fd zsh-fast-syntax-highlighting tmux nvim git rg; do
  if ! command -v "$dep" &>/dev/null; then
    missing_deps+=("$dep")
  fi
done

if (( ${#missing_deps} > 0 )); then
  print ""
  print "⚠️  Missing dependencies: ${missing_deps[*]}"
  print "Install them with:"
  print "  brew bundle install --file=$PWD/Brewfile"
  print ""
  print "Or install individually:"
  for dep in $missing_deps; do
    case "$dep" in
      fzf) print "  brew install fzf" ;;
      fd) print "  brew install fd" ;;
      zsh-fast-syntax-highlighting) print "  brew install zsh-fast-syntax-highlighting" ;;
      tmux) print "  brew install tmux" ;;
      nvim) print "  brew install neovim" ;;
      git) print "  brew install git" ;;
      rg) print "  brew install ripgrep" ;;
    esac
  done
else
  print "✅ All essential dependencies installed"
fi
