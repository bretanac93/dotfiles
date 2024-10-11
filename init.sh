#!/bin/zsh

mkdir -p "$HOME/.config"

# Link neovim configuration to `$HOME/.config`
ln -sf "$PWD/nvim" "$HOME/.config/"
echo "nvim configuration done"

# Link the tmux configuration and install the tmux plugin manager
git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
ln -sf "$PWD/.tmux.conf" "$HOME/.tmux.conf"
echo "tmux configuration done"

# Link the kitty configuration to `$HOME/.config`
ln -sf "$PWD/kitty" "$HOME/.config/"
echo "kitty configuration done"
