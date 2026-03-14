load_zsh_alias_dir() {
  local alias_dir="$1"
  local alias_file

  for alias_file in "$alias_dir"/*.zsh(N); do
    source "$alias_file"
  done
}

load_zsh_aliases() {
  local aliases_dir profile profile_spec
  local -a profiles

  aliases_dir="$ZSH_CONFIG_DIR/aliases"
  load_zsh_alias_dir "$aliases_dir/common"

  profile_spec="${ZSH_ALIAS_PROFILES:-}"
  profile_spec="${profile_spec//,/ }"
  profile_spec="${profile_spec//:/ }"
  profiles=(${=profile_spec})

  for profile in $profiles; do
    load_zsh_alias_dir "$aliases_dir/profiles/$profile"
  done
}
