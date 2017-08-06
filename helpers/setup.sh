#!/bin/bash

# Helper functions and vars for use in the other setup scripts. Most of these are from
# my gibrc, but that's not necessarily installed yet.

# Include (source) with this line (assuming you're in gcfg):
# . $(dirname $0)/helpers/setup.sh # Load helper script from gcfg/helpers.

export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"} # Config stuff should go here.
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME/.cache"} # Cache stuff should go here.
export XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"} # Data should go here.

exists() { type "$1" >/dev/null 2>&1; } # Check if command exists (is in path).

# `if no foo` then foo isn't in $XDG_DATA_HOME and we should install it.
no() { # Do we need to install $1?
  if [ ! -e "$XDG_DATA_HOME/$1" ]; then
    echo "❯❯❯ Installing: $1"
    return 0 # Directory is missing.
  else
    echo "❯❯❯ Already Installed : $1"
    return 1 # Directory not missing.
  fi
}

# `if not foo` then foo isn't in path and we should install it.
not() { # Do we need to install $1?
  if ! exists "$1"; then
    echo "❯❯❯ Installing: $1"
    return 0 # Binary not in path.
  else
    echo "❯❯❯ Already Installed : $1"
    return 1 # Binary in path.
  fi
}

# This is stupid, but some machines can't understand GitHub's https certs for some reason.
gitClone() {
  REPO=$1; shift # First arg is repo, rest are passed on to git clone.
  git clone git@github.com:$REPO.git $@ ||
    git clone https://github.com/$REPO.git $@
}

# `hasSudo || exit` in individual install scripts to check for sudo.
hasSudo() {
  if sudo -v; then
    echo "❯❯❯ Installing packages."
    return 0
  else
    echo "❯❯❯ User doesn't have sudo, skipping package installs"
    return 1
  fi
}
