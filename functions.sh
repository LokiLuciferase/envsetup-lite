source driver_functions.sh

function do_python_f {
    echo "Installing miniconda3 & jupyter..."
    try_install_cascade wget || (errmess "Wget not installed." && return 1)
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


function do_env_f {
    echo "Installing ZSH environment..."
    try_install_cascade zsh || (errmess "ZSH not installed." && return 1)
    try_install_cascade git || (errmess "Git not installed." && return 1)
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
    try_install_cascade git  || (errmess "Git not installed." && return 1)
    try_install_cascade curl || (errmess "Curl not installed." && return 1)
    try_install_cascade vim  || (errmess "Vim not installed." && return 1)
    git clone https://github.com/SpaceVim/SpaceVim.git $HOME/.SpaceVim
    cp .vimrc $HOME
    cp -r .SpaceVim.d $HOME
}


function do_docker_f {
    echo "Installing Docker..."
    SUDO_PREFIX=$(get_sudo_prefix)
    have_sudo && [[ "$PKG_MNGR" = 'apt-get' ]] || "Could not install Docker."
    $SUDO_PREFIX apt-get update
    $SUDO_PREFIX apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common --yes
    $SUDO_PREFIX apt-get remove docker docker-engine docker.io containerd runc
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    $SUDO_PREFIX add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    $SUDO_PREFIX apt-get update
    $SUDO_PREFIX apt-get install docker-ce docker-ce-cli containerd.io --yes
    $SUDO_PREFIX systemctl enable docker
    $SUDO_PREFIX groupadd docker
    $SUDO_PREFIX usermod -aG docker $USER || true
}


function do_goofys_f {
    echo "Installing goofys..."
    GOOFYS_VERSION="v0.24.0"
    wget "https://github.com/kahing/goofys/releases/download/${GOOFYS_VERSION}/goofys"
    chmod +x goofys
    $SUDO_PREFIX mv goofys "$(get_bin_dir)/goofys"
}


function do_various_f {
    echo "Installing various useful packages..."
    try_install_any libmysqlclient-dev rename pigz awscli progress tldr colordiff tmux parallel ripgrep fzf || true
}


function do_minimal_f {
    echo "Installing minimal tooling..."
    ALL_MINIMAL=(git zsh wget make)
    [[ -z "$CC" ]] && ALL_MINIMAL+=(gcc)
    [[ -z "$CPP" ]] && ALL_MINIMAL+=(g++)
    try_install_all $ALL_MINIMAL
}


function do_extras_f {
    echo "Installing extra tooling..."
    #do_docker_f || true
    do_goofys_f || true
    do_various_f || true
}
