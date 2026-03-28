#!/bin/zsh
# Dotfiles initialization script
# Sets up symlinks and checks dependencies

set -euo pipefail

repo_root="${0:A:h}"
common_dir="$repo_root/common"
macos_dir="$repo_root/macos"
backup_dir="$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"
force_symlinks=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force-symlinks)
      force_symlinks=1
      ;;
    -h|--help)
      print "Usage: ./init.sh [--force-symlinks]"
      print ""
      print "Options:"
      print "  --force-symlinks  recreate managed symlinks even if already linked"
      exit 0
      ;;
    *)
      print "Error: unknown option: $1" >&2
      print "Run ./init.sh --help for usage." >&2
      exit 1
      ;;
  esac
  shift
done

link_path() {
  local src="$1"
  local dst="$2"
  local name="$3"
  local backup_name="${4:-$name}"

  if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
    if (( force_symlinks )); then
      rm -f "$dst"
      print "  ↻ $name (relinked)"
    else
      print "  ✓ $name (already linked)"
      return 0
    fi
  fi

  if [[ -L "$dst" ]]; then
    rm -f "$dst"
  elif [[ -e "$dst" ]]; then
    mv "$dst" "$backup_dir/$backup_name"
    print "  📦 Backed up existing $name"
  fi

  ln -s "$src" "$dst"
  print "  ✓ $name"
}

print "Setting up dotfiles..."
print ""

mkdir -p "$backup_dir"
print "📁 Backup directory: $backup_dir"
print ""

mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.worktrees"
mkdir -p "$HOME/.config/zsh.local"
mkdir -p "$HOME/.config/zsh.local/alias"
mkdir -p "$HOME/.config/zsh.local/completions"

link_path "$common_dir/nvim" "$HOME/.config/nvim" "nvim"
link_path "$common_dir/tmux/tmux.conf" "$HOME/.tmux.conf" "tmux" "tmux.conf"
link_path "$common_dir/ghostty" "$HOME/.config/ghostty" "ghostty"
link_path "$common_dir/wallpaper.png" "$HOME/.config/wallpaper.png" "wallpaper" "wallpaper.png"

if [[ "$(uname)" == "Linux" ]] && [[ -d "$repo_root/arch/hypr" ]]; then
  link_path "$repo_root/arch/hypr" "$HOME/.config/hypr" "hyprland" "hypr"
fi

if [[ "$(uname)" == "Linux" ]] && [[ -d "$repo_root/arch/waybar" ]]; then
  link_path "$repo_root/arch/waybar" "$HOME/.config/waybar" "waybar"
fi

if [[ "$(uname)" == "Linux" ]] && [[ -d "$repo_root/arch/wofi" ]]; then
  link_path "$repo_root/arch/wofi" "$HOME/.config/wofi" "wofi"
fi

if [[ "$(uname)" == "Linux" ]] && [[ -d "$repo_root/arch/yazi" ]]; then
  link_path "$repo_root/arch/yazi" "$HOME/.config/yazi" "yazi"
fi

link_path "$common_dir/zsh/env.zsh" "$HOME/.zshenv" "zshenv"
link_path "$common_dir/zsh/profile.zsh" "$HOME/.zprofile" "zprofile"
link_path "$common_dir/zsh/rc.zsh" "$HOME/.zshrc" "zshrc"
link_path "$common_dir/zsh" "$HOME/.config/zsh" "zsh"

if [[ -r "$common_dir/git/gitconfig" ]]; then
  link_path "$common_dir/git/gitconfig" "$HOME/.gitconfig" "git" "gitconfig"

  if [[ ! -r "$HOME/.config/git/config.local" ]]; then
    print ""
    print "⚠️  Local git config not found. Run this to set it up:"
    print "  setup-git-local"
    print ""
  fi
fi

mkdir -p "$HOME/.gnupg"
chmod 700 "$HOME/.gnupg"
if [[ -r "$common_dir/git/gpg.conf" ]]; then
  link_path "$common_dir/git/gpg.conf" "$HOME/.gnupg/gpg.conf" "gpg" "gpg.conf"
fi

