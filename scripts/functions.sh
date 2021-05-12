. "${SCRIPT_PATH}/driver_functions.sh"

do_python_f() {
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
    try_install_cascade curl || { errmess "cURL not installed." && return 1; }
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
    # installing and using mamba is faster than resolving with conda...
    conda install -c conda-forge mamba --yes
    mamba env update -f ${CONFIG_PATH}/essentials.yaml
    mamba clean -a --yes
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
    # enable vim bindings ipython
    mkdir -p $HOME/.ipython/profile_default
    echo "c.TerminalInteractiveShell.editing_mode = 'vi'" >> $HOME/.ipython/profile_default/ipython_config.py
}

do_brew_f() {
    echo "Installing brew..."
    [[ "$(get_arch)" != 'amd64' ]] && errmess "Cannot install brew on non-x86_64 arch." && return 1
    ensure_gcc_toolchain || { errmess "Cannot install brew: GCC not installed." && return 1; }
    try_install_cascade git || { errmess "Git not installed." && return 1; }
    export HOMEBREW_NO_ENV_FILTERING=1
    git clone https://github.com/Homebrew/brew ~/.linuxbrew/Homebrew
    mkdir ~/.linuxbrew/bin
    ln -s ~/.linuxbrew/Homebrew/bin/brew ~/.linuxbrew/bin
    eval $(~/.linuxbrew/bin/brew shellenv)
    brew install hello
}

do_env_f() {
    echo "Installing ZSH environment..."
    # try install any indicated packages - zsh and git are required
    PKG_LIST="$(get_package_list env ${PKG_MNGR})"
    ALL_EXTRAS=(${PKG_LIST})
    echo ${ALL_EXTRAS[@]}
    try_install_any "${ALL_EXTRAS[@]}"
    try_install_cascade zsh || { errmess "ZSH not installed." && return 1; }
    try_install_cascade git || { errmess "Git not installed." && return 1; }
    # set up environment and shell
    export CHSH=no
    export RUNZSH=no
    sh -c "$(curl -sL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

    # install dotfiles: intended to be easily updated by pulling
    introduce_dotfiles
    # do not ever replace some configs like SSH - only add to new env
    while read p; do
        line=($p)
        [[ "$line" == "" ]] && break
        SOURCE="${CONFIG_PATH}/${line[0]}"
        if [[ "${#line[@]}" -eq 2 ]]; then
            TARGET="${HOME}/${line[1]}"
        else
            TARGET=""
        fi
        introduce_static_config_file_if_not_exists "${SOURCE}" "${TARGET}"
    done < "${CONFIG_PATH}/config_mappings_no_replace.txt"
}

do_vim_f() {
    echo "Setting up Neovim..."
    try_install_cascade git  || { errmess "Git not installed." && return 1; }
    try_install_cascade curl || { errmess "Curl not installed." && return 1; }
    try_install_cascade neovim  || { errmess "Neovim not installed." && return 1; }
    if [[ "$ALLOW_SUDO" != "true" && "$(which nvim)" == "" ]]; then
        NVIM_NIGHTLY="https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage"
        LOCAL_BIN_PATH="$HOME/.local/bin"
        mkdir -p "$LOCAL_BIN_PATH"
        curl -SsL -o "${LOCAL_BIN_PATH}/nvim" "$NVIM_NIGHTLY"
        chmod u+x "$LOCAL_BIN_PATH/nvim"
    fi
    [[ ! -d $HOME/.SpaceVim ]] && git clone https://github.com/SpaceVim/SpaceVim.git $HOME/.SpaceVim
    if [[ ! -d "${HOME}/.SpaceVim.d" && ! -L "${HOME}/.SpaceVim.d" ]]; then
        # standalone installation without dotfiles
        git submodule update --init
        mkdir -p "${HOME}/.config"
        cp -vr --backup=t ${CONFIG_PATH}/dotfiles/SpaceVim.d "${HOME}/.SpaceVim.d"
        cp -vr --backup=t ${CONFIG_PATH}/dotfiles/init.vim "${HOME}/.config/nvim/init.vim"
    fi
}

do_docker_f() {
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

do_goofys_f() {
    echo "Installing goofys..."
    [[ "$(get_arch)" == "amd64" ]] || return 0  # x86
    GOOFYS_VERSION="v0.24.0"
    curl -sL -o goofys "https://github.com/kahing/goofys/releases/download/${GOOFYS_VERSION}/goofys"
    chmod +x goofys
    $SUDO_PREFIX mv goofys "$(get_bin_dir)/goofys"
}

do_various_f() {
    echo "Installing various useful packages..."
    PKG_LIST="$(get_package_list various ${PKG_MNGR})"
    ALL_EXTRAS=(${PKG_LIST})
    echo ${ALL_EXTRAS[@]}
    try_install_any "${ALL_EXTRAS[@]}" || true
}

do_various_pip_f() {
    echo "Installing various useful packages with pip..."
    PKG_LIST="$(get_package_list various pip)"
    ALL_EXTRAS_PIP=(${PKG_LIST})
    echo ${ALL_EXTRAS_PIP[@]}
    try_pip "${ALL_EXTRAS_PIP[@]}" || true
}

do_extras_f() {
    echo "Installing extra tooling..."
    #do_docker_f || true
    do_goofys_f || true
    do_various_f || true
    do_various_pip_f || true
}

do_desktop_f() {
    echo "Installing desktop packages..."
    PKG_LIST="$(get_package_list desktop ${PKG_MNGR})"
    ALL_DESKTOP=(${PKG_LIST})
    echo ${ALL_DESKTOP[@]}
    try_install_any "${ALL_DESKTOP[@]}" || true
}
