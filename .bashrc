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
alias ll='pls -ap	'
alias ff='fastfetch'
alias c='clear'

# Start vscode under wayland
alias code="code --enable-features=UseOzonePlatform --ozone-platform=$XDG_SESSION_TYPE"

git_branch() {
    local branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    if [ -n "$branch" ]; then
        echo " ($branch)"
    fi
}

COLOR_USER="\[\033[36m\]"      # Cyan
COLOR_HOST="\[\033[32m\]"      # Green
COLOR_PATH="\[\033[34m\]"      # Blue
COLOR_GIT="\[\033[33m\]"       # Yellow
COLOR_AT="\[\033[37m\]"        # White
COLOR_RESET="\[\033[0m\]"

PS1="${COLOR_USER}\u${COLOR_AT}@${COLOR_HOST}\h ${COLOR_PATH}\w${COLOR_GIT}\$(git_branch)${COLOR_RESET} \$ "

. "$HOME/.cargo/env"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
