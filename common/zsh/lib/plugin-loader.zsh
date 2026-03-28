load_zsh_plugins() {
  local plugin_file

  for plugin_file in "$ZSH_CONFIG_DIR"/plugins/*.zsh(N); do
    source "$plugin_file"
  done
}
