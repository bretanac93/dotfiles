#!/bin/zsh
# Dotfiles initialization script

set -euo pipefail

repo_root="${0:A:h}"
common_dir="$repo_root/common"
macos_dir="$repo_root/macos"
backup_dir="$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"
force_symlinks=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force-symlinks) force_symlinks=1 ;;
    -h|--help) print "Usage: ./init.sh [--force-symlinks]"; exit 0 ;;
    *) print "Error: unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

# ── Helpers ────────────────────────────────────────────────────────────────────

link_path() {
  local src="$1" dst="$2" name="$3" backup_name="${4:-$3}"

  if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
    if (( force_symlinks )); then
      rm -f "$dst"
      print "  ↻ $name (relinked)"
    else
      print "  ✓ $name (already linked)"
      return 0
    fi
  fi

  [[ -L "$dst" ]] && rm -f "$dst"
  if [[ -e "$dst" ]]; then
    mv "$dst" "$backup_dir/$backup_name"
    print "  📦 Backed up $name"
  fi

  ln -s "$src" "$dst"
  print "  ✓ $name"
}

copy_if_missing() {
  local src="$1" dst="$2" name="$3"
  [[ -e "$dst" ]] && { print "  ✓ $name (already exists)"; return 0; }
  cp "$src" "$dst"
  print "  ✓ $name"
}

unlink_legacy_repo_symlink() {
  local src="$1" dst="$2" name="$3"

  # Migrate only links created by an earlier version of this repository. Never
  # touch a real file or a link the user manages themselves.
  if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
    rm -f "$dst"
    print "  ✓ $name (removed legacy dotfiles link)"
  fi
}

# ── Bootstrap ──────────────────────────────────────────────────────────────────

print "Setting up dotfiles...\n"
mkdir -p "$backup_dir"
print "📁 Backup directory: $backup_dir\n"

mkdir -p "$HOME"/{.config,.local/bin,.worktrees}
mkdir -p "$HOME/.config/zsh.local/"{alias,completions}

# ── Platform detection ─────────────────────────────────────────────────────────
#
# On Omarchy, anything Omarchy already standardizes is left to Omarchy — its
# theme system rewrites terminal, btop, and background config on every
# `omarchy theme set`, so linking our own on top would fight it. macOS keeps the
# full set, because nothing else manages those files there.

if [[ -d /usr/share/omarchy ]]; then
  on_omarchy=1
else
  on_omarchy=0
fi

# ── Cross-platform configs ─────────────────────────────────────────────────────

copy_if_missing "$common_dir/zsh.local/env.zsh" "$HOME/.config/zsh.local/env.zsh" "zsh local env"

# Neovim: common/nvim is kept in the repo but skipped on Omarchy, which ships
# LazyVim and symlinks lua/plugins/theme.lua at the current theme's neovim.lua.
# Every Omarchy theme sets its colorscheme on the LazyVim/LazyVim plugin spec,
# which common/nvim does not declare — it drives lazy.nvim directly — so linking
# ours would leave that symlink pointing at a plugin the spec never loads.
# Set DOTFILES_LINK_NVIM=1 to link it anyway.
if (( on_omarchy )) && [[ "${DOTFILES_LINK_NVIM:-0}" != "1" ]]; then
  print "  → nvim: using Omarchy's LazyVim (common/nvim not linked)"
else
  link_path "$common_dir/nvim" "$HOME/.config/nvim" "nvim"
fi