link_path "$common_dir/bin/wb" "$HOME/.local/bin/wb" "wb"
link_path "$common_dir/bin/mdf" "$HOME/.local/bin/mdf" "mdf"
link_path "$common_dir/bin/hypr-launcher" "$HOME/.local/bin/hypr-launcher" "hypr-launcher"
link_path "$common_dir/bin/hypr-screenshot" "$HOME/.local/bin/hypr-screenshot" "hypr-screenshot"
link_path "$common_dir/bin/hypr-power-menu" "$HOME/.local/bin/hypr-power-menu" "hypr-power-menu"
link_path "$common_dir/bin/dotfiles-doctor" "$HOME/.local/bin/dotfiles-doctor" "dotfiles-doctor"
link_path "$common_dir/bin/dotfiles-benchmark" "$HOME/.local/bin/dotfiles-benchmark" "dotfiles-benchmark"
link_path "$common_dir/bin/dotfiles-uninstall" "$HOME/.local/bin/dotfiles-uninstall" "dotfiles-uninstall"
link_path "$common_dir/bin/dotfiles-update" "$HOME/.local/bin/dotfiles-update" "dotfiles-update"
link_path "$common_dir/bin/dotfiles-cleanup-backups" "$HOME/.local/bin/dotfiles-cleanup-backups" "dotfiles-cleanup-backups"
link_path "$repo_root/scripts/zsh-dotfiles" "$HOME/.local/bin/zsh-dotfiles" "zsh-dotfiles"
link_path "$repo_root/scripts/check-deps" "$HOME/.local/bin/check-deps" "check-deps"
link_path "$repo_root/scripts/install-deps" "$HOME/.local/bin/install-deps" "install-deps"
link_path "$macos_dir/scripts/macos-defaults" "$HOME/.local/bin/macos-defaults" "macos-defaults"
link_path "$repo_root/scripts/setup-git-local" "$HOME/.local/bin/setup-git-local" "setup-git-local"
link_path "$repo_root/scripts/setup-ssh" "$HOME/.local/bin/setup-ssh" "setup-ssh"

if [[ ! -f "$HOME/.ssh/id_rsa" ]]; then
  print ""
  print "⚠️  SSH keys not found. Run this to set them up:"
  print "  setup-ssh"
  print ""
fi

print ""
if [[ -x "$repo_root/scripts/check-deps" ]]; then
  if ! zsh "$repo_root/scripts/check-deps"; then
    print ""
    print "Installing missing dependencies..."
    if [[ -x "$repo_root/scripts/install-deps" ]]; then
      zsh "$repo_root/scripts/install-deps"
    else
      print "Error: install-deps script not found"
      exit 1
    fi
  fi
else
  print "Warning: check-deps script not found"
fi

if [[ "$(uname)" == "Darwin" ]] && [[ -x "$macos_dir/scripts/macos-defaults" ]]; then
  print ""
  zsh "$macos_dir/scripts/macos-defaults" 2>/dev/null | grep -E "^✅|^Configuring" | sed 's/^/  /' | sed 's/✅/✓/' || true
fi

print ""
print "✓ Setup complete!"
print ""

print "Checking 1Password integration..."
print ""

op_ready=0
typeset -a setup_needed=()

if ! command -v op >/dev/null 2>&1; then
  print "⚠️  1Password CLI not found"
  print "   Run: install-deps"
  print ""
  print "   Then:"
  print "   1. Open 1Password app"
  print "   2. Unlock with your password/biometrics"
  print "   3. Run setup-ssh and setup-git-local"
  print ""
else
  if ! op account list >/dev/null 2>&1; then
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

if [[ $op_ready -eq 1 ]]; then
  if [[ ! -f "$HOME/.ssh/id_rsa" ]]; then
    setup_needed+=("setup-ssh")
  fi

  if [[ ! -f "$HOME/.config/git/config.local" ]]; then
    setup_needed+=("setup-git-local")
  fi

  if (( ${#setup_needed[@]} > 0 )); then
    print ""
    print "🔐 Setting up secrets from 1Password..."
    for setup_script in "${setup_needed[@]}"; do
      print ""
      print "▶️  Running $setup_script..."
      if [[ -x "$HOME/.local/bin/$setup_script" ]]; then
        "$HOME/.local/bin/$setup_script" || print "   ⚠️  $setup_script failed - you can run it manually later"
      else
        print "   ⚠️  $setup_script is not linked yet - you can run it manually later"
      fi
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

exec zsh -l
