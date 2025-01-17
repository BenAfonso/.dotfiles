#!/bin/bash

echo "Installing Homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew analytics off

echo "Installing packages..."
brew bundle

PLATFORM=$(uname)
if [ $PLATFORM == 'Linux' ]
then
  echo "Linux"
elif [ $PLATFORM == 'Darwin' ]
then
  skhd --start-service
  echo "Apple"
fi

./scripts/oh-my-z.sh
./scripts/configs.sh
./scripts/import-gpg.sh
./scripts/install-privates.sh
