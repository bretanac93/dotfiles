if (( $+commands[lsd] )); then
  alias ls='lsd'
  alias l='ls -l'
  alias la='ls -a'
  alias ll='ls -la'
  alias lt='ls --tree'
  alias lla='ls -lA'
  alias l.='ls -d .*'
elif (( $+commands[exa] )); then
  alias ls='exa'
  alias l='exa -l'
  alias la='exa -a'
  alias ll='exa -la'
  alias lt='exa --tree'
  alias lla='exa -la'
  alias l.='exa -d .*'
else
  # Standard ls with color (macOS uses -G, GNU uses --color=auto)
  if [[ "$(uname)" == "Darwin" ]]; then
    alias ls='ls -G'
  else
    alias ls='ls --color=auto'
  fi
  alias l='ls -lFh'
  alias la='ls -lah'
  alias ll='ls -lAFh'
  alias l.='ls -d .*'
fi

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias -- -='cd -'

cd() {
  if (( $# == 1 )) && [[ "$1" == ...* ]] && [[ "$1" != *[^.]* ]]; then
    local depth=${#1}
    local target='..'

    while (( depth > 3 )); do
      target+='/..'
      (( depth-- ))
    done

    builtin cd "$target"
    return
  fi

  builtin cd "$@"
}
