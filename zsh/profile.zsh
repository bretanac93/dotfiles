typeset -U path PATH

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [[ -r "$HOME/.config/envman/load.sh" ]]; then
  source "$HOME/.config/envman/load.sh"
fi

if [[ -r "$HOME/.orbstack/shell/init.zsh" ]]; then
  source "$HOME/.orbstack/shell/init.zsh"
fi

export LC_ALL="en_US.UTF-8"
export DOCKER_HOST="unix://$HOME/.orbstack/run/docker.sock"
export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
export GOPATH="${GOPATH:-$HOME/go}"
export OPENCODEPATH="$HOME/.opencode"
export LOCALBIN="$HOME/.local/bin"

path=(
  "$GOPATH/bin"
  "$OPENCODEPATH/bin"
  "$HOME/.composer/vendor/bin"
  "$HOME/.dotnet/tools"
  "$HOME/.cache/lm-studio/bin"
  "$LOCALBIN"
  $path
)

export PYENV_ROOT="$HOME/.pyenv"
if [[ -d "$PYENV_ROOT/bin" ]]; then
  path=("$PYENV_ROOT/bin" $path)
fi

if (( $+commands[pyenv] )); then
  eval "$(pyenv init - zsh --no-rehash)"
fi

if [[ -x /usr/libexec/java_home ]]; then
  export JAVA_HOME="${JAVA_HOME:-$(/usr/libexec/java_home -v 23 2>/dev/null)}"
fi

if [[ -n "${JAVA_HOME:-}" ]]; then
  export DYLD_LIBRARY_PATH="$JAVA_HOME/lib:${DYLD_LIBRARY_PATH:-}"
  path=("$JAVA_HOME/bin" $path)
fi

export PATH
