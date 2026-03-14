prompt_git() {
  GIT_OPTIONAL_LOCKS=0 command git "$@"
}

prompt_git_info() {
  local ref dirty

  prompt_git rev-parse --git-dir >/dev/null 2>&1 || return 0

  ref="$(prompt_git symbolic-ref --quiet --short HEAD 2>/dev/null)" \
    || ref="$(prompt_git describe --tags --exact-match HEAD 2>/dev/null)" \
    || ref="$(prompt_git rev-parse --short HEAD 2>/dev/null)" \
    || return 0

  if [[ -n "$(prompt_git status --porcelain --ignore-submodules=dirty 2>/dev/null)" ]]; then
    dirty=" %{$fg[red]%}*%{$fg[green]%}"
  fi

  print -nr -- "%{$fg[green]%}(${ref//\%/%%}${dirty})%{$reset_color%}"
}
