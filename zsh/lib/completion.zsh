typeset -gU fpath FPATH

# Add repo completions (tracked functions)
if [[ -d "$ZSH_CONFIG_DIR/completions" ]]; then
  fpath=("$ZSH_CONFIG_DIR/completions" $fpath)
fi

# Add local completions (generated from external binaries)
if [[ "${ZSH_LOAD_LOCAL_CONFIG:-1}" != "0" ]]; then
  local local_completions="${ZSH_LOCAL_CONFIG_DIR:-$HOME/.config/zsh.local}/completions"
  if [[ -d "$local_completions" ]]; then
    fpath=("$local_completions" $fpath)
  fi
fi

if [[ -n "${HOMEBREW_PREFIX:-}" && -d "$HOMEBREW_PREFIX/share/zsh/site-functions" ]]; then
  fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)
fi

# Note: compinit will be called at the end of rc.zsh after all fpath setup is complete
