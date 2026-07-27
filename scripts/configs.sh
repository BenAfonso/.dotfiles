#!/bin/bash

CONFIGS_PATH=~/.dotfiles/configs

mkdir -p ~/.config ~/.config/zsh ~/.config/lazygit

# Pi
if [ -e ~/.pi ] && [ ! -L ~/.pi ]; then
  mv ~/.pi ~/.pi.backup.$(date +%Y%m%d%H%M%S)
fi
ln -sfn $CONFIGS_PATH/pi ~/.pi
mkdir -p ~/.dotfiles/private/pi/agent
ln -sfn ../../../private/pi/agent/auth.json $CONFIGS_PATH/pi/agent/auth.json

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
ln -sfv $CONFIGS_PATH/zsh/zshrc ~/.config/zsh/.zshrc

# Gnupg
ln -sfv $CONFIGS_PATH/gnupg/gpg-agent.conf ~/.gnupg/gpg-agent.conf

# Hyprland
ln -sfv $CONFIGS_PATH/hypr ~/.config/

# Rofi
ln -sfv $CONFIGS_PATH/rofi ~/.config/
ln -sfv $CONFIGS_PATH/dunst ~/.config/

# Waybar
ln -sfv $CONFIGS_PATH/waybar ~/.config/

# Fastfetch
ln -sfv $CONFIGS_PATH/fastfetch ~/.config/

# Lazygit
ln -sfv $CONFIGS_PATH/lazygit/config.yml ~/.config/lazygit/config.yml

# Yazi
ln -sfv $CONFIGS_PATH/yazi ~/.config/

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
