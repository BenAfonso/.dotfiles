#!/bin/sh

SECRETS_PATH=~/.dotfiles/secrets

TMP_PATH=./tmp
mkdir -p $TMP_PATH

# Generate key file
keepassxc-cli show ~/.keepass/keepass-noha.kdbx "Age key - Pass and config" -a raw > $TMP_PATH/key.txt
KEY_FILE=$TMP_PATH/key.txt

# Decrypt
age --decrypt -i $KEY_FILE ~/.dotfiles/configs/private.tar.gz.age > $TMP_PATH/private.tar.gz

# Export
mkdir -p ~/.dotfiles/private
tar xvf $TMP_PATH/private.tar.gz -C ~/.dotfiles/private/

# Cleanup
rm -rf $TMP_PATH/

# Password store
rm ~/.password-store
ln -sfv ~/.dotfiles/private/password-store/ ~/.password-store

