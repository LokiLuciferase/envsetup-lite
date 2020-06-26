#!/usr/bin/env bash
set -euo pipefail
source functions.sh

# run selected
# run stuff requiring that sudo be called
[[ "$ALLOW_SUDO" = true ]] && sudo bash -c "$(declare -f); do_minimal_f"
[[ "$ALLOW_SUDO" = true ]] && [[ "$DO_EXTRAS" = true ]] && sudo bash -c "$(declare -f); do_extras_f"
# if we don't run with sudo and we have no wget, we can't install python or zsh
[[ -z "$(which wget)" ]] && echo "wget not installed. Exiting..." && exit 1
[[ "$DO_PYTHON" = true ]] && do_python_f
[[ "$DO_ENV" = true ]] && do_env_f
[[ "$DO_PYTHON" = true ]] && [[ "$DO_ENV" = true ]] && conda init zsh
echo "All selected components were installed."
