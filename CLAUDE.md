# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Entry Points

- `./init.sh [--force-symlinks]` — idempotent bootstrap: symlinks configs, installs deps, sets up secrets
- `mdf <command>` — day-to-day management after first install (`mdf help` for full list)

Key `mdf` commands: `install`, `update`, `doctor`, `benchmark`, `deps`, `ssh`, `git`, `shortcuts`

## Architecture

Everything is symlinked into `~/.config/` and `~/.local/bin/` at install time — nothing is copied except `zsh.local/env.zsh`. Changing a tracked file takes effect immediately (no rebuild step).

**Platform split**: `common/` is shared across macOS and Linux. `arch/` is Linux/Hyprland-only. `macos/` is macOS-only. `init.sh` guards Arch-specific links with `[[ "$(uname)" == "Linux" ]]`.

**Dependency manifests**:
- `arch/packages.txt` — pacman packages
- `arch/aur-packages.txt` — paru/AUR packages
- `macos/Brewfile` — Homebrew formulas and casks

When adding a new tool, add it to the appropriate manifest so `install-deps` / `check-deps` pick it up.

## Shell (zsh)

`common/zsh/rc.zsh` is the `.zshrc`. It loads lib files in order, then aliases, then plugins, then the theme. The load sequence matters — vim-mode is sourced last to win keybinding conflicts.

**Aliases** live in `common/zsh/alias/*.zsh` — every `.zsh` file in that directory is auto-sourced. Add a new alias file and it's picked up without touching `rc.zsh`.

**Local overrides** (not tracked): `~/.config/zsh.local/alias/`, `~/.config/zsh.local/env.zsh`, `~/.config/zsh.local/profile.<hostname>.zsh`. Use these for machine-specific config.

## Hyprland / Waybar (Arch only)

`arch/hypr/hyprland.conf` includes split conf files from `arch/hypr/conf/`:
- `variables.conf` — `$mainMod`, `$terminal`, `$fileManager`
- `autostart.conf` — daemons and startup apps
- `keybinds.conf` — all keybindings
- `monitors.conf` — monitor layout
- `rules.conf` — window rules
- `theme.conf` — gaps, borders, animations
- `input.conf` — keyboard/mouse settings

**Waybar** custom modules run scripts from `common/bin/waybar-*`. They output JSON `{text, tooltip, class}`. Phosphor icons are embedded as raw Unicode PUA characters (U+E000+) — the Edit tool strips these silently. Always write Phosphor codepoints using Python: `chr(0xEXXX)`, never paste the glyph directly.

`arch/waybar/style.css` sets `font-family: "Phosphor"` on icon modules. The font is `ttf-phosphor-icons` from AUR.

## Bin Scripts

All files in `common/bin/` and `scripts/` are symlinked to `~/.local/bin/` automatically. Scripts prefixed `hypr-` are Hyprland helpers (menus, screenshot, clipboard, etc.). Scripts prefixed `waybar-` are custom waybar module executors.

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
