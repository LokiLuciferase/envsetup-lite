#!/usr/bin/env bash
set -eo pipefail

# config
PKG_MNGR="${PKG_MNGR:-apt-get}"  # package manager to use
ALLOW_SUDO="${ALLOW_SUDO:-false}"  # allows installation of stuff with Apt and writing to system dirs
DO_PYTHON="${DO_PYTHON:-false}"  # install an essential Python 3 dev environment with data science focus, using miniconda3.
DO_ENV="${DO_ENV:-false}"  # install the zsh, powerlevel10k and a number of dotfiles.
DO_VIM="${DO_VIM:-false}"  # install vim and initialize .vimrc
DO_EXTRAS="${DO_EXTRAS:-false}" # also install extra features such as Docker, goofys and fzf
DO_ALL="${DO_ALL:-false}"  # whether to override all other settings, and do all, using sudo

if [[ "$DO_ALL" = true ]]; then
    DO_PYTHON=true
    DO_ENV=true
    DO_VIM=true
    DO_EXTRAS=true
    ALLOW_SUDO=true
fi

# get paths
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export CONFIG_PATH="$DIR/config"
export SCRIPT_PATH="$DIR/scripts"

# get functionality
source "${SCRIPT_PATH}/functions.sh"

# run selected
[[ "$DO_PYTHON" = true ]] && do_python_f
[[ "$DO_ENV" = true ]] && do_env_f
[[ "$DO_PYTHON" = true ]] && [[ "$DO_ENV" = true ]] && conda init zsh && export PATH=$HOME/miniconda3/bin:$PATH
[[ "$DO_VIM" = true ]] && do_vim_f
[[ "$DO_EXTRAS" = true ]] && do_minimal_f && do_extras_f
[[ "$DO_ENV" = true ]] && echo 'Running zsh now. To make this permanent, run: sudo /usr/bin/chsh -s $(which zsh) $USER' && exec zsh

