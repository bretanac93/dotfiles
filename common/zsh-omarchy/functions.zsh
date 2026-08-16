# Port of $OMARCHY_PATH/default/bash/functions — source every function file.
# (N) is a glob qualifier: expand to nothing instead of erroring when empty.

for _zsh_fn in "$ZSH_CONFIG_DIR"/fns/*.zsh(N); do
  source "$_zsh_fn"
done
unset _zsh_fn
