# Port of $OMARCHY_PATH/default/bash/aliases. Everything is guarded on the tool
# existing, so this file is safe to load on a machine without the Omarchy stack.

# File system
if (( $+commands[eza] )); then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
fi

if [[ "$TERM" == "xterm-kitty" ]]; then
  alias ff="fzf --preview 'case \$(file --mime-type -b {}) in image/*) kitty icat --clear --transfer-mode=memory --stdin=no --place=\${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES}@0x0 {} ;; *) bat --style=numbers --color=always {} ;; esac'"
else
  alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
fi
alias eff='$EDITOR "$(ff)"'

sff() {
  emulate -L ksh
  if [ $# -eq 0 ]; then echo "Usage: sff <destination> (e.g. sff host:/tmp/)"; return 1; fi
  local file
  file=$(find . -type f -printf '%T@\t%p\n' | sort -rn | cut -f2- | ff) && [ -n "$file" ] && scp "$file" "$1"
}

if (( $+commands[zoxide] )); then
  alias cd="zd"
  zd() {
    emulate -L ksh
    if (( $# == 0 )); then
      builtin cd ~ || return
    elif [[ -d $1 ]]; then
      builtin cd "$1" || return
    else
      if ! z "$@"; then
        echo "Error: Directory not found"
        return 1
      fi

      printf "\U000F17A9 "
      pwd
    fi
  }
fi

# macOS already ships an `open`; only stand one up where xdg-open is the way.
if [[ "$OSTYPE" != darwin* ]] && (( $+commands[xdg-open] )); then
  open() (
    xdg-open "$@" >/dev/null 2>&1 &
  )
fi

# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Tools
alias a='omarchy-agent --inline'
alias c='opencode --auto'
alias cx='printf "\033[2J\033[3J\033[H" && claude --permission-mode bypassPermissions'
alias cy='codex -s danger-full-access -a never'
alias d='docker'
alias r='rails'
alias t='tmux attach || tmux new -s Work'
alias h='herdr'
alias ic='tdl c'
alias ix='tdl cx'
alias icx='tdl c cx'
alias mup='MISE_MINIMUM_RELEASE_AGE=0 mise up'

n() {
  emulate -L ksh
  if [ "$#" -eq 0 ]; then command nvim . ; else command nvim "$@"; fi
}

# Git
alias g='git'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'
