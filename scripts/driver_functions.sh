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
    dpkg --print-architecture || echo "amd64"
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
    elif [[ ! -z "$(groups $USER | grep sudo)" ]]; then
        sudo true
        return 0
    else
        return 1
    fi
}

function get_sudo_prefix {
    [[ "$USER" = 'root' ]] && echo "" || echo "sudo"
}

function introduce_config_file {
    # introduce_config_file storage_location target_location
    if [[ -d $2 || -f $2 ]]; then
        if [[ "${UPDATE_BEHAVIOUR}" != "all" && "${UPDATE_BEHAVIOUR}" != "configs" ]]; then
            errmess "Config $2 already exists."
            return 1
        fi
    fi
    UNIFIED_CONFIG_DIR="${HOME}/.envsetup-lite.d"
    CONFIG_FILENAME="$(basename $1)"
    mkdir -p "$(dirname $2)"
    mkdir -p "${UNIFIED_CONFIG_DIR}"
    cp -r --backup=t "$1" "${UNIFIED_CONFIG_DIR}"
    ln -s --backup=t "${UNIFIED_CONFIG_DIR}/${CONFIG_FILENAME}" $2
}

function maybe_restore_config_file {
    # restore_config_file target_location
    LATEST_BACKUP_FILE=$(ls -d "$1".~*~ | sort | tail -1)
    [[ -f "${LATEST_BACKUP_FILE}" ]] && mv "${LATEST_BACKUP_FILE}" $1 || true
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
    elif [[ "$PKG_MNGR" = 'yum' ]]; then
        pkg_mngr_update
        $SUDO_PREFIX yum -y install $@
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
