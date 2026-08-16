# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Entry Points

- `./init.sh [--force-symlinks]` — idempotent bootstrap: symlinks configs, installs deps, sets up secrets
- `mdf <command>` — day-to-day management after first install (`mdf help` for full list)

Key `mdf` commands: `install`, `update`, `doctor`, `benchmark`, `deps`, `ssh`, `git`, `shortcuts`

## Architecture

Everything is symlinked into `~/.config/` and `~/.local/bin/` at install time — nothing is copied except `zsh.local/env.zsh`. Changing a tracked file takes effect immediately (no rebuild step).

**Platform split**: `common/` is shared across macOS and Linux. `macos/` is macOS-only. `arch/` is now just the two Arch dependency manifests — all desktop config was removed when this machine moved to Omarchy.

**Omarchy defers to Omarchy.** `init.sh` sets `on_omarchy` from `[[ -d /usr/share/omarchy ]]` and, when true, hands anything Omarchy already standardizes back to it. macOS is unaffected and still gets the full set.

| Config | On Omarchy | On macOS |
|---|---|---|
| nvim | **not linked** — Omarchy's LazyVim is used instead | `common/nvim` |
| tmux | thin layer over packaged config | `common/tmux/tmux.conf` |
| git | `gitconfig.omarchy` thin layer over `~/.config/git/config` | `common/git/gitconfig` |
| btop, ghostty, wallpaper | **not linked** — `omarchy theme set` rewrites these | ours |
| desktop (hypr, bar, launcher) | **not linked** — Omarchy owns them | n/a |

**Neovim: `common/nvim` is kept but skipped on Omarchy.** The two configs are unrelated — `common/nvim` drives `lazy.nvim` directly through `lua/user/` and never mentions LazyVim, while `~/.config/nvim` is the LazyVim starter Omarchy installs. Omarchy symlinks `lua/plugins/theme.lua` at `~/.local/state/omarchy/current/theme/neovim.lua`, and every theme's `neovim.lua` sets `colorscheme` on the `LazyVim/LazyVim` plugin spec. Since `common/nvim` never declares that plugin, linking it would leave the theme symlink pointing at something the spec never loads.

Set `DOTFILES_LINK_NVIM=1` to link `common/nvim` on Omarchy anyway.

The rule: if `omarchy theme set` or an `omarchy` command writes a file, we do not link over it. Linking our own would be silently reverted on the next theme change.

Dependency installs route through `omarchy pkg add` / `omarchy pkg aur add` when the `omarchy` CLI is present (idempotent, self-elevating, verified), falling back to `pacman`/`paru` otherwise.

**Dependency manifests**:
- `arch/packages.txt` — pacman packages
- `arch/aur-packages.txt` — paru/AUR packages
- `macos/Brewfile` — Homebrew formulas and casks

When adding a new tool, add it to the appropriate manifest so `install-deps` / `check-deps` pick it up.

## Shell (zsh)

`common/zsh-omarchy/` is the active shell config, symlinked to `~/.zshenv`, `~/.zshrc`, and `~/.config/zsh`. It is a zsh port of Omarchy's `/usr/share/omarchy/default/bash/` tree, layered on top of oh-my-zsh.

Load order (this is the whole design — nothing else is subtle):

1. `zshenv` → every zsh, including scripts. Sources Omarchy's `env-bootstrap` under `emulate sh`, sets `OMARCHY_PATH`, `ZSH_CONFIG_DIR`, `HISTFILE`, and toolchain paths.
2. `zshrc` → oh-my-zsh first (plugins, completions, **compinit**), then the Omarchy layer, then your own additions.
3. `rc.zsh` → sources `envs`, `shell`, `aliases`, `functions`, `keybindings`, `completions`, `init`, `local` in that order.

**The Omarchy layer loads after oh-my-zsh so it wins conflicts.** `ZSH_THEME` is deliberately empty — starship is the prompt, started by `init.zsh`.

