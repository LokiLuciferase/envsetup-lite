#!/usr/bin/env bash
set -eo pipefail

# get functionality
source functions.sh

# the following environment variables are checked:
# ALLOW_SUDO=true ==> allows installation of stuff with Apt, e.g. basic dev tools, and extras.
# Note that the script will prompt for sudo password when required - running this script with sudo will install python and env for the root user.
# DO_EXTRAS=true ==> also install extra features such as Docker, goofys and fzf
# DO_PYTHON=true ==> install an essential Python 3 dev environment with data science focus, using miniconda3.
# DO_ENV=true ==> install the zsh, powerlevel10k and a number of dotfiles.
# DO_VIM=true ==> if conda is installed, get fresh vim. add and initialize .vimrc

# run selected
# run stuff requiring that sudo be called
[[ "$ALLOW_SUDO" = true ]] && sudo bash -c "$(declare -f); do_minimal_f"
[[ "$ALLOW_SUDO" = true ]] && [[ "$DO_EXTRAS" = true ]] && sudo bash -c "$(declare -f); do_extras_f"
# if we do not run with sudo and we have no wget, we cannot install python or zsh
[[ -z "$(which wget)" ]] && echo "wget not installed. Exiting..." && exit 1
[[ "$DO_PYTHON" = true ]] && do_python_f
[[ "$DO_ENV" = true ]] && do_env_f
[[ "$DO_PYTHON" = true ]] && [[ "$DO_ENV" = true ]] && conda init zsh
[[ "$DO_VIM" = true ]] && do_vim_f
echo "All selected components were installed."
[[ "$DO_ENV" = true ]] && echo "Running zsh now. To make this permanent, utilize /usr/bin/chsh." && exec /usr/bin/zsh
