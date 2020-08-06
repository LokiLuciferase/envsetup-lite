#!/usr/bin/env bash
set -eo pipefail

# get functionality
source functions.sh

# config
PKG_MNGR="${PKG_MNGR:-apt-get}"  # package manager to use
ALLOW_SUDO="${ALLOW_SUDO:-false}"  # allows installation of stuff with Apt and writing to system dirs
DO_PYTHON="${DO_PYTHON:-false}"  # install an essential Python 3 dev environment with data science focus, using miniconda3.
DO_ENV="${DO_ENV:-false}"  # install the zsh, powerlevel10k and a number of dotfiles.
DO_VIM="${DO_VIM:-false}"  # install vim and initialize .vimrc
DO_EXTRAS="${DO_EXTRAS:-false}" # also install extra features such as Docker, goofys and fzf

# run selected
[[ "$DO_PYTHON" = true ]] && do_python_f
[[ "$DO_ENV" = true ]] && do_env_f
[[ "$DO_PYTHON" = true ]] && [[ "$DO_ENV" = true ]] && conda init zsh && export PATH=$HOME/miniconda3/bin:$PATH
[[ "$DO_VIM" = true ]] && do_vim_f
[[ "$DO_EXTRAS" = true ]] && do_minimal_f && do_extras_f

[[ "$DO_ENV" = true ]] && echo "Running zsh now. To make this permanent, utilize /usr/bin/chsh." && exec zsh
