if [[ "$(uname)" != "Linux" ]]; then return; fi

if (( $+commands[paru] )); then
  alias p='paru'
  alias pi='paru -S'
  alias pr='paru -Rs'
  alias pu='paru -Syu'
  alias pkg='paru -Qs'
  alias pkgs='paru -Ss'
fi

alias pm='sudo pacman'
alias pmi='sudo pacman -S'
alias pmr='sudo pacman -Rs'
alias pmu='sudo pacman -Syu'
alias pml='pacman -Qs'
alias pms='pacman -Ss'
