## essential
alias cd..='cd ..'
alias cd2='cd ../..'
alias cd3='cd ../../..'

alias ll='ls -l'
alias la='ls -a'
alias lh='ls -lh'
alias l='ls -lah'
alias lt='ls -lahtr'

alias dush='du -ahd1 | sort -h'
alias hgrep='history|grep'
alias trace='tail -f -n100000'
alias mkdir='mkdir -pv'

[[ "$(which nvim)" != "" ]] && VIM_BIN='nvim' || VIM_BIN='vim'
alias svim="${VIM_BIN} -u ~/.SpaceVim/vimrc"
alias svimdiff='svim -d "$@"'
alias nano="${VIM_BIN}"
alias vim="${VIM_BIN}"
alias ed="echo 'fuck off'"

[[ "$(which spip)" != "" ]] && alias pip=spip

##silly
alias mansplain='man'
alias leckmiamoasch='echo "trottl"'
alias please='sudo '
alias fucking='sudo '
alias get-rekt="sudo apt update && sudo apt upgrade --yes"

