# Neovim
ln -sfv ~/.dotfiles/nvim ~/.config

# Tmux
ln -sfv ~/.dotfiles/tmux/.tmux/.tmux.conf ~/.tmux.conf
ln -sfv ~/.dotfiles/tmux/.tmux ~/

# Wezterm
ln -sfv ~/.dotfiles/wezterm/wezterm.lua ~/.wezterm.lua

# Git
ln -sfv ~/.dotfiles/git/config ~/.gitconfig

# Starship
ln -sfv ~/.dotfiles/starship/starship.toml ~/.config/

# Zsh
ln -sfv ~/.dotfiles/zsh/zshrc ~/.zshrc

## Mac specifics
if [[ $OSTYPE == 'darwin'* ]]; then 
  # Hammerspoon
  ln -sfv ~/.dotfiles/hammerspoon ~/.hammerspoon
fi
