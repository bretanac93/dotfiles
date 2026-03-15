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
  alias/          # Tracked aliases
  functions/      # Shell functions (install-bin, gen-completion)
  completions/    # Custom completions
  lib/            # Core setup (prompt, completion, keybindings)
  plugins/        # Plugin loading

scripts/
  wb              # Tmux workbench
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
