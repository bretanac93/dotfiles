typeset -gU fpath FPATH

if [[ -d "$ZSH_CONFIG_DIR/completions" ]]; then
  fpath=("$ZSH_CONFIG_DIR/completions" $fpath)
fi

if [[ -n "${HOMEBREW_PREFIX:-}" && -d "$HOMEBREW_PREFIX/share/zsh/site-functions" ]]; then
  fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)
fi

autoload -Uz compinit
compinit -C -i -d "${ZSH_COMPDUMP:-${ZDOTDIR:-$HOME}/.zcompdump}"
