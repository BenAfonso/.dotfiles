#!/bin/bash

read -s -p "Enter the password: " PASSWORD
echo \n

echo $PASSWORD | keepassxc-cli show ~/.keepass/keepass-noha.kdbx "GPG" -a PUBLIC -q > public.key
echo $PASSWORD | keepassxc-cli show ~/.keepass/keepass-noha.kdbx "GPG" -a PRIVATE -q > private.key

# gpg --import private.key # |& awk -F '[ :]' 'NR==1 {print $4; exit}')

gpg --import public.key
KEY_ID=$(gpg --import private.key | awk -F '[ :]' 'NR==1 {print $4; exit}')

echo Run \'gpg --edit-key $KEY_ID trust quit\'

rm private.key public.key

