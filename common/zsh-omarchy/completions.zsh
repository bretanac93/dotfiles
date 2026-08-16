# Completion tweaks layered on top of oh-my-zsh.
#
# oh-my-zsh already runs compinit and sets matcher-list from CASE_SENSITIVE /
# HYPHEN_INSENSITIVE, so this file only adds what it doesn't cover — mostly the
# behaviour Omarchy configures through readline in default/bash/inputrc.

# Local completions win over oh-my-zsh's and the system site-functions.
fpath=("$ZSH_CONFIG_DIR/completions" "$HOME/.config/zsh.local/completions" $fpath)

# mark-symlinked-directories on
setopt MARK_DIRS
# completion-query-items 200 — ask before dumping a huge candidate list
LISTMAX=200

# Omarchy dispatches `omarchy <group> <action>` to omarchy-<group>-<action>
# binaries. Walk that naming scheme to offer the next path segment, and keep the
# individual omarchy-* binaries out of command completion like the bash setup does.
if (( $+commands[omarchy] )); then
  _omarchy_complete() {
    local bin_dir prefix part file rest next i
    local -a candidates
    bin_dir="${$(readlink -f -- "$commands[omarchy]"):h}"
    [[ -d $bin_dir ]] || return 0

    prefix="omarchy"
    for (( i = 2; i < CURRENT; i++ )); do
      part="${words[i]}"
      [[ -z $part || $part == -* ]] && continue
      prefix+="-$part"
    done

    for file in "$bin_dir/$prefix"-*(N-*); do
      rest="${${file:t}#${prefix}-}"
      next="${rest%%-*}"
      [[ -n $next ]] && candidates+=("$next")
    done

    (( CURRENT == 2 )) && candidates+=("commands")
    [[ "${words[2]}" == "commands" ]] && (( CURRENT >= 3 )) &&
      candidates+=("--all" "--json" "--markdown" "--check")

    if (( ${#candidates} )); then
      _describe -t omarchy 'omarchy command' candidates
    else
      _files
    fi
  }
  compdef _omarchy_complete omarchy
  # Hide the individual dispatch targets from bare command completion.
  zstyle ':completion:*:-command-:*' ignored-patterns 'omarchy-*'
fi
