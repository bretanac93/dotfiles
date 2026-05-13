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

# ── Bootstrap ──────────────────────────────────────────────────────────────────

print "Setting up dotfiles...\n"
mkdir -p "$backup_dir"
print "📁 Backup directory: $backup_dir\n"

mkdir -p "$HOME"/{.config,.local/bin,.worktrees}
mkdir -p "$HOME/.config/zsh.local/"{alias,completions}

# ── Cross-platform configs ─────────────────────────────────────────────────────

copy_if_missing "$common_dir/zsh.local/env.zsh" "$HOME/.config/zsh.local/env.zsh" "zsh local env"

link_path "$common_dir/nvim"           "$HOME/.config/nvim"          "nvim"
link_path "$common_dir/tmux/tmux.conf" "$HOME/.tmux.conf"            "tmux" "tmux.conf"
link_path "$common_dir/ghostty"        "$HOME/.config/ghostty"       "ghostty"
link_path "$common_dir/wallpaper.png"  "$HOME/.config/wallpaper.png" "wallpaper" "wallpaper.png"

# ── Shell ──────────────────────────────────────────────────────────────────────

link_path "$common_dir/zsh/env.zsh"     "$HOME/.zshenv"     "zshenv"
link_path "$common_dir/zsh/profile.zsh" "$HOME/.zprofile"   "zprofile"
link_path "$common_dir/zsh/rc.zsh"      "$HOME/.zshrc"      "zshrc"
link_path "$common_dir/zsh"             "$HOME/.config/zsh" "zsh"

# ── Git & GPG ─────────────────────────────────────────────────────────────────

if [[ -r "$common_dir/git/gitconfig" ]]; then
  link_path "$common_dir/git/gitconfig" "$HOME/.gitconfig" "git" "gitconfig"
  [[ ! -r "$HOME/.config/git/config.local" ]] && print "\n⚠️  Local git config missing — run: setup-git-local\n"
fi

mkdir -p "$HOME/.gnupg" && chmod 700 "$HOME/.gnupg"
[[ -r "$common_dir/git/gpg.conf" ]] && link_path "$common_dir/git/gpg.conf" "$HOME/.gnupg/gpg.conf" "gpg" "gpg.conf"

# ── Arch / Hyprland configs ───────────────────────────────────────────────────

if [[ "$(uname)" == "Linux" ]]; then
  for dir in hypr waybar wofi yazi swaync swayosd walker; do
    [[ -d "$repo_root/arch/$dir" ]] && link_path "$repo_root/arch/$dir" "$HOME/.config/$dir" "$dir"
  done

  mkdir -p "$HOME/.local/share/applications"
  for desktop in "$repo_root/arch/applications/"*.desktop; do
    name=$(basename "$desktop")
    link_path "$desktop" "$HOME/.local/share/applications/$name" "$name"
  done

  link_path "$repo_root/arch/applications/mimeapps.list"  "$HOME/.config/mimeapps.list"       "mimeapps"
  link_path "$repo_root/arch/vivaldi/vivaldi-stable.conf" "$HOME/.config/vivaldi-stable.conf" "vivaldi-flags"
fi

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
