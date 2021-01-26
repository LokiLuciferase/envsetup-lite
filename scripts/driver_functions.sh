DEBIAN_FRONTEND=noninteractive

function errmess {
    echo "$@" 1>&2
}

function have_cmd {
    [[ ! -z "$(command -v $1)" ]] && return 0 || return 1
}

function get_nonfound_cmds {
    ALL=("$@")
    NOTFOUND=()
    for tool in $@; do
        have_cmd $tool || NOTFOUND+=( $tool )
    done
    echo "$NOTFOUND"
}

function get_arch {
    FOUND_ARCH=$(uname -m)
    if [[ "$FOUND_ARCH" = 'arm64' ]] || [[ "$FOUND_ARCH" = 'aarch64' ]]; then
        # 64-bit ARM
        echo 'arm64'
    elif [[ "$FOUND_ARCH" = 'armv7l' ]]; then
        # 32-bit ARM
        echo 'armv7l'
    else
        echo 'amd64'
    fi
}

function get_package_list {
    # get_package_list fraction pkg_mngr
    package_list_file="${CONFIG_PATH}/package_lists.tsv"
    cols=($(head -1 ${package_list_file}))
    idx=""
    for ci in "${!cols[@]}"; do
        [[ "${cols[$ci]}" == $2 ]] && idx=$ci
    done
    [[ -z "$idx" ]] && echo "Invalid package manager chosen: $2" && return 1
    pkgs=("$(sed 1d ${package_list_file} | grep $1 | cut -f2- | cut -f${idx} | tr '\n' ' ')")
    echo "$pkgs"
}

function running_in_docker {
  awk -F/ '$2 == "docker"' /proc/self/cgroup | read
}

function have_conda {
    have_cmd conda && return 0 || return 1
}

function have_sudo {
    if [[ "$ALLOW_SUDO" != true ]]; then
        return 1
    elif [[ "$USER" = 'root' ]]; then
        return 0
    elif [[ -z "$(sudo -nv)" ]]; then
        sudo true
        return 0
    else
        return 1
    fi
}

function get_sudo_prefix {
    [[ "$USER" = 'root' ]] && echo "" || echo "sudo"
}

function introduce_static_config_file {
    # introduce_static_config_file storage_location target_location
    if [[ -d $2 || -f $2 ]]; then
        if [[ "${UPDATE_BEHAVIOUR}" != "all" && "${UPDATE_BEHAVIOUR}" != "configs" ]]; then
            errmess "Config $2 already exists."
            return 1
        fi
    fi
    [[ -d $2 ]] && mv $2 "${2}.~1~"
    mkdir -p "$(dirname $2)"
    cp -r --backup=t "$1" "$2"
}

function introduce_static_config_file_if_not_exists {
    UPDATE_BEHAVIOUR="no" introduce_static_config_file $1 $2 || true
}

function introduce_dotfiles {
    REPO_DOTFILE_DIR="${CONFIG_PATH}/dotfiles"
    DOTFILE_DIR="${HOME}/.dotfiles"
    DOTFILE_PUSH_URL='git@github.com:LokiLuciferase/dotfiles'
    [[ -d "${DOTFILE_DIR}" ]] && errmess "dotfile directory already present." && return 0  # already exists
    if [[ ! -d "${REPO_DOTFILE_DIR}/.git" ]]; then
        git submodule update --init
        pushd "${REPO_DOTFILE_DIR}" && git remote set-url --push origin "${DOTFILE_PUSH_URL}" && popd
    fi
    cp -r "${REPO_DOTFILE_DIR}" "${DOTFILE_DIR}"
    while read p; do
        line=($p)
        [[ "$line" == "" ]] && break
        if [[ "${#line[@]}" -eq 2 ]]; then
            SOURCE="${DOTFILE_DIR}/${line[0]}"
            TARGET="${HOME}/${line[1]}"
            mkdir -p "$(dirname $TARGET)"
            ln -vs --backup=t "${SOURCE}" "${TARGET}"
        fi
    done < "${CONFIG_PATH}/config_mappings.txt"
}

function maybe_restore_config_file {
    # restore_config_file target_location
    LATEST_BACKUP_FILE=$(ls -d "$1".~*~ | sort | tail -1)
    if [[ -f "${LATEST_BACKUP_FILE}" ]]; then
    [[ -d "${LATEST_BACKUP_FILE}" ]] && rm $1
        mv -v "${LATEST_BACKUP_FILE}" $1 || true
    fi
}

function get_bin_dir {
    if [[ "$(have_sudo; echo $?)" -ne 1 ]]; then
        BIN_DIR=/usr/bin
    else
        BIN_DIR=$HOME/.local/bin
        mkdir -p $BIN_DIR
    fi
    echo $BIN_DIR
}

function pkg_mngr_update {
    if [[ -f pkg_mngr_uptodate ]]; then
        return 0
    else
        $SUDO_PREFIX $PKG_MNGR update && touch pkg_mngr_uptodate
    fi
}

function try_pkg_mngr {
    echo "Attempting to install $@ with $PKG_MNGR."
    SUDO_PREFIX=$(get_sudo_prefix)
    if [[ "$PKG_MNGR" = 'apt-get' ]]; then
        pkg_mngr_update
        $SUDO_PREFIX DEBIAN_FRONTEND=noninteractive apt-get install $@ --yes
    elif [[ "$PKG_MNGR" = 'dnf' ]]; then
        pkg_mngr_update
        $SUDO_PREFIX dnf -y install $@
    elif [[ "$PKG_MNGR" = 'pacman' ]]; then
        $SUDO_PREFIX pacman -S --noconfirm $@
    else
        errmess "Unknown package manager '$PKG_MNGR' selected."
        return 1
    fi
    if [[ "$?" -eq 0 ]]; then
        return 0
    else
        errmess "Could not install $@ with $PKG_MNGR."
        return 1
    fi
}

function try_conda_forge {
    echo "Attempting to install $@ with conda."
    have_conda || (echo "Conda not installed." && return 1)
    conda install -c conda-forge $@ --yes
    if [[ "$?" -eq 0 ]]; then
        return 0
    else
        errmess "Could not install $@ with conda."
        return 1
    fi
}

# try to install packages with package manager if privileges ok;
# if fails or if no privs, try with conda forge.
function try_install_cascade {
    notfound=($(get_nonfound_cmds "$@"))
    [[ "${#notfound[@]}" -eq 0 ]] && return 0
    have_sudo && try_pkg_mngr $notfound && return 0
    have_conda && try_conda_forge $notfound && return 0
    errmess "Failed to install $notfound."
    return 1
}

# Try to install all packages. At the end, unless disabled, check if each package is
# available from the command line. If not return 1.
# Else, return 0.
# If disabled, return the output of try_install_cascade.
function try_install_all {
    try_install_cascade "$@"
    RV=$?
    if [[ "$2" != false ]]; then
        notfound_again=($(get_nonfound_cmds $@))
        [[ "${#notfound_again[@]}" -eq 0 ]] && return 0 || return 1
    fi
    return $RV
}

function try_install_any {
    RV=0
    for tool in "$@"; do
        try_install_cascade $tool || RV=1
    done
    return $RV
}
