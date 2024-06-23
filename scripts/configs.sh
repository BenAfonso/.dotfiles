#!/bin/sh

CONFIGS_PATH=~/.dotfiles/configs

# Neovim
ln -sfv $CONFIGS_PATH/nvim ~/.config

# Tmux
ln -sfv $CONFIGS_PATH/tmux/.tmux/.tmux.conf ~/.tmux.conf
ln -sfv $CONFIGS_PATH/tmux/.tmux ~/

# Wezterm
ln -sfv $CONFIGS_PATH/wezterm/wezterm.lua ~/.wezterm.lua

# Git
ln -sfv $CONFIGS_PATH/git/config ~/.gitconfig

# Starship
ln -sfv $CONFIGS_PATH/starship/starship.toml ~/.config/

# Zsh
ln -sfv $CONFIGS_PATH/zsh/zshrc ~/.zshrc

# Gnupg
ln -sfv $CONFIGS_PATH/gnupg/gpg-agent.conf ~/.gnupg/gpg-agent.conf

## Mac specifics
if [[ $OSTYPE == 'darwin'* ]]; then 
  # Hammerspoon
  ln -sfv $CONFIGS_PATH/hammerspoon ~/.hammerspoon
fi
