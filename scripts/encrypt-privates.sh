#!/bin/sh

PUBLIC=$(pass keepass-noha | keepassxc-cli show ~/.keepass/keepass-noha.kdbx "Age key - Pass and config" -a public -q)

tar cvz --directory ~/.dotfiles/private/ . | age -r $PUBLIC > ~/.dotfiles/configs/private.tar.gz.age 
