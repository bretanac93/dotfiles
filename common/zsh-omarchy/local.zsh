# Machine-specific overrides, loaded last so they win. None of this is tracked
# in the dotfiles repo — that is the point.
#
#   ~/.config/zsh.local/env.zsh                  exports and secrets
#   ~/.config/zsh.local/alias/*.zsh              extra aliases
#   ~/.config/zsh.local/profile.<hostname>.zsh   per-host config

_local_dir="$HOME/.config/zsh.local"

[[ -r "$_local_dir/env.zsh" ]] && source "$_local_dir/env.zsh"

for _local_file in "$_local_dir"/alias/*.zsh(N); do
  source "$_local_file"
done

[[ -r "$_local_dir/profile.${HOST%%.*}.zsh" ]] && source "$_local_dir/profile.${HOST%%.*}.zsh"

unset _local_file _local_dir
