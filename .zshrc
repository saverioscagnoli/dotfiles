# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -v
# End of lines configured by zsh-newuser-install

# The following lines were added by compinstall
zstyle :compinstall filename '/home/svscagn/.zshrc'
autoload -Uz compinit
compinit
# End of lines added by compinstall

if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi

export PATH

. "$HOME/.cargo/env"

# Helpers

mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Aliases

alias ll="ls -lah"
alias pll="pls -a"
alias plf="pls find"
alias vim="nvim"

# Prompt configuration

autoload -Uz colors && colors
setopt PROMPT_SUBST

GREY="%F{240}"
PURPLE="%F{141}"
BLUE="%F{105}"
CYAN="%F{80}"
PINK="%F{212}"
GREEN="%F{84}"
RED="%F{203}"
RESET="%f"
BOLD="%B"
UNBOLD="%b"

parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

export PS1="${GREY}[${PURPLE}%n${GREY}@${BLUE}%m${GREY}] ${CYAN}%~${PINK}\$(parse_git_branch)
${GREEN}  ${RESET}"
