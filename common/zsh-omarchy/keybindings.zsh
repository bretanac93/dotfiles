# Keybindings layered on top of oh-my-zsh's lib/key-bindings.zsh.
#
# oh-my-zsh already sets the emacs keymap and binds the arrow keys to
# up/down-line-or-beginning-search (the history-prefix search Omarchy configures
# in default/bash/inputrc). What's left is the readline behaviour it doesn't set.

# Cycle forward and backward through completion candidates (tab / shift+tab),
# completing the common prefix first — inputrc's TAB: menu-complete plus
# menu-complete-display-prefix.
bindkey '^I' menu-complete
bindkey '^[[Z' reverse-menu-complete

# bash kills to the start of the line; zsh's default kills the whole line.
bindkey '^U' backward-kill-line
