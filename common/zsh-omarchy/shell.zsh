# Port of $OMARCHY_PATH/default/bash/shell — history, shell options, PATH hygiene.

# History. Omarchy's bash uses HISTCONTROL=ignoreboth (dupes + leading space).
# HISTFILE itself is set in zshenv, ahead of oh-my-zsh.
HISTSIZE=32768
SAVEHIST=$HISTSIZE

setopt APPEND_HISTORY INC_APPEND_HISTORY SHARE_HISTORY EXTENDED_HISTORY
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS
setopt HIST_VERIFY HIST_NO_STORE

# Navigation
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT

# Misc quality of life
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
setopt LONG_LIST_JOBS

# Free Ctrl-S / Ctrl-Q from XON/XOFF flow control. Required for the Ctrl-S tmux
# prefix to reach tmux instead of freezing the terminal. unsetopt covers zsh's
# line editor; stty covers everything else running in the terminal.
setopt NO_FLOW_CONTROL
[[ -t 0 ]] && stty -ixon 2>/dev/null

# Equivalent of bash's `set +h` — don't cache command locations, so mise shims
# resolve to the current tool version after a `mise use`.
setopt NO_HASH_CMDS NO_HASH_DIRS

# Dedupe PATH/FPATH in place
typeset -gU path PATH fpath FPATH
