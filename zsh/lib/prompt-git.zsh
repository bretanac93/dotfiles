prompt_git() {
  GIT_OPTIONAL_LOCKS=0 command git "$@"
}

prompt_git_info() {
  local git_status_output branch_head branch_oid ref dirty line

  git_status_output="$(prompt_git status --porcelain=2 --branch --ignore-submodules=dirty 2>/dev/null)" || return 0

  for line in ${(f)git_status_output}; do
    case "$line" in
      '# branch.head '*)
        branch_head="${line#\# branch.head }"
        ;;
      '# branch.oid '*)
        branch_oid="${line#\# branch.oid }"
        branch_oid="${branch_oid%% *}"
        ;;
      '# '*)
        ;;
      *)
        dirty=" %{$fg[red]%}*%{$fg[green]%}"
        ;;
    esac
  done

  case "$branch_head" in
    '(detached)')
      ref="$(prompt_git describe --tags --exact-match HEAD 2>/dev/null)"
      ref="${ref:-${branch_oid[1,7]}}"
      ;;
    '(unknown)'|'')
      ref="${branch_oid[1,7]}"
      ;;
    *)
      ref="$branch_head"
      ;;
  esac

  print -nr -- "%{$fg[green]%}(${ref//\%/%%}${dirty})%{$reset_color%}"
}
