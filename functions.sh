function do_python_f {
    echo "Installing miniconda3 & jupyter..."
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
    jupyter nbextension enable highlight_selected_word/main
    jupyter nbextension enable execute_time/ExecuteTime
    jupyter nbextension enable scroll_down/main
    jupyter nbextension enable code_prettify/autopep8
    jupyter nbextension enable varInspector/main
    jupyter nbextension enable rubberband/main
    jupyter nbextension enable latex_envs/latex_envs
    jt -t oceans16 -tfs 14 -ofs 10 -f dejavu -cellw 95% -altmd -T
    conda init bash
}


function try_conda_forge {
    echo "Attempting to install $1 with conda."
    [[ -z "$(which conda)" ]] && echo "Conda not installed." && return 1
    conda install -c conda-forge "$1" --yes
    if [[ "$?" -eq 0 ]]; then
        return 0
    else
        echo "Could not install $1 with conda."
        return 1
    fi
}


function do_env_f {
    echo "Installing ZSH environment..."
        [[ -z "$(which zsh)" ]] && try_conda_forge zsh
        [[ -z "$(which git)" ]] && try_conda_forge git
        [[ -z "$(which zsh)" ]] && echo "ZSH not installed. Exiting..." && return 1
        [[ -z "$(which git)" ]] && echo "git not installed. Exiting..." && return 1
        # set up environment and shell
        mkdir -p $HOME/.ssh && cp .ssh/config $HOME/.ssh
        mkdir -p $HOME/.config/htop && cp htoprc $HOME/.config/htop
        export CHSH=no
        export RUNZSH=no
        sh -c "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
        cp .p10k.zsh .zsh_aliases .zshrc .gitconfig .dircolors $HOME
}


function do_vim_f {
    echo "Setting up Vim..."
    try_conda_forge vim
    [[ -z "$(which curl)" ]] && try_conda_forge curl
    [[ -z "$(which vim)" ]] && echo "Vim not installed." && return 1
    cp .vimrc $HOME
    vim +VimEnter +silent +PlugInstall +qall
}


function do_docker_f {
    echo "Installing Docker..."
    apt-get update
    apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common --yes
    apt-get remove docker docker-engine docker.io containerd runc
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update
    apt-get install docker-ce docker-ce-cli containerd.io --yes
    systemctl enable docker
    groupadd docker
    usermod -aG docker $SUDO_USER || true
}


function do_goofys_f {
    echo "Installing goofys..."
    GOOFYS_VERSION="v0.24.0"
    wget "https://github.com/kahing/goofys/releases/download/${GOOFYS_VERSION}/goofys"
    chmod +x goofys
    mv goofys /usr/bin/goofys
}


function do_various_f {
    echo "Installing various useful packages..."
    apt-get update
    apt-get install libmysqlclient-dev rename pigz awscli progress tldr colordiff tmux parallel --yes
    apt-get install ripgrep fzf --yes || true # these might not exist in older ubuntu distros
}


function do_minimal_f {
    echo "Installing minimal tooling..."
    apt-get update
    apt-get install git zsh wget build-essential --yes

    if [[ "$(arch)" = "aarch64" ]]; then
        echo "ARM environment detected."
        apt-get install gfortran rustc libopenblas-dev liblapack-dev
        apt-get install libfreetype6-dev pkg-config
    fi
}


function do_extras_f {
    echo "Installing extra tooling..."
    do_docker_f
    do_goofys_f
    do_various_f
}
