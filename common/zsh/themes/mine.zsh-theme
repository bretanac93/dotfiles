autoload -Uz colors
colors

setopt prompt_subst

PROMPT=$'%{$fg[white]%}[%~]%{$reset_color%} $(prompt_git_info)\n%(?:%{$fg_bold[green]%}>>:%{$fg_bold[red]%}>>) %{$reset_color%}'
