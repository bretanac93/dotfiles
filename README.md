# dotfiles

Minimal, opinionated personal environment for macOS and Arch/Hyprland built around native zsh, tmux, Neovim, Ghostty, and a small set of setup scripts.

## Highlights

- Native zsh setup with no Oh-My-Zsh
- One main entry point: `mdf`
- Idempotent setup with backups in `~/.dotfiles-backups/YYYYMMDD-HHMMSS/`
- Platform-native dependency checks during install
- 1Password-backed Git signing and SSH key export
- Installed helper scripts work from `~/.local/bin` in any directory

## Quick Start

```bash
git clone https://github.com/bretanac93/dotfiles ~/Code/dotfiles
cd ~/Code/dotfiles
./init.sh
# or force relink managed symlinks after moving paths around
./init.sh --force-symlinks
```

After the first install, use `mdf` for day-to-day management.

## Daily Use

```bash
mdf install              # Run init again
mdf update               # Pull latest changes and re-run setup
mdf deps                 # Install platform dependencies
mdf doctor               # Check health
mdf benchmark            # Measure zsh startup time
mdf cleanup --dry-run    # Preview old-backup cleanup
mdf cleanup              # Remove old backups
mdf uninstall --dry-run  # Preview uninstall
mdf ssh                  # Export SSH keys from 1Password
mdf git                  # Set up git + GPG signing
mdf aliases              # Show common aliases
mdf help                 # Show all commands
```

## What Setup Does

Running `./init.sh` or `mdf install` will:

- symlink tracked config into your home directory
- back up any existing conflicting files before replacing them
- link helper commands into `~/.local/bin/`
- check platform dependencies and install missing packages through Homebrew or pacman/paru
- apply macOS defaults from `macos/scripts/macos-defaults`
- optionally bootstrap Git and SSH secrets from 1Password

## Included Tools

Tools linked into `~/.local/bin/`:

- `mdf` - main dotfiles manager
- `wb` - launch editor + terminal + AI assistant in tmux
- `check-deps` - verify platform dependency manifests
- `install-deps` - install platform dependency manifests
- `setup-git-local` - configure git with GPG signing
- `setup-ssh` - export SSH keys from 1Password
- `dotfiles-doctor` - health checks
- `dotfiles-benchmark` - benchmark zsh startup time
- `dotfiles-update` - pull latest changes and re-run setup
- `dotfiles-uninstall` - remove dotfiles and restore backups
- `dotfiles-cleanup-backups` - prune old backup directories
- `zsh-dotfiles` - launch an isolated zsh session using this repo

`wb` creates a three-pane tmux layout with your editor, a shell, and an assistant pane. When the assistant is OpenCode, each `wb` launch picks its own port, exports `OPENCODE_PORT` into the panes it creates, and starts `opencode --port <port>` so the Neovim instance in that layout talks to the adjacent OpenCode session instead of a shared default port. Set `WB_OPENCODE_PORT` if you want to pin a specific port manually. You can also launch into a git worktree with `wb --with-worktree=<branch>` (or `-w <branch>`); it will reuse that branch's existing worktree when present, otherwise create one under `WB_WORKTREE_ROOT` (defaults to `~/.worktrees`) using a repo-scoped path like `~/.worktrees/Code/my-project/feature/my-branch` before opening the tmux layout there. If you prefer something like `~/Code/.worktrees`, set `WB_WORKTREE_ROOT` in `~/.config/zsh.local/env.zsh`.

Git worktrees are full working directories, so you can work from them normally with your editor, shell, tests, and helper commands. Dotfiles-linked commands like `wb`, `mdf`, `nvim`, and `tmux` are unaffected because they come from your shell setup, not the repo location. The main thing to remember is that repo-local dependencies and caches stay per worktree: Python `.venv` directories, `node_modules`, `.direnv`, and tool caches usually need to be created or refreshed inside each worktree. That is usually a good thing because it keeps branches isolated, but it means a new worktree may need its own `uv sync`, `poetry install`, `pip install`, `npm install`, or `direnv allow` before you start.

## Shell and Configs

Tracked config includes:

- zsh config, aliases, functions, completions, and plugins
- tmux config and helper layout tools
- Ghostty config and macOS key-repeat tuning
- Hyprland config for Linux/Arch environments
- Neovim config
- shared Git config plus local per-machine Git config support
- SSH config that uses local keys instead of the 1Password SSH agent

## 1Password Integration

1Password is optional but recommended.

