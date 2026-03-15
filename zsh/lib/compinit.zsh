# Run compinit at the end of shell initialization
# This file must be loaded LAST to ensure all fpath modifications are complete

autoload -Uz compinit

local compdump_file="${ZSH_COMPDUMP:-${ZDOTDIR:-$HOME}/.zcompdump}.v2"

# Rebuild completion cache if:
# - compdump doesn't exist
# - Any completion file is newer than compdump
local rebuild=0
if [[ ! -f "$compdump_file" ]]; then
  rebuild=1
elif [[ -n "$(find ${fpath[@]} -name '_*' -newer "$compdump_file" 2>/dev/null | head -1)" ]]; then
  rebuild=1
fi

if [[ $rebuild -eq 1 ]]; then
  compinit -d "$compdump_file"
else
  compinit -C -d "$compdump_file"
fi
