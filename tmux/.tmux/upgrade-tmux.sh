#!/usr/bin/env bash

set -e

# dependecies
apt update
apt install -y git automake build-essential pkg-config libevent-dev libncurses5-dev byacc

# where our temp file locates
rm -rf /tmp/tmux
wget -P /tmp/tmux https://github.com/tmux/tmux/releases/download/3.3a/tmux-3.3a.tar.gz
cd /tmp/tmux
tar -xvf tmux-3.3a.tar.gz
cd /tmp/tmux/tmux-3.3a

# bash autogen.sh
./configure && make
make install
cd -

# clean up
#rm -rf /tmp/tmux
