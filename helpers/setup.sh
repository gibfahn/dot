#!/bin/bash

# Helper functions and vars for use in the other setup scripts. Most of these are from
# my gibrc, but that's not necessarily installed yet.

# Include (source) with this line (assuming you're in gcfg):
# . $(dirname $0)/helpers/setup.sh # Load helper script from gcfg/helpers.

# No POSIX way to get dir of sourced script.
[ "$BASH_VERSION" ] && thisDir="$(dirname ${BASH_SOURCE[0]})"
[ "$ZSH_VERSION" ] && thisDir="$(dirname $0)"
[ -z "$thisDir" ] && thisDir="./helpers"

# Get colour aliases.
. "$thisDir"/colours.sh

export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"} # Config stuff should go here.
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME/.cache"} # Cache stuff should go here.
export XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"} # Data should go here.

: ${BUILD_DIR:="$HOME/code/build"} # Directory to clone/build things in.
mkdir -p "$BUILD_DIR"
: ${BIN_DIR:="$HOME/bin"} # Directory to copy binaries to.
mkdir -p "$BIN_DIR"

exists() { type "$1" >/dev/null 2>&1; } # Check if command exists (is in path).

### Logging functions

# Used when you're going to install something.
get() {
    echo -e "${CYAN}❯❯❯ Installing:${NC} $@"
}

# Used when you're not going to install something.
skip() {
    echo -e "${YELLOW}❯❯❯   Skipping:${NC} $@"
}

# `if no foo` then foo isn't in $XDG_DATA_HOME and we should install it.
no() { # Do we need to install $1?
  if [ ! -e "$XDG_DATA_HOME/$1" ]; then
    get "$1"
    return 0 # Directory is missing.
  else
    skip "$1 (already exists)."
    return 1 # Directory not missing.
  fi
}

# `if not foo` then foo isn't in path and we should install it.
not() { # Do we need to install $1?
  if ! exists "$1"; then
    get "$@"
    return 0 # Binary not in path.
  else
    get "$@"
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
  if [ "$NO_SUDO" ] || ! sudo -v; then
    skip "Packages (user doesn't have sudo)."
    return 1
  else
    get "Packages."
    return 0
  fi
}

finalOutput() {
  echo -e "${BCYAN}❯❯❯ INSTALL STATUS:${NC} $?"
  [ "$FINAL_OUTPUT" ] && echo -e "${BGBRED}❯❯❯ FINAL OUTPUT:${NC} $FINAL_OUTPUT"
}
