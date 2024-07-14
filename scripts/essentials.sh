#!/bin/sh

nix-env -iA nixpkgs.tmux
nix-env -iA nixpkgs.neovim
nix-env -iA nixpkgs.pass
nix-env -iA nixpkgs.age
nix-env -iA nixpkgs.btop
nix-env -iA nixpkgs.duf
nix-env -iA nixpkgs.eza
nix-env -iA nixpkgs.jq
nix-env -iA nixpkgs.keepassxc
nix-env -iA nixpkgs.nix
nix-env -iA nixpkgs.tealdeer

nix-env -iA nixpkgs.ripgrep
nix-env -iA nixpkgs.go
nix-env -iA nixpkgs.fzf
nix-env -iA nixpkgs.lua
nix-env -iA nixpkgs.lua54Packages.luarocks-nix

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
curl -sS https://starship.rs/install.sh | sh
