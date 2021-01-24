source "${SCRIPT_PATH}/driver_functions.sh"

function do_python_f {
    echo "Installing miniconda3 & jupyter..."
    if [[ -d "${HOME}/miniconda3" ]]; then
        if [[ "${UPDATE_BEHAVIOUR}" = "all" ]]; then
            rm -rf ${HOME}/miniconda3
        elif [[ "${UPDATE_BEHAVIOUR}" = "configs" ]]; then
            errmess "${HOME}/miniconda3 already exists. Skipping python install."
            return 0
        else
            errmess "${HOME}/miniconda3 already exists."
            return 1
        fi
    fi
    try_install_cascade curl || (errmess "cURL not installed." && return 1)
    if [[ "$(get_arch)" = "amd64" ]]; then
        DLPATH="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
    elif [[ "$(get_arch)" = "arm64" ]]; then
        DLPATH="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-aarch64.sh"
    else
        echo "Unknown architecture: $(get_arch)" && exit 1
    fi
    # install miniconda3 or miniforge3
    mkdir -p anaconda_install && cd anaconda_install
    curl -sSL $DLPATH -o conda.sh
    bash conda.sh -b -p $HOME/miniconda3
    cd .. && rm -rf anaconda_install
    export PATH=$HOME/miniconda3/bin:$PATH
    conda env update -f ${CONFIG_PATH}/essentials.yaml
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
    jt -t chesterish -tfs 14 -ofs 10 -f dejavu -cellw 95% -altmd -T
    conda init bash
}


function do_env_f {
    echo "Installing ZSH environment..."
    try_install_cascade zsh || (errmess "ZSH not installed." && return 1)
    try_install_cascade git || (errmess "Git not installed." && return 1)
    # set up environment and shell
    export CHSH=no
    export RUNZSH=no
    sh -c "$(curl -sL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

    # check if any of the to be installed things already exist
    # if so, back them up
    while read p; do
        line=($p)
        [[ "$line" == "" ]] && break
        SOURCE="${CONFIG_PATH}/${line[0]}"
        if [[ "${#line[@]}" -eq 2 ]]; then
            TARGET="${HOME}/${line[1]}"
        else
            TARGET=""
        fi
        introduce_config_file "${SOURCE}" "${TARGET}"
    done < "${CONFIG_PATH}/config_mappings.txt"

    # do not ever replace some configs like SSH
    while read p; do
        line=($p)
        [[ "$line" == "" ]] && break
        SOURCE="${CONFIG_PATH}/${line[0]}"
        if [[ "${#line[@]}" -eq 2 ]]; then
            TARGET="${HOME}/${line[1]}"
        else
            TARGET=""
        fi
        introduce_config_file_if_not_exists "${SOURCE}" "${TARGET}"
    done < "${CONFIG_PATH}/config_mappings_no_replace.txt"
}


function do_vim_f {
    echo "Setting up Vim..."
    try_install_cascade git  || (errmess "Git not installed." && return 1)
    try_install_cascade curl || (errmess "Curl not installed." && return 1)
    try_install_cascade neovim  || (errmess "Neovim not installed." && return 1)
    [[ ! -d $HOME/.SpaceVim ]] && git clone https://github.com/SpaceVim/SpaceVim.git $HOME/.SpaceVim
    introduce_config_file ${CONFIG_PATH}/vimrc ${HOME}/.vimrc
    introduce_config_file ${CONFIG_PATH}/SpaceVim.d/ ${HOME}/.SpaceVim.d
}


function do_docker_f {
    echo "Installing Docker..."
    SUDO_PREFIX=$(get_sudo_prefix)
    have_sudo && [[ "$PKG_MNGR" = 'apt-get' ]] || "Could not install Docker."
    $SUDO_PREFIX apt-get update
    $SUDO_PREFIX apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common --yes
    $SUDO_PREFIX apt-get remove docker docker-engine docker.io containerd runc || true
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO_PREFIX apt-key add -
    $SUDO_PREFIX apt-key fingerprint 0EBFCD88
    ARCH=$(get_arch)
    $SUDO_PREFIX add-apt-repository "deb [arch=${ARCH}] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    $SUDO_PREFIX apt-get update
    $SUDO_PREFIX apt-get install docker-ce docker-ce-cli containerd.io --yes
    $SUDO_PREFIX systemctl enable docker.service
    $SUDO_PREFIX systemctl enable containerd.service
    $SUDO_PREFIX groupadd docker || true
    $SUDO_PREFIX usermod -aG docker $USER || true
}


function do_goofys_f {
    echo "Installing goofys..."
    [[ "$(get_arch)" == "amd64" ]] || return 0  # x86
    GOOFYS_VERSION="v0.24.0"
    curl -sL -o goofys "https://github.com/kahing/goofys/releases/download/${GOOFYS_VERSION}/goofys"
    chmod +x goofys
    $SUDO_PREFIX mv goofys "$(get_bin_dir)/goofys"
}


function do_various_f {
    echo "Installing various useful packages..."
    try_install_any build-essential htop libmysqlclient-dev mysql-client rename pigz awscli progress tldr colordiff tmux parallel ripgrep fzf || true
}


function do_minimal_f {
    echo "Installing minimal tooling..."
    ALL_MINIMAL=(git zsh curl make)
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
