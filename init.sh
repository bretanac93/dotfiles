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
local missing_nvim_deps=()

# Check for command-line tools
for dep in fzf fd tmux nvim git rg; do
  if ! command -v "$dep" &>/dev/null; then
    missing_deps+=("$dep")
  fi
done

# Check for zsh-fast-syntax-highlighting (it's a plugin, not a command)
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
if (( ! fsh_found )); then
  missing_deps+=("zsh-fast-syntax-highlighting")
fi

# Check for nvim-specific dependencies
if ! command -v deno &>/dev/null; then
  missing_nvim_deps+=("deno")
fi

if (( ${#missing_deps} > 0 )); then
  print ""
  print "⚠️  Missing shell dependencies: ${missing_deps[*]}"
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
  print "✅ All shell dependencies installed"
fi

if (( ${#missing_nvim_deps} > 0 )); then
  print ""
  print "⚠️  Missing nvim plugin dependencies: ${missing_nvim_deps[*]}"
  print "Install them with:"
  for dep in $missing_nvim_deps; do
    case "$dep" in
      deno) print "  brew install deno  # required for markdown-preview.nvim" ;;
    esac
  done
  print ""
  print "Note: LSP servers are installed automatically via Mason inside nvim"
else
  print "✅ All nvim plugin dependencies installed"
fi
