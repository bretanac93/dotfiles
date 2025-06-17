#!/bin/zsh



mkdir -p "$HOME/.config"

# Link neovim configuration to `$HOME/.config`
rm -rf "$HOME/.config/nvim"
ln -sf "$PWD/nvim" "$HOME/.config/nvim"
echo "nvim configured"

# Link the tmux configuration and install the tmux plugin manager
ln -sf "$PWD/.tmux.conf" "$HOME/.tmux.conf"
echo "tmux configured"

# Link the ghostty configuration
rm -rf "$HOME/.config/ghostty"
ln -sf "$PWD/ghostty" "$HOME/.config/ghostty"
echo "ghostty configured"

# Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
echo "oh-my-zsh configured"

rm -rf "$HOME/.oh-my-zsh/custom/themes"
cp -r "$PWD/omz/custom/themes" "$HOME/.oh-my-zsh/custom/themes"
echo "oh-my-zsh theme configured"