The setup scripts currently expect these items:

- `git-signing-config`
  - `name`
  - `email`
  - `key_id`
  - `public_key`
  - `private_key`
- `Legacy SSH key`
  - standard 1Password SSH key item

If the 1Password CLI is unavailable:

- `setup-git-local` falls back to prompting for `user.name`, `user.email`, and `user.signingkey`
- `setup-ssh` requires 1Password and does not have a manual fallback

## Git Setup

Run either command:

```bash
mdf git
# or
setup-git-local
```

This will:

- generate `~/.config/git/config.local` from `common/git/gitconfig.local.tpl`
- import the GPG public and private key from 1Password into your local keyring
- validate that the imported secret key matches `key_id`
- link `common/git/gpg.conf` to `~/.gnupg/gpg.conf` for terminal-based signing

If terminal signing acts up, this usually helps:

```bash
export GPG_TTY=$(tty)
```

## SSH Setup

Run either command:

```bash
mdf ssh
# or
setup-ssh
```

This will:

- export the exact `Legacy SSH key` item from 1Password
- write the key to the conventional filename for its key type (`id_rsa`, `id_ed25519`, etc.)
- write the matching public key beside it
- link `common/ssh/config` into `~/.ssh/config`

For the current bundled key item, the exported filenames are:

- `~/.ssh/id_rsa`
- `~/.ssh/id_rsa.pub`

Add the public key to GitHub if needed:

```bash
cat ~/.ssh/id_rsa.pub
```

## Aliases

Examples:

```bash
g        # git
ga       # git add
gst      # git status
gd       # git diff
glog     # git log --oneline --decorate --graph
..       # cd ..
ll       # ls -la
v        # nvim
```

See everything with:

```bash
mdf aliases
# or
alias
```

## Customization

Keep local changes out of the repo by using `~/.config/zsh.local/`.

```bash
mkdir -p ~/.config/zsh.local/alias
mkdir -p ~/.config/zsh.local/completions
```

Local aliases:

```zsh
# ~/.config/zsh.local/alias/local.zsh
alias work='cd ~/Work/myproject'
alias aws-prod='aws --profile production'
```

Local environment variables:

```zsh
# ~/.config/zsh.local/env.zsh
export PATH="$HOME/custom-tools:$PATH"
export OPENAI_API_KEY="sk-..."
```

Machine-specific login-shell overrides:

```zsh
# ~/.config/zsh.local/profile.<short-hostname>.zsh
if [[ -S "$HOME/.colima/default/docker.sock" ]]; then
  export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"
fi
```

Use `env.zsh` for general local environment variables, `profile.zsh` or `profile.<short-hostname>.zsh` for login-shell overrides, and `rc.zsh` or `rc.<short-hostname>.zsh` for interactive-shell overrides. The short hostname is derived from `${HOST%%.*}`.

Generated completions are stored in `~/.config/zsh.local/completions/`.

## Structure

```text
common/
  bin/          user-facing tools linked to ~/.local/bin/
  ghostty/      shared Ghostty config
  git/          shared git config, template, and gpg.conf
  nvim/         shared Neovim config
scripts/        shared setup helpers
  ssh/          shared SSH config
  tmux/         shared tmux config
  zsh/          shared zsh env, rc, aliases, functions, completions, plugins
macos/
  Brewfile      macOS dependencies
  scripts/      macOS-only setup helpers
arch/
  hypr/         Hyprland config
  packages.txt  Arch repo packages
  aur-packages.txt
```

## Requirements

- macOS or Arch
- zsh
- Homebrew on macOS, `pacman` on Arch, and `paru` if you want AUR packages installed automatically
- 1Password CLI for automatic Git and SSH secret bootstrap

Dependencies are managed through `macos/Brewfile`, `arch/packages.txt`, and `arch/aur-packages.txt`.

- macOS formulas and casks live in `macos/Brewfile`
- Arch repo packages live in `arch/packages.txt`
- Arch AUR packages live in `arch/aur-packages.txt`

## Maintenance

Useful commands:

```bash
mdf doctor
mdf benchmark
mdf update
mdf cleanup
mdf uninstall --dry-run
```

You can also run the underlying tools directly:

```bash
dotfiles-doctor
dotfiles-update
dotfiles-uninstall
```

## Contributing

Pull requests are not accepted. This is an extremely opinionated personal setup tailored to my workflow.

Issues are welcome if you have questions or spot something broken.

Fork it freely and take whatever is useful.

## License

MIT
