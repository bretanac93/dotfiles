zmodload zsh/complist 2>/dev/null || true

zstyle ':completion:*' use-cache true
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"
zstyle ':completion:*' menu select
zstyle ':completion:*' verbose no
zstyle ':completion:*' group-name ''
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' matcher-list \
  'm:{a-z}={A-Z}' \
  'r:|[._-]=* r:|=*'

zstyle ':completion:*:warnings' format 'no matches'

if [[ -n "${LS_COLORS:-}" ]]; then
  zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
fi
