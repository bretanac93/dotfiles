# Port of $OMARCHY_PATH/default/bash/init — activate the tool integrations.
# Runs after completions.zsh so compdef exists for fzf and zoxide.

(( $+commands[mise] )) && eval "$(mise activate zsh)"

if [[ -o interactive ]] && [[ "${TERM:-}" != "dumb" ]] && (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi

(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# Defer `try`'s init until first use — it is slow and rarely needed.
if (( $+commands[try] )); then
  try() {
    unfunction try
    eval "$(SHELL=$(command -v zsh) command try init ~/Work/tries)"
    try "$@"
  }
fi

if (( $+commands[fzf] )); then
  # Arch ships these; newer fzf can also emit them via `fzf --zsh`.
  if [[ -f /usr/share/fzf/completion.zsh ]]; then
    source /usr/share/fzf/completion.zsh
  fi
  if [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
    source /usr/share/fzf/key-bindings.zsh
  elif fzf --zsh &>/dev/null; then
    eval "$(fzf --zsh)"
  fi
fi
