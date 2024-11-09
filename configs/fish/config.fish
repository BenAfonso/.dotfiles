set fish_greeting ""


set -gx TERM xterm-256color

if status is-interactive
    # Commands to run in interactive sessions can go here
end


# Preferred editor for local and remote sessions
 # if [[ -n $SSH_CONNECTION ]]; then
 #   export EDITOR='vim'
 # else
 #   export EDITOR='nvim'
 # fi


## Dotfiles scripts
set -g DOTFILES "$HOME/.dotfiles"
set -gx PATH "$DOTFILES/bin:$PATH"

## Go
set -g GOPATH $HOME/go
set -gx PATH "$PATH:$GOPATH/bin"

set -gx PYTHON 3.11

export GPG_TTY=$(tty)

alias vim "nvim"
alias cat "bat"
alias ls "lsd"

alias nvim "v"
alias nvdis "nvr --servername $(nvim-server-name) -s"


# if [ -z "$TMUX" ]
# then
#     tmux attach || tmux new
# fi


starship init fish | source
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
