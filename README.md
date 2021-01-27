# Dotfiles

## Installation

### Installation Scripts
To install everything on debian-based distros (will ask for sudo privileges to use `apt-get` for package installations):
```
curl -sL https://gist.github.com/LokiLuciferase/e104a783b98304b6ab4a04627caf9922/raw | bash
```

To install everything without sudo privileges (requires `curl` and `unzip` to be available, will attempt to
install any other packages from conda-forge):
```
curl -sL https://gist.github.com/LokiLuciferase/cd31c91b536dd65036a431d214f4e0d2/raw | bash
```

### Manual Installation
To customize which components to install, set the requisite environment variables and run the set up script:
```
export PKG_MNGR='apt-get'  # tested on Ubuntu (apt-get), Arch Linux (pacman) and Fedora 33 (dnf)
export ALLOW_SUDO=true  # allows installation of pkgs with package manager and writing to system dirs
export DO_PYTHON=true  #install an essential Python3 dev environment with data science focus, using miniconda3.
export DO_ENV=true  # install zsh, powerlevel10k and a number of dotfiles.
export DO_VIM=true  # install neovim and SpaceVim
export DO_EXTRAS=true  # also install extra features such as rg, goofys and fzf
export DO_DOCKER=true  # also install docker
export DO_ALL=false  # whether to override all other settings, and do all, using sudo

git clone git@github.com:LokiLuciferase/envsetup-lite.git
cd envsetup-lite
bash set_up.sh
```

