[[ $- != *i* ]] && return

typeset -gU path PATH fpath FPATH

export ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-$HOME/.config/zsh}"
export ZSH_THEME="${ZSH_THEME:-mine}"
export HISTFILE="${ZSH_HISTORY_FILE:-$HISTFILE}"

if [[ -n "$SSH_CONNECTION" ]]; then
  export EDITOR="vim"
else
  export EDITOR="nvim"
fi

for lib_file in \
  "$ZSH_CONFIG_DIR/lib/options.zsh" \
  "$ZSH_CONFIG_DIR/lib/completion.zsh" \
  "$ZSH_CONFIG_DIR/lib/completion-styles.zsh" \
  "$ZSH_CONFIG_DIR/lib/prompt-git.zsh" \
  "$ZSH_CONFIG_DIR/lib/keybindings.zsh" \
  "$ZSH_CONFIG_DIR/lib/local.zsh" \
  "$ZSH_CONFIG_DIR/lib/aliases.zsh" \
  "$ZSH_CONFIG_DIR/lib/plugin-loader.zsh"; do
  if [[ -r "$lib_file" ]]; then
    source "$lib_file"
  fi
done

if typeset -f load_zsh_local_config >/dev/null 2>&1; then
  load_zsh_local_config
fi

if typeset -f load_zsh_plugins >/dev/null 2>&1; then
  load_zsh_plugins
fi

if typeset -f load_zsh_aliases >/dev/null 2>&1; then
  load_zsh_aliases
fi

theme_file="$ZSH_CONFIG_DIR/themes/${ZSH_THEME}.zsh-theme"
if [[ -r "$theme_file" ]]; then
  source "$theme_file"
fi
