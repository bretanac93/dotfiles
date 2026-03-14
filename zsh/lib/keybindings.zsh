autoload -Uz edit-command-line
autoload -Uz select-word-style
autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zmodload zsh/terminfo 2>/dev/null || true

bindkey -e
zle -N edit-command-line
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
select-word-style bash

bindkey '^P' up-line-or-beginning-search
bindkey '^N' down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[OA' up-line-or-beginning-search
bindkey '^[OB' down-line-or-beginning-search
bindkey '^X^E' edit-command-line

if [[ -n "${terminfo[kcuu1]:-}" ]]; then
  bindkey "$terminfo[kcuu1]" up-line-or-beginning-search
fi

if [[ -n "${terminfo[kcud1]:-}" ]]; then
  bindkey "$terminfo[kcud1]" down-line-or-beginning-search
fi

bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[OH' beginning-of-line
bindkey '^[OF' end-of-line

bindkey '^[b' backward-word
bindkey '^[f' forward-word
bindkey '^[d' kill-word
bindkey '^[^?' backward-kill-word

bindkey '^[[1;3D' backward-word
bindkey '^[[1;3C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[1;9D' backward-word
bindkey '^[[1;9C' forward-word
