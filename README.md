# dotfiles

Minimal, opinionated macOS development environment built around native zsh, tmux, Neovim, Ghostty, and a small set of setup scripts.

## Highlights

- Native zsh setup with no Oh-My-Zsh
- One main entry point: `mdf`
- Idempotent setup with backups in `~/.dotfiles-backups/YYYYMMDD-HHMMSS/`
- Brewfile dependency checks during install
- 1Password-backed Git signing and SSH key export
- Installed helper scripts work from `~/.local/bin` in any directory

## Quick Start

```bash
git clone https://github.com/bretanac93/dotfiles ~/Code/dotfiles
cd ~/Code/dotfiles
./init.sh
```

After the first install, use `mdf` for day-to-day management.

## Daily Use

```bash
mdf install              # Run init again
mdf update               # Pull latest changes and re-run setup
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
- check the `Brewfile` and install missing dependencies if Homebrew is available
- apply macOS defaults from `scripts/macos-defaults`
- optionally bootstrap Git and SSH secrets from 1Password

## Included Tools

Tools linked into `~/.local/bin/`:

- `mdf` - main dotfiles manager
- `wb` - launch editor + terminal + AI assistant in tmux
- `check-deps` - verify Brewfile dependencies
- `setup-git-local` - configure git with GPG signing
- `setup-ssh` - export SSH keys from 1Password
- `dotfiles-doctor` - health checks
- `dotfiles-benchmark` - benchmark zsh startup time
- `dotfiles-update` - pull latest changes and re-run setup
- `dotfiles-uninstall` - remove dotfiles and restore backups
- `dotfiles-cleanup-backups` - prune old backup directories
- `zsh-dotfiles` - launch an isolated zsh session using this repo

## Shell and Configs

Tracked config includes:

- zsh config, aliases, functions, completions, and plugins
- tmux config and helper layout tools
- Ghostty config and macOS key-repeat tuning
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

- generate `~/.config/git/config.local` from `git/gitconfig.local.tpl`
- import the GPG public and private key from 1Password into your local keyring
- validate that the imported secret key matches `key_id`
- link `git/gpg.conf` to `~/.gnupg/gpg.conf` for terminal-based signing

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
- link `ssh/config` into `~/.ssh/config`

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

Generated completions are stored in `~/.config/zsh.local/completions/`.

## Structure

```text
bin/            user-facing tools linked to ~/.local/bin/
git/            shared git config, template, and gpg.conf
ghostty/        Ghostty config
nvim/           Neovim config
scripts/        setup helpers and system scripts
ssh/            SSH config
tmux/           tmux config
zsh/            zsh env, rc, aliases, functions, completions, plugins
```

## Requirements

- macOS
- zsh
- Homebrew
- 1Password CLI for automatic Git and SSH secret bootstrap

Dependencies are managed through `Brewfile`.

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
