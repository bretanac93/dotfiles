load_zsh_alias_dir() {
  local alias_dir="$1"
  local alias_file

  for alias_file in "$alias_dir"/*.zsh(N); do
    source "$alias_file"
  done
}

load_zsh_aliases() {
  local aliases_dir local_aliases_dir

  aliases_dir="$ZSH_CONFIG_DIR/aliases"
  load_zsh_alias_dir "$aliases_dir/personal"

  if [[ "${ZSH_LOAD_LOCAL_CONFIG:-1}" != "0" ]]; then
    local_aliases_dir="${ZSH_LOCAL_CONFIG_DIR:-$HOME/.config/zsh.local}/aliases"
    load_zsh_alias_dir "$local_aliases_dir"
  fi
}
