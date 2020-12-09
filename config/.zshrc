# general omz setup
unsetopt nomatch
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="dd.mm.yyyy"
DEFAULT_USER=$USER
EDITOR=vim
plugins=(git)
[[ -d "$ZSH/custom/plugins/zsh-syntax-highlighting" ]] && plugins+=(zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# Dirty hacks 
# improved highlighting on WSL: make color of other-writable directories less offensive
[[ ! -f "$HOME/.dircolors" ]] || eval "$(dircolors -b "$HOME/.dircolors" )" && zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# load all found config files
CONFIG_FILES=( 
    ".common_env_variables"  # environment variables
    ".zsh_functions"  # functions
    ".zsh_aliases"  # aliases
    ".p10k.zsh"  # powerlevel10k setup
)
for config in "${CONFIG_FILES[@]}" ; do
    [[ ! -f "$HOME/$config" ]] || source "$HOME/$config"
done

cd
