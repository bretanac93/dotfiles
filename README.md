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

**Tools** (in `~/.local/bin/`)
- `wb` - Launch editor + terminal + AI assistant in tmux
- `check-deps` - Verify Brewfile dependencies
- `setup-git-local` - Configure git with GPG signing from 1Password
- `setup-ssh` - Export SSH keys from 1Password
- `dotfiles-doctor` - Health check - verify everything works
- `dotfiles-uninstall` - Clean removal with backup restoration
- `dotfiles-update` - Pull latest changes and re-run init

**Zsh Functions** (auto-loaded)
- `install-bin` - Install binaries to `~/.local/bin`
- `gen-completion` - Generate zsh completions

**Configs**
- zsh with syntax highlighting and git prompt
- tmux with macOS clipboard
- Ghostty with key repeat tuning
- nvim with LSP
- Git with GPG signing
- SSH with local keys (no 1Password agent)

## Maintenance

Check if everything is working:
```bash
dotfiles-doctor
```

Update to latest version:
```bash
dotfiles-update
```

Remove dotfiles (restores from backup):
```bash
# Preview what would be removed
dotfiles-uninstall --dry-run

# Actually remove
dotfiles-uninstall
```

All existing configs are backed up to `~/.dotfiles-backups/YYYYMMDD-HHMMSS/` before being replaced.

## Customization

Add your own aliases, environment variables, and completions without touching the repo:

```bash
# Create local config directory structure
mkdir -p ~/.config/zsh.local/alias
mkdir -p ~/.config/zsh.local/completions
```

**Aliases** (`~/.config/zsh.local/alias/local.zsh`):
```zsh
# Example: add work-specific shortcuts
alias work='cd ~/Work/myproject'
alias aws-prod='aws --profile production'
```
See `zsh/examples/alias.example.zsh` for more examples.

**Environment Variables** (`~/.config/zsh.local/env.zsh`):
```zsh
# Example: add API keys or custom paths
export PATH="$HOME/custom-tools:$PATH"
export OPENAI_API_KEY="sk-..."
```
See `zsh/examples/env.example.zsh` for more examples.

**Completions** (auto-generated):
```bash
# When you install a new binary with 'install-bin', completions are
# automatically generated and saved to ~/.config/zsh.local/completions/
```

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
  examples/       # Example local configs

~/.config/zsh.local/  (not in repo, auto-created)
  alias/          # Your local aliases
  completions/    # Generated completions

git/
  gitconfig       # Shared git config
  gitconfig.local.tpl  # Template for local config
  gpg.conf        # GPG terminal signing config

tmux/
  tmux.conf       # Tmux configuration

ssh/
  config          # SSH configuration

bin/            # User tools (linked to ~/.local/bin)
  wb              # Tmux workbench
  tmux-code-layout # Tmux layout implementation
  dotfiles-doctor # Health check
  dotfiles-uninstall # Clean removal
  dotfiles-update # Update dotfiles

scripts/        # Init dependencies and setup scripts
  setup-git-local # Git config with GPG signing
  setup-ssh       # SSH keys from 1Password
  check-deps      # Dependency checker
  macos-defaults  # System tuning
  zsh-dotfiles    # Isolated zsh testing

~/.config/zsh.local/  (not in repo, auto-created)
  alias/          # Your local aliases
  completions/    # Generated completions
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

**Note:** The 1Password SSH agent is automatically disabled in this setup. SSH will use your local `~/.ssh/id_ed25519` key directly without agent prompts. This is configured in both `ssh/config` (IdentityAgent none) and `zsh/env.zsh` (unsets 1Password's SSH_AUTH_SOCK).

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
