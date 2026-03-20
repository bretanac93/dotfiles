#!/bin/zsh
# Dotfiles initialization script
# Sets up symlinks and checks dependencies

set -euo pipefail

repo_root="${0:A:h}"
backup_dir="$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"

link_path() {
  local src="$1"
  local dst="$2"
  local name="$3"
  local backup_name="${4:-$name}"

  if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
    print "  ✓ $name (already linked)"
    return 0
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

link_path "$repo_root/nvim" "$HOME/.config/nvim" "nvim"
link_path "$repo_root/tmux/tmux.conf" "$HOME/.tmux.conf" "tmux" "tmux.conf"
link_path "$repo_root/ghostty" "$HOME/.config/ghostty" "ghostty"

link_path "$repo_root/zsh/env.zsh" "$HOME/.zshenv" "zshenv"
link_path "$repo_root/zsh/profile.zsh" "$HOME/.zprofile" "zprofile"
link_path "$repo_root/zsh/rc.zsh" "$HOME/.zshrc" "zshrc"
link_path "$repo_root/zsh" "$HOME/.config/zsh" "zsh"

if [[ -r "$repo_root/git/gitconfig" ]]; then
  link_path "$repo_root/git/gitconfig" "$HOME/.gitconfig" "git" "gitconfig"

  if [[ ! -r "$HOME/.config/git/config.local" ]]; then
    print ""
    print "⚠️  Local git config not found. Run this to set it up:"
    print "  setup-git-local"
    print ""
  fi
fi

mkdir -p "$HOME/.gnupg"
chmod 700 "$HOME/.gnupg"
if [[ -r "$repo_root/git/gpg.conf" ]]; then
  link_path "$repo_root/git/gpg.conf" "$HOME/.gnupg/gpg.conf" "gpg" "gpg.conf"
fi

link_path "$repo_root/bin/wb" "$HOME/.local/bin/wb" "wb"
link_path "$repo_root/bin/mdf" "$HOME/.local/bin/mdf" "mdf"
link_path "$repo_root/bin/dotfiles-doctor" "$HOME/.local/bin/dotfiles-doctor" "dotfiles-doctor"
link_path "$repo_root/bin/dotfiles-benchmark" "$HOME/.local/bin/dotfiles-benchmark" "dotfiles-benchmark"
link_path "$repo_root/bin/dotfiles-uninstall" "$HOME/.local/bin/dotfiles-uninstall" "dotfiles-uninstall"
link_path "$repo_root/bin/dotfiles-update" "$HOME/.local/bin/dotfiles-update" "dotfiles-update"
link_path "$repo_root/bin/dotfiles-cleanup-backups" "$HOME/.local/bin/dotfiles-cleanup-backups" "dotfiles-cleanup-backups"
link_path "$repo_root/scripts/zsh-dotfiles" "$HOME/.local/bin/zsh-dotfiles" "zsh-dotfiles"
link_path "$repo_root/scripts/check-deps" "$HOME/.local/bin/check-deps" "check-deps"
link_path "$repo_root/scripts/macos-defaults" "$HOME/.local/bin/macos-defaults" "macos-defaults"
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
  if ! zsh "$repo_root/scripts/check-deps" "$repo_root/Brewfile" 2>/dev/null; then
    print ""
    print "Installing missing dependencies..."
    if command -v brew >/dev/null 2>&1; then
      brew bundle install --file="$repo_root/Brewfile"
    else
      print "Error: Homebrew not found. Please install Homebrew first."
      print "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
      exit 1
    fi
  fi
else
  print "Warning: check-deps script not found"
fi

if [[ "$(uname)" == "Darwin" ]] && [[ -x "$repo_root/scripts/macos-defaults" ]]; then
  print ""
  zsh "$repo_root/scripts/macos-defaults" 2>/dev/null | grep -E "^✅|^Configuring" | sed 's/^/  /' | sed 's/✅/✓/' || true
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
  print "   Run: brew install --cask 1password 1password-cli"
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
