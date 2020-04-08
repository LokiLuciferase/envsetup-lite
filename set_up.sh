#!/usr/bin/env bash

DO_PYTHON=false
DO_ENV=false

if [[ "$#" -eq 0 ]]; then
    DO_PYTHON=true
    DO_ENV=true
elif [[ "$1" = "python" ]]; then
    DO_PYTHON=true
elif [[ "$1" = "env" ]]; then
    DO_ENV=true
else
    echo "Supplied command line argument(s) [ $@ ] are invalid."
    exit 1
fi

[[ -z "$(which wget)" ]] && echo "wget not installed. Exiting..." && exit 1

if [[ "$DO_PYTHON" = true ]]; then
    echo "Installing miniconda3 & jupyter."
    # install anaconda3
    mkdir -p anaconda_install && cd anaconda_install
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda3
    cd .. && rm -rf anaconda_install
    export PATH=$HOME/miniconda3/bin:$PATH
    conda env update -f essentials.yaml
    conda clean -a --yes

    # setup setup custom jupyter stuff and jupyterthemes
    jupyter contrib nbextension install --sys-prefix
    jupyter nbextension enable rise --py --sys-prefix
    jupyter nbextension enable comment-uncomment/main
    jupyter nbextension enable execute_time/ExecuteTime
    jupyter nbextension enable scroll_down/main
    jupyter nbextension enable code_prettify/autopep8
    jupyter nbextension enable varInspector/main
    jupyter nbextension enable rubberband/main
    jt -t oceans16 -tfs 14 -ofs 10 -f dejavu -cellw 95% -altmd -T
fi

if [[ "$DO_ENV" = true ]]; then
    echo "Installing ZSH environment."
    [[ -z "$(which zsh)"  ]] && echo "ZSH not installed. Exiting..." && exit 1
    [[ -z "$(which git)"  ]] && echo "git not installed. Exiting..." && exit 1
    # set up environment and shell
    mkdir -p $HOME/.ssh && cp .ssh/config $HOME/.ssh
    export CHSH=no
    sh -c "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
    cp .p10k.zsh .zsh_aliases .zshrc $HOME
    [[ "$DO_PYTHON" = true ]] && conda init bash zsh
fi

echo "All selected components were installed."