if (( on_omarchy )); then
  # Remove only the old repository links that would otherwise shadow files
  # Omarchy owns. This is needed when upgrading an existing installation.
  unlink_legacy_repo_symlink "$common_dir/tmux/tmux.conf" "$HOME/.tmux.conf" "tmux"
  unlink_legacy_repo_symlink "$common_dir/zsh/profile.zsh" "$HOME/.zprofile" "zprofile"
  unlink_legacy_repo_symlink "$common_dir/btop.conf" "$HOME/.config/btop/btop.conf" "btop"
  unlink_legacy_repo_symlink "$common_dir/ghostty" "$HOME/.config/ghostty" "ghostty"
  unlink_legacy_repo_symlink "$common_dir/wallpaper.png" "$HOME/.config/wallpaper.png" "wallpaper"

  for dir in hypr waybar wofi yazi swaync swayosd walker; do
    unlink_legacy_repo_symlink "$repo_root/arch/$dir" "$HOME/.config/$dir" "$dir"
  done
  unlink_legacy_repo_symlink "$repo_root/arch/gtk/gtk-3.0/settings.ini" "$HOME/.config/gtk-3.0/settings.ini" "gtk-3.0"
  unlink_legacy_repo_symlink "$repo_root/arch/gtk/gtk-4.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini" "gtk-4.0"
  unlink_legacy_repo_symlink "$repo_root/arch/applications/mimeapps.list" "$HOME/.config/mimeapps.list" "mimeapps"
  unlink_legacy_repo_symlink "$repo_root/arch/vivaldi/vivaldi-stable.conf" "$HOME/.config/vivaldi-stable.conf" "vivaldi-flags"
  for desktop in com.mitchellh.ghostty.desktop slack.desktop vivaldi-stable.desktop yazi.desktop zathura.desktop; do
    unlink_legacy_repo_symlink "$repo_root/arch/applications/$desktop" "$HOME/.local/share/applications/$desktop" "$desktop"
  done

  # tmux: thin override layer that source-files the packaged config.
  mkdir -p "$HOME/.config/tmux"
  link_path "$common_dir/tmux/omarchy.conf" "$HOME/.config/tmux/tmux.conf" "tmux (omarchy layer)" "tmux.conf"

  print "  → btop, ghostty, wallpaper: managed by Omarchy themes (not linked)"
else
  link_path "$common_dir/tmux/tmux.conf" "$HOME/.tmux.conf"             "tmux" "tmux.conf"
  mkdir -p "$HOME/.config/btop"
  link_path "$common_dir/btop.conf"     "$HOME/.config/btop/btop.conf"  "btop"
  link_path "$common_dir/ghostty"       "$HOME/.config/ghostty"         "ghostty"
  link_path "$common_dir/wallpaper.png" "$HOME/.config/wallpaper.png"   "wallpaper" "wallpaper.png"
fi

# ── Shell ──────────────────────────────────────────────────────────────────────

# oh-my-zsh owns the plugin/completion framework; the zsh-omarchy layer loads on
# top of it. Cloned directly rather than through the upstream install script,
# which rewrites .zshrc and runs chsh on its own.
omz_dir="$HOME/.oh-my-zsh"
if [[ ! -d "$omz_dir/.git" ]]; then
  print "  ↓ Cloning oh-my-zsh..."
  git clone --quiet --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$omz_dir"
fi
print "  ✓ oh-my-zsh"

for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  plugin_dir="$omz_dir/custom/plugins/$plugin"
  if [[ ! -d "$plugin_dir/.git" ]]; then
    print "  ↓ Cloning $plugin..."
    git clone --quiet --depth=1 "https://github.com/zsh-users/$plugin.git" "$plugin_dir"
  fi
  print "  ✓ $plugin"
done

link_path "$common_dir/zsh-omarchy/zshenv" "$HOME/.zshenv"     "zshenv"
link_path "$common_dir/zsh-omarchy/zshrc"  "$HOME/.zshrc"      "zshrc"
link_path "$common_dir/zsh-omarchy"        "$HOME/.config/zsh" "zsh"

# Make zsh the login shell if it isn't already. chsh prompts for a password, so
# it stays interactive rather than being wrapped in sudo.
if [[ "$(getent passwd "$USER" 2>/dev/null | cut -d: -f7)" != *zsh ]]; then
  print "\n⚠️  Login shell is not zsh — run: chsh -s \"\$(command -v zsh)\"\n"
fi

# ── Git & GPG ─────────────────────────────────────────────────────────────────

# On Omarchy, ~/.config/git/config is Omarchy's. Git reads it first and
# ~/.gitconfig second, so ours is a thin override carrying only what Omarchy
# does not already set. Elsewhere ~/.gitconfig is the whole config.
if (( on_omarchy )) && [[ -r "$common_dir/git/gitconfig.omarchy" ]]; then
  link_path "$common_dir/git/gitconfig.omarchy" "$HOME/.gitconfig" "git (omarchy layer)" "gitconfig"
  [[ ! -r "$HOME/.config/git/config.local" ]] && print "\n⚠️  Local git config missing — run: setup-git-local\n"
