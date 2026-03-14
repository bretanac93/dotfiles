typeset -gU fpath FPATH

local compdump_file

if [[ -d "$ZSH_CONFIG_DIR/completions" ]]; then
  fpath=("$ZSH_CONFIG_DIR/completions" $fpath)
fi

if [[ -n "${HOMEBREW_PREFIX:-}" && -d "$HOMEBREW_PREFIX/share/zsh/site-functions" ]]; then
  fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)
fi

autoload -Uz compinit
compdump_file="${ZSH_COMPDUMP:-${ZDOTDIR:-$HOME}/.zcompdump}.v2"
compinit -C -i -d "$compdump_file"
