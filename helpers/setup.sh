#!/bin/bash

# Helper functions and vars for use in the other setup scripts. Most of these are from
# my gibrc, but that's not necessarily installed yet.

# Include (source) with this line (assuming you're in dot):
# . $(dirname $0)/helpers/setup.sh # Load helper script from dot/helpers.

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

# Used when you're not sure if you'll install or update something.
getOrUpdate() {
    printf "${CYAN}❯❯❯ Installing/Updating:${NC} $@\n"
}

# Used when you're going to install something.
get() {
    printf "${CYAN}❯❯❯ Installing:${NC} $@\n"
}

# Used when you're going to install something.
update() {
    printf "${CYAN}❯❯❯   Updating:${NC} $@\n"
}

# Used when you're not going to install something.
skip() {
    printf "${YELLOW}❯❯❯   Skipping:${NC} $@\n"
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
    skip "$@"
    return 1 # Binary in path.
  fi
}

# Some machines can't understand GitHub's https certs for some reason.
gitClone() {
  get "$@"
  REPO=$1; shift # First arg is repo, rest are passed on to git clone.
  git clone git@github.com:$REPO.git $@ ||
    git clone https://github.com/$REPO.git $@
}

gitUpdate() {
  DIR="$1" # First arg is repo.

  pushd "$DIR"

  git fetch --all

  if [ "$(git status --porcelain)" ]; then
    git add -A
    # Amend the previous commit if it's one you made.
    [ $(git show -s --pretty=%an) = $(git config user.name) ] && FLAGS=--amend
    git commit $FLAGS -m "My changes as of $(date)"
  fi

  local skip=true
  # If upstream is a different commit as HEAD, rebase:
  if [ "$(git rev-parse $(git headUpstream))" != "$(git rev-parse HEAD)" ]; then
    unset skip
    git rebase

    if [ -d "$(git rev-parse --git-path rebase-merge)" -o -d "$(git rev-parse --git-path rebase-apply)" ]; then
      addError "Git rebase failed for $1"
      git rebase --abort
    fi
  fi

  # If upstream submodule is a different sha from head, update it:
  if [ "$(git submodule status --recursive 2>/dev/null | grep -q '^+')" ]; then
    unset skip
    git submodule update --rebase --recursive
  fi

  [ "$skip" ] && skip "$@" || update "$@"
  popd
}

# If the repo isn't there, clone it, if it is, update it.
gitCloneOrUpdate() {
  DIR="$2" # Directory to clone into.
  if [ ! -d "$DIR" ]; then
    gitClone $@
  else
    gitUpdate "$2"
  fi
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

# Summary of what has run, pass fail status plus optional error message. $1 is
# what it's the status of (should be all-caps).
finalOutput() {
  printf "${BCYAN}❯❯❯ $1 STATUS:${NC} $?\n"
  [ "$FINAL_OUTPUT" ] && printf "${BGBRED}❯❯❯ FINAL OUTPUT:${NC} $FINAL_OUTPUT\n"
}

# Summary of what has run, pass fail status plus optional error message. $1 is
# what it's the status of (should be all-caps).
addError() {
  FINAL_OUTPUT="$FINAL_OUTPUT\n${RED}ERR:${NC} $@"
}
