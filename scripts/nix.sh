#!/bin/sh

if test ! "$(command -v nix)"; then
    echo "Nix not installed. Installing."
    sh -c "$(curl -L https://nixos.org/nix/install) --no-daemon"
else
    echo "Nix is already installed."
fi
