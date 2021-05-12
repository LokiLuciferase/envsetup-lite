#!/usr/bin/env bash
set -eo pipefail

# config
PKG_MNGR="${PKG_MNGR:-apt-get}"  # package manager to use
ALLOW_SUDO="${ALLOW_SUDO:-false}"  # allows installation of pkgs with apt and writing to system dirs
DO_BREW_IF_NO_SUDO="${DO_BREW_IF_NO_SUDO:-false}"  # install and use brew if sudo is not available
DO_PYTHON="${DO_PYTHON:-false}"  # install an essential Python3 dev environment with data science focus, using miniconda3.
DO_ENV="${DO_ENV:-false}"  # install zsh, powerlevel10k and a number of dotfiles.
RUN_ZSH="${RUN_ZSH:-true}"  # run ZSH at end of install
DO_VIM="${DO_VIM:-false}"  # install nvim and spacevim
DO_EXTRAS="${DO_EXTRAS:-false}" # also install extra features such as goofys, rg and fzf
DO_DOCKER="${DO_DOCKER:-false}"  # install docker
DO_DESKTOP="${DO_DESKTOP:-false}"  # install desktop packages like VLC
DO_ALL="${DO_ALL:-false}"  # whether to override all other settings, and do all, using sudo

if [[ "$DO_ALL" = true ]]; then
    DO_PYTHON=true
    DO_ENV=true
    DO_VIM=true
    DO_EXTRAS=true
    DO_DOCKER=true
    ALLOW_SUDO=true
fi

# get paths and export additional config variables
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export CONFIG_PATH="$DIR/config"
export SCRIPT_PATH="$DIR/scripts"
export DEBIAN_FRONTEND="noninteractive"
export UPDATE_BEHAVIOUR="${UPDATE_BEHAVIOUR:-configs}"  # whether to update only config files. Others: "fail" and "all"

# get functionality
. "${SCRIPT_PATH}/functions.sh"

# run selected
[[ "$DO_PYTHON" = true ]] && do_python_f
[[ "$ALLOW_SUDO" != true ]] && [[ "$DO_BREW_IF_NO_SUDO" = true ]] && do_brew_f && export PATH=$HOME/.linuxbrew/bin/brew:$PATH
[[ "$DO_ENV" = true ]] && do_env_f
[[ "$DO_PYTHON" = true ]] && [[ "$DO_ENV" = true ]] && conda init zsh && export PATH=$HOME/miniconda3/bin:$PATH
[[ "$DO_VIM" = true ]] && do_vim_f
[[ "$DO_EXTRAS" = true ]] && do_extras_f
[[ "$DO_DOCKER" = true ]] && [[ "$PKG_MNGR" = 'apt-get' ]] && do_docker_f
[[ "$DO_DESKTOP" = true ]] && do_desktop_f
running_in_docker && exit 0
[[ "$DO_ENV" = true  && "$RUN_ZSH" = true ]] && echo 'Running zsh now. To make this permanent, run: /usr/bin/chsh -s $(which zsh)' && exec zsh

