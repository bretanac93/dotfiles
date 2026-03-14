load_zsh_aliases() {
  local alias_file

  for alias_file in "$ZSH_CONFIG_DIR"/aliases/*.zsh(N); do
    source "$alias_file"
  done
}
