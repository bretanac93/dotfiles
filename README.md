# dotfiles

A minimal, fast, and maintainable macOS development environment.

## Features

- **Native zsh** - No Oh-My-Zsh, pure zsh with ~60ms startup time
- **Single-command setup** - Run `./init.sh` and everything works
- **Work/personal separation** - Local configs in `~/.config/zsh.local/`
- **Auto-dependency management** - Brewfile parsed automatically
- **Fast tmux workflow** - `wb` command for instant dev environments

## Quick Start

```bash
# Clone and setup
git clone https://github.com/bretanac93/dotfiles ~/Code/dotfiles
cd ~/Code/dotfiles
./init.sh
```

That's it. Your shell, tmux, nvim, and ghostty are configured.

## What's Included

**Shell (zsh)**
- Syntax highlighting
- Git prompt
- 60+ aliases (git, navigation)
- Completions for custom tools

**Tools**
- `wb` - Launch editor + terminal + AI assistant in tmux
- `install-bin` - Install binaries to `~/.local/bin`
- `gen-completion` - Generate zsh completions
- `check-deps` - Verify Brewfile dependencies

**Configs**
- tmux with macOS clipboard
- Ghostty with key repeat tuning
- nvim with LSP

## Structure

```
zsh/
  rc.zsh          # Main zsh config (~/.zshrc)
  env.zsh         # Environment vars (~/.zshenv)
  profile.zsh     # Login shell config (~/.zprofile)
  alias/          # Tracked aliases
  functions/      # Shell functions
  completions/    # Custom completions
  lib/            # Core setup
  plugins/        # Plugin loading

git/
  gitconfig       # Shared git config
  gitconfig.local.tpl  # Template for local config
  gpg.conf        # GPG terminal signing config

tmux/
  tmux.conf       # Tmux configuration

ssh/
  config          # SSH configuration

scripts/
  wb              # Tmux workbench
  setup-git-local # Git config with GPG signing
  setup-ssh       # SSH keys from 1Password
  check-deps      # Dependency checker
  macos-defaults  # System tuning

~/.config/zsh.local/
  alias/          # Your local aliases (untracked)
  completions/    # Generated completions (untracked)
```

## Customization

Add your own aliases without touching the repo:

```bash
# ~/.config/zsh.local/alias/work.zsh
alias aws-sso='aws sso login'
alias kctx-dev='kubectl config use-context dev'
```

### Git Configuration

Personal git info (name, email, signing key) is stored separately from the shared config using 1Password templates:

```bash
# Run this after init.sh to set up your local git config
# Requires 1Password CLI (optional - can enter manually if not available)
setup-git-local
```

This uses `op inject` to populate `~/.config/git/config.local` from `git/gitconfig.local.tpl`, which contains:
- Your name and email (from 1Password "git-signing-config" item)
- GPG key ID for signing (from 1Password "git-signing-config" item)
- GPG program path (portable across macOS/Linux)

The setup script also exports your GPG keys from 1Password and imports them into your local keyring. A `git/gpg.conf` is included to enable terminal-based signing (no GUI prompts).

The shared `gitconfig` includes this file automatically.

**Note:** GPG must be installed (usually comes with macOS or Linux). The setup script exports keys from 1Password and configures git to use them.

**Passphrase:** Your GPG key has a passphrase. When signing commits, GPG will prompt for it in the terminal (no GUI). This happens once per session or you can configure GPG to cache it.

### SSH Configuration

SSH keys are stored in 1Password and exported to `~/.ssh/` during setup:

```bash
# Run this after init.sh to export your SSH keys
setup-ssh
```

This exports your "Legacy SSH key" from 1Password to:
- `~/.ssh/id_ed25519` (private key)
- `~/.ssh/id_ed25519.pub` (public key)

The SSH config is automatically linked and configured for GitHub authentication.

**Note:** You'll need to add the public key to your GitHub account if not already done:
```bash
cat ~/.ssh/id_ed25519.pub
# Copy and paste into GitHub → Settings → SSH and GPG keys
```

## Requirements

- macOS (Apple Silicon)
- Homebrew
- zsh

Dependencies auto-install via Brewfile.

## Contributing

**Pull requests are not accepted.** This is an extremely opinionated personal setup tailored to my specific workflow and preferences.

**Issues are welcome.** Feel free to open an issue if you have questions or suggestions. I will evaluate whether they align with my needs and may or may not implement them.

**Forks and free use are encouraged.** Take anything you find useful. This comes without warranty or liability—use at your own risk.

## License

MIT - Do whatever you want.