elif [[ -r "$common_dir/git/gitconfig" ]]; then
  link_path "$common_dir/git/gitconfig" "$HOME/.gitconfig" "git" "gitconfig"
  [[ ! -r "$HOME/.config/git/config.local" ]] && print "\n⚠️  Local git config missing — run: setup-git-local\n"
fi

[[ -r "$common_dir/git/gitignore" ]] && link_path "$common_dir/git/gitignore" "$HOME/.gitignore" "git" "gitignore"

mkdir -p "$HOME/.gnupg" && chmod 700 "$HOME/.gnupg"
[[ -r "$common_dir/git/gpg.conf" ]] && link_path "$common_dir/git/gpg.conf" "$HOME/.gnupg/gpg.conf" "gpg" "gpg.conf"

# ── Desktop configs ───────────────────────────────────────────────────────────
#
# Nothing here on Linux anymore: Omarchy owns the compositor, bar, launcher,
# notifications, GTK theming, and .desktop entries. Customize those through
# ~/.config/hypr/ and ~/.config/omarchy/, not this repo.

# ── Bin scripts (auto-link everything) ────────────────────────────────────────

for script in "$common_dir/bin/"* "$repo_root/scripts/"*; do
  [[ -f "$script" ]] || continue
  name=$(basename "$script")
  link_path "$script" "$HOME/.local/bin/$name" "$name"
done

[[ "$(uname)" == "Darwin" ]] && \
  link_path "$macos_dir/scripts/macos-defaults" "$HOME/.local/bin/macos-defaults" "macos-defaults"

# ── SSH check ─────────────────────────────────────────────────────────────────

[[ ! -f "$HOME/.ssh/id_rsa" ]] && print "\n⚠️  SSH keys not found — run: setup-ssh\n"

# ── Dependencies ──────────────────────────────────────────────────────────────

print ""
if [[ -x "$repo_root/scripts/check-deps" ]]; then
  if ! zsh "$repo_root/scripts/check-deps"; then
    print "\nInstalling missing dependencies..."
    zsh "$repo_root/scripts/install-deps"
  fi
fi

# ── macOS defaults ────────────────────────────────────────────────────────────

if [[ "$(uname)" == "Darwin" ]] && [[ -x "$macos_dir/scripts/macos-defaults" ]]; then
  zsh "$macos_dir/scripts/macos-defaults" 2>/dev/null \
    | grep -E "^✅|^Configuring" | sed 's/^/  /; s/✅/✓/' || true
fi

print "\n✓ Setup complete!\n"

# ── 1Password ─────────────────────────────────────────────────────────────────

print "Checking 1Password integration...\n"

op_ready=0
typeset -a setup_needed=()

if ! command -v op >/dev/null 2>&1; then
  print "⚠️  1Password CLI not found — run: install-deps"
  print "   Then: op signin → setup-ssh → setup-git-local\n"
elif ! op account list >/dev/null 2>&1; then
  print "⚠️  1Password CLI not authenticated"
  print "   Unlock 1Password → op signin → setup-ssh → setup-git-local\n"
else
  print "✓ 1Password CLI ready"
  op_ready=1
fi

if (( op_ready )); then
  [[ ! -f "$HOME/.ssh/id_rsa" ]]              && setup_needed+=("setup-ssh")
  [[ ! -f "$HOME/.config/git/config.local" ]] && setup_needed+=("setup-git-local")

  if (( ${#setup_needed[@]} > 0 )); then
    print "\n🔐 Setting up secrets from 1Password..."
    for script in "${setup_needed[@]}"; do
      print "\n▶️  Running $script..."
      "$HOME/.local/bin/$script" || print "   ⚠️  $script failed — run manually later"
    done
    print "\n✅ Secret setup complete!"
  fi
else
  print "\n💡 After setting up 1Password, run:"
  [[ ! -f "$HOME/.ssh/id_rsa" ]]              && print "   setup-ssh"
  [[ ! -f "$HOME/.config/git/config.local" ]] && print "   setup-git-local"
fi

print "\nReloading shell...\n"
exec zsh -l
