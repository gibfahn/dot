#!/usr/bin/env bash

. "$(dirname "$0")"/../helpers/setup.sh # Load helper script from dot/helpers.

set -ex

pip3_modules=(
  neovim-remote                 # Connect to existing nvim sessions (try `g cm` in a nvim terminal).
  pynvim                        # Python plugin framework for neovim.
  'python-language-server[all]' # Python language server (I use it in neovim).
  vim-vint                      # Vim linter.
)

# Install or update pip modules.
export PATH=/usr/local/bin:$PATH # Make sure brew pip/ruby are the first pip/ruby in the PATH.
pip=pip
exists pip3 && pip=pip3
pip_installed="$($pip list | awk '{print $1}')"
pip_outdated="$($pip list --outdated | awk '{print $1}')"

for module in "${pip3_modules[@]}"; do
  if ! echo "$pip_installed" | grep -qx "${module%[*}" \
      || echo "$pip_outdated" | grep -qx "${module%[*}"; then
    # log_get "$pip: $module"
    $pip install --user --upgrade "$module"
  else
    :
    # TODO(gib): add skipping in the check command.
    # log_skip "$pip: $module"
  fi
done
