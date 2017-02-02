#bin/sh

rm -r ~/.vim
cd ~/ && ln -s .dotfiles/vim .vim
echo "[+] Vim config installed !"

rm ~/.tmux.conf
rm /usr/local/bin/vimux
ln -s ~/.dotfiles/tmux/Vimux /usr/local/bin/vimux
cd ~/ && ln -s .dotfiles/tmux/tmux.conf .tmux.conf
echo "[+] Tmux config installed !
 |___ [?] Try runnning 'vimux' in your Terminal :) "
cd ~/


rm ~/.bash_profile
ln -s ~/.dotfiles/.bash_profile .bash_profile
echo "[+] Bash_profile installed !
 |___ [?] run 'source ~/.bash_profile' to make it effective"
