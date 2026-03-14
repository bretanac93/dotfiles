load_zsh_local_config() {
  local local_dir local_file

  if [[ "${ZSH_LOAD_LOCAL_CONFIG:-1}" == "0" ]]; then
    return 0
  fi

  local_dir="${ZSH_LOCAL_CONFIG_DIR:-$HOME/.config/zsh.local}"

  for local_file in "$local_dir"/*.zsh(N); do
    source "$local_file"
  done
}