**Function ports** in `fns/*.zsh` open with `emulate -L ksh`, which gives bash semantics locally (0-indexed arrays, `printf -v`, `%q`). Two things do not survive the emulation and are patched at each call site: `read -rp` (zsh puts the prompt in the variable name — `read -r "var?prompt"`) and `${str:i:1}` (needs `${str:$i:1}`). Also never name a local array `argv` — in zsh it aliases the positional parameters.

**Alias vs function precedence**: zsh resolves an alias before a function of the same name. `fns/worktrees.zsh` therefore has to `unalias ga gd` to reach Omarchy's worktree helpers, since oh-my-zsh's git plugin claims those names.

**Local overrides** (not tracked): `~/.config/zsh.local/alias/*.zsh`, `~/.config/zsh.local/env.zsh`, `~/.config/zsh.local/profile.<hostname>.zsh`. Machine-specific config goes here — `local.zsh` sources it last.

`common/zsh/` is the pre-Omarchy setup. Nothing links to it anymore; it is kept only for reference.

## tmux

On Omarchy, `common/tmux/omarchy.conf` is symlinked to `~/.config/tmux/tmux.conf`. It `source-file`s the packaged config from `/usr/share/omarchy/config/tmux/tmux.conf` rather than copying it, so `omarchy update` improvements arrive with no merge, then applies overrides — prefix is `C-s` with `C-Space` as secondary. Off Omarchy, `init.sh` falls back to linking the standalone `common/tmux/tmux.conf` to `~/.tmux.conf`.

## Desktop (Omarchy owns this)

This repo no longer carries any desktop configuration. Omarchy owns the compositor, status bar, launcher, notifications, GTK theming, and `.desktop` entries. The former `arch/{hypr,waybar,wofi,yazi,swaync,swayosd,walker,gtk,sddm,vivaldi,applications}` trees and the `common/bin/{hypr-*,waybar-*}` helper scripts were removed — recover them from git history if ever needed.

Customize the desktop through Omarchy instead:
- `~/.config/hypr/*.lua` — bindings, monitors, looknfeel, input, autostart
- `~/.config/omarchy/shell.json` — bar layout, widgets, idle behavior
- `omarchy theme set <name>`, `omarchy bar ...`, `omarchy hook install ...`

The `omarchy` skill covers this; use it rather than editing these by hand.

## Bin Scripts

All files in `common/bin/` and `scripts/` are symlinked to `~/.local/bin/` automatically. What remains is platform-neutral: the `dotfiles-*` management commands, `mdf`, `wt`/`wb` (worktrees), and `tmux-code-layout`.

## Commit Style

No `Co-Authored-By:` lines in commits. Conventional commits (`feat:`, `fix:`, `chore:`).

## Git Worktree Workflow

This repo manages a custom worktree tool (`wt`) at `common/bin/wt`.

### When to use worktrees

- Working on multiple branches/features simultaneously
- Need to run tests/builds on one branch while editing another
- Want to avoid `git stash` / `git checkout` context switches
- Long-running background tasks on one branch, active dev on another

### `wt` commands

| Command | Action |
|---|---|
| `wt feat/my-feature` | Create or switch to a worktree for the branch |
| `wt list` (or `ls`, `l`) | List all worktrees for the current repo |
| `wt rm feat/my-feature` (or `remove`) | Remove a worktree |
| `wt prune` | Remove all worktrees except the main one |

### How it works

- Worktrees are stored in `repo.worktrees/<sanitized-branch-name>/`
- The global `~/.gitignore` ignores `.worktrees/` directories
- `wt` can be run from any directory inside the repo, including from inside another worktree
- The `wt()` zsh function wrapper auto-`cd`s into the worktree directory
- Branch names can be gitflow-style (`feat/foo`, `chore/bar`) — slashes become dashes in directory names

### Integration with `wb`

`wb --with-worktree <branch>` (or `wb -w <branch>`) creates a tmux coding layout inside a worktree. It reuses existing worktrees or creates new ones under `WB_WORKTREE_ROOT` (default `~/.worktrees`).

### Best practices

- Clean up finished worktrees with `wt rm <branch>` or `wt prune`
- Never manually delete worktree directories — always use `wt rm` or `git worktree remove`
- The main worktree is protected — `wt rm` and `wt prune` will not remove it
