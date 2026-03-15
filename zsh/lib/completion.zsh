typeset -gU fpath FPATH

# Ensure ZSH_CONFIG_DIR is set
ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-$HOME/.config/zsh}"

# Add repo completions (tracked functions)
if [[ -d "$ZSH_CONFIG_DIR/completions" ]]; then
  fpath=("$ZSH_CONFIG_DIR/completions" $fpath)
fi

# Add local completions (generated from external binaries)
local local_completions="${ZSH_LOCAL_CONFIG_DIR:-$HOME/.config/zsh.local}/completions"
if [[ -d "$local_completions" ]]; then
  fpath=("$local_completions" $fpath)
fi

# Add Homebrew completions if available
if [[ -n "${HOMEBREW_PREFIX:-}" && -d "$HOMEBREW_PREFIX/share/zsh/site-functions" ]]; then
  fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)
fi
