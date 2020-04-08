unsetopt nomatch
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="dd.mm.yyyy"
DEFAULT_USER=$USER
EDITOR=/bin/nano
plugins=(git)
[[ -d "$ZSH/custom/plugins/zsh-syntax-highlighting" ]] && plugins+=(zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$HOME/bin:$HOME/.local/bin:/usr/games
export DISPLAY=localhost:0.0

[[ ! -f "$HOME/.dircolors" ]] || eval "$(dircolors -b "$HOME/.dircolors" )" && zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
for config in ".zsh_aliases" ".p10k.zsh"; do
    [[ ! -f "$HOME/$config" ]] || source "$HOME/$config"
done

cd
