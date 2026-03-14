if (( $+commands[fzf] )) && [[ -o interactive ]]; then
  eval "$(fzf --zsh 2>/dev/null)" 2>/dev/null

  if zle -l fzf-cd-widget >/dev/null 2>&1; then
    bindkey '^[c' fzf-cd-widget
    bindkey '^[C' fzf-cd-widget
  fi
fi

if [[ -z "${FZF_DEFAULT_COMMAND:-}" ]]; then
  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
  elif (( $+commands[rg] )); then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git/*"'
  fi
fi

if [[ -z "${FZF_ALT_C_COMMAND:-}" ]] && (( $+commands[fd] )); then
  export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
fi
