# Port of $OMARCHY_PATH/default/bash/envs, with fallbacks so the layer also works
# on machines that have no Omarchy installed.

# Editor used by CLI
if (( $+commands[omarchy-launch-editor] )); then
  export EDITOR="${EDITOR:-omarchy-launch-editor --inline}"
elif [[ -n "$SSH_CONNECTION" ]]; then
  export EDITOR="${EDITOR:-vim}"
else
  export EDITOR="${EDITOR:-nvim}"
fi
export SUDO_EDITOR="$EDITOR"

# Used by terminal programs (like gh) to open URLs detached from the terminal
# process tree. Shell-scoped on purpose: exporting BROWSER session-wide makes
# xdg-settings refuse to change the default browser.
(( $+commands[omarchy-launch-browser] )) && export BROWSER="${BROWSER:-omarchy-launch-browser}"

# Color man pages with bat
if (( $+commands[bat] )); then
  export BAT_THEME=ansi
  export MANROFFOPT="-c"
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# /etc/profile.d/locale.sh is what puts /etc/locale.conf into the environment,
# and it only runs for login shells. A shell started by SSH misses it and lands
# in the C locale, where printf emits \u/\U escapes literally instead of the
# character. Mirror locale.sh for those sessions.
if [[ -z "$LANG" ]]; then
  [[ -r /etc/locale.conf ]] && emulate sh -c 'source /etc/locale.conf'
  export LANG="${LANG:-C.UTF-8}"
fi
