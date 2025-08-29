#!/bin/bash

CONFIGS_PATH=~/.dotfiles/configs

mkdir ~/.config

# Neovim
ln -sfv $CONFIGS_PATH/nvim ~/.config

# Tmux
ln -sfv $CONFIGS_PATH/tmux/.tmux/.tmux.conf ~/.tmux.conf
ln -sfv $CONFIGS_PATH/tmux/.tmux ~/

# Wezterm
ln -sfv $CONFIGS_PATH/wezterm ~/.wezterm

# Git
ln -sfv $CONFIGS_PATH/git/.gitconfig ~/.gitconfig

# Starship
ln -sfv $CONFIGS_PATH/starship/starship.toml ~/.config/

# Zsh
ln -sfv $CONFIGS_PATH/zsh/zshrc ~/.zshrc

# Gnupg
ln -sfv $CONFIGS_PATH/gnupg/gpg-agent.conf ~/.gnupg/gpg-agent.conf

# Lazygit
mkdir ~/.config/lazygit
ln -sfv $CONFIGS_PATH/lazygit/config.yml ~/.config/lazygit/config.yml

ln -sfv $CONFIGS_PATH/aider/aider.conf.yml ~/.aider.conf.yml

## Mac specifics
if [[ $OSTYPE == 'darwin'* ]]; then 
  # Hammerspoon
  ln -sfv $CONFIGS_PATH/hammerspoon ~/.hammerspoon
  # Aerospace
  ln -sfv $CONFIGS_PATH/aerospace/aerospace.toml ~/.aerospace.toml
  # SKHD
  ln -sfv $CONFIGS_PATH/skhd/ ~/.config/
  
fi

# python -m pip install aider-install
