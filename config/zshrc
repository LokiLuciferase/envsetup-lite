# general omz setup
unsetopt nomatch
export ZSH="$HOME/.oh-my-zsh"
DISABLE_UPDATE_PROMPT=true
ZSH_THEME="powerlevel10k/powerlevel10k"
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="dd.mm.yyyy"
ZLE_RPROMPT_INDENT=0
DEFAULT_USER=$USER
EDITOR=vim
DOTFILES_DIR="${HOME}/.envsetup-lite.d"
plugins=(vi-mode git)
[[ -d "$ZSH/custom/plugins/zsh-syntax-highlighting" ]] && plugins+=(zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# Dirty hacks 
# improved highlighting on WSL: make color of other-writable directories less offensive
[[ ! -f "$HOME/.dircolors" ]] || eval "$(dircolors -b "$HOME/.dircolors" )" && zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# load all ZSH-related config files from unified directory
for config in ${DOTFILES_DIR}/*.zsh ; do
    [[ ! -f "$config" ]] || source "$config"
done

cd
