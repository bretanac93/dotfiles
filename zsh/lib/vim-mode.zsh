#!/bin/zsh
#
# Vim mode for zsh command line editing
# Press Esc or Ctrl+[ to enter normal mode
# Press i/a to return to insert mode
#

# Enable vim mode
bindkey -v

# Reduce lag when entering normal mode (100ms)
export KEYTIMEOUT=10

# Better cursor indicators for different modes
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]]; then
    # Block cursor in normal mode
    echo -ne '\e[2 q'
  else
    # Beam cursor in insert mode
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select

# Initialize with beam cursor
function zle-line-init {
  echo -ne '\e[5 q'
}
zle -N zle-line-init

# Vim-style keybindings in insert mode
bindkey "^A" beginning-of-line          # Ctrl+a: beginning
bindkey "^E" end-of-line                # Ctrl+e: end
bindkey "^K" kill-line                  # Ctrl+k: delete to end
bindkey "^U" backward-kill-line         # Ctrl+u: delete to beginning
bindkey "^W" backward-kill-word         # Ctrl+w: delete word

# Allow Ctrl+R for history search in insert mode
bindkey "^R" history-incremental-search-backward

# Fix backspace in vi mode
bindkey "^?" backward-delete-char
bindkey "^H" backward-delete-char
