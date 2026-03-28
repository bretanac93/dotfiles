# Setup fpath for completions (compinit runs later in compinit.zsh)

# Add repo completions
if [[ -d "$ZSH_CONFIG_DIR/completions" ]]; then
  fpath=("$ZSH_CONFIG_DIR/completions" $fpath)
fi

# Add local completions
local local_completions="${ZSH_LOCAL_CONFIG_DIR:-$HOME/.config/zsh.local}/completions"
if [[ -d "$local_completions" ]]; then
  fpath=("$local_completions" $fpath)
fi

# Add Homebrew completions
if [[ -n "${HOMEBREW_PREFIX:-}" && -d "$HOMEBREW_PREFIX/share/zsh/site-functions" ]]; then
  fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)
fi
