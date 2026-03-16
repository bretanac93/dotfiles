export CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"

if [[ -r "$CARGO_HOME/env" ]]; then
  . "$CARGO_HOME/env"
fi

# Disable 1Password SSH agent - use local keys only
# This ensures SSH uses ~/.ssh/ keys directly instead of 1Password agent
if [[ "$SSH_AUTH_SOCK" == *"1password"* ]] || [[ "$SSH_AUTH_SOCK" == *"com.1password"* ]]; then
  unset SSH_AUTH_SOCK
fi

_source_local_configs() {
  [[ "${ZSH_LOAD_LOCAL_CONFIG:-1}" == "0" ]] && return 0
  local _dir="${ZSH_LOCAL_CONFIG_DIR:-$HOME/.config/zsh.local}"
  local _host="${HOST%%.*}" _prefix _f
  for _prefix in "$@"; do
    for _f in "$_dir/${_prefix}.zsh" "$_dir/${_prefix}.${_host}.zsh"; do
      [[ -r "$_f" ]] && source "$_f"
    done
  done
}

_source_local_configs env
