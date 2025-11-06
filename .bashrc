#
# ~/.bashrc
#
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi

export PATH

alias ls='ls --color=auto'
alias grep='grep --color=auto'

alias ls='pls'
alias ll='pls -a'
alias ff='fastfetch'
alias c='clear'


# Git branch function
git_branch() {
    git rev-parse --is-inside-work-tree &>/dev/null || return
    git branch 2>/dev/null | sed -n '/\* /s/^* \(.*\)/  \1/p'
}

PS1='\[\033[96m\]\W\[\033[93m\]$(git_branch)\[\033[0m\] > '

. "$HOME/.cargo/env"