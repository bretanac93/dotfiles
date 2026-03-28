load_zsh_alias_dir() {
  local alias_dir="$1"
  local alias_file

  for alias_file in "$alias_dir"/*.zsh(N); do
    source "$alias_file"
  done
}

load_zsh_aliases() {
  local repo_alias_dir local_alias_dir

  # Load tracked aliases from repo
  repo_alias_dir="$ZSH_CONFIG_DIR/alias"
  load_zsh_alias_dir "$repo_alias_dir"

  # Load local aliases (work-specific, machine-specific, etc)
  if [[ "${ZSH_LOAD_LOCAL_CONFIG:-1}" != "0" ]]; then
    local_alias_dir="${ZSH_LOCAL_CONFIG_DIR:-$HOME/.config/zsh.local}/alias"
    load_zsh_alias_dir "$local_alias_dir"
  fi
}
