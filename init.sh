#!/bin/zsh

mkdir -p "$HOME/.config"

# Link neovim configuration to `$HOME/.config`
ln -sf "$PWD/nvim" "$HOME/.config/"
echo "nvim configuration done"

# Link the tmux configuration
ln -sf "$PWD/.tmux.conf" "$HOME/.tmux.conf"
echo "tmux configuration done"
