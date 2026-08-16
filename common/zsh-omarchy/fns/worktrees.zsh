# oh-my-zsh's git plugin claims ga/gd as `git add`/`git diff`. In zsh an alias
# is resolved before a function of the same name, so these have to go for the
# Omarchy worktree helpers below to be reachable at all.
unalias ga 2>/dev/null
unalias gd 2>/dev/null

# Create a new worktree and branch from within current git directory.
ga() {
  emulate -L ksh

  if [[ -z "$1" ]]; then
    echo "Usage: ga [branch name]"
    return 1
  fi

  local branch="$1"
  local base="$(basename "$PWD")"
  local wt_path="../${base}--${branch}"

  git worktree add -b "$branch" "$wt_path"
  mise trust "$wt_path"
  cd "$wt_path"
}

# Remove worktree and branch from within active worktree directory.
gd() {
  emulate -L ksh

  if gum confirm "Remove worktree and branch?"; then
    local cwd base branch root worktree

    cwd="$(pwd)"
    worktree="$(basename "$cwd")"

    # split on first `--`
    root="${worktree%%--*}"
    branch="${worktree#*--}"

    # Protect against accidentally nuking a non-worktree directory
    if [[ "$root" != "$worktree" ]]; then
      cd "../$root"
      git worktree remove "$cwd" --force || return 1
      git branch -D "$branch"
    fi
  fi
}
