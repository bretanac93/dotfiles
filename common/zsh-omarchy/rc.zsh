# Entry point for the zsh layer — the counterpart to $OMARCHY_PATH/default/bash/rc.
#
# Sourced by ~/.zshrc *after* oh-my-zsh, so everything here overrides it.
#
# Load order matters: envs before anything that reads EDITOR, completions before
# init because fzf and zoxide register widgets with compdef, and local last so
# machine-specific overrides win. compinit itself is oh-my-zsh's job.

: "${ZSH_CONFIG_DIR:=${${(%):-%N}:A:h}}"
: "${OMARCHY_PATH:=/usr/share/omarchy}"

for _zsh_part in envs shell aliases functions keybindings completions init local; do
  [[ -r "$ZSH_CONFIG_DIR/$_zsh_part.zsh" ]] && source "$ZSH_CONFIG_DIR/$_zsh_part.zsh"
done
unset _zsh_part
