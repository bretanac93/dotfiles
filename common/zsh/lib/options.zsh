typeset -gi HISTSIZE SAVEHIST KEYTIMEOUT

HISTSIZE="${ZSH_HISTORY_SIZE:-100000}"
SAVEHIST="${ZSH_SAVEHIST:-$HISTSIZE}"
KEYTIMEOUT="${ZSH_KEYTIMEOUT:-10}"

setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushd_silent
setopt interactive_comments
setopt no_beep

setopt append_history
setopt extended_history
setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt inc_append_history
setopt share_history

WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# Enable color support for ls and other tools
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

if [[ -t 0 ]]; then
  stty -ixon 2>/dev/null || true
fi
