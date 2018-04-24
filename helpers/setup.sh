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

# TODO(gib): Add log prefix to these.

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

# TODO(gib): Should this update from the up remote?
# TODO(gib): Return error code if rebase had conflicts (and print next steps).
# TODO(gib): Maybe create a backup branch.
gitUpdate() {
  DIR="$1" # First arg is directory.

  pushd "$DIR"

  git fetch --all

  local skip=true   # Whether we did anything or just skipped this update.
  local exit_code=0 # What the function should return (default 0 == success).
  # If upstream is a different commit as HEAD, rebase:
  if [ "$(git rev-parse $(git headUpstream))" != "$(git rev-parse HEAD)" ]; then
    unset skip

    # If you have uncommitted changes, commit them.
    if [ "$(git status --porcelain)" ]; then
      git add -A
      # Amend the previous commit if it's one you made.
      [ "$(git show -s --pretty=%an)" = "$(git config user.name)" ] &&
        FLAGS=--amend ||
        FLAGS="-m 'My changes as of $(date)'"
      git commit $FLAGS
    fi

    git rebase

    if [ -d "$(git rev-parse --git-path rebase-merge &>/dev/null)" ] ||
       [ -d "$(git rev-parse --git-path rebase-apply &>/dev/null)" ]; then
      addError "Git rebase failed for $1"
      exit_code=1
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
  return "$exit_code"
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
  local status="$?"
  printf "${BCYAN}❯❯❯ $1 STATUS:${NC} $status\n"
  [ "$FINAL_OUTPUT" ] && printf "${BGBRED}❯❯❯ FINAL OUTPUT:${NC} $FINAL_OUTPUT\n"
  exit "$status"
}

# Summary of what has run, pass fail status plus optional error message. $1 is
# what it's the status of (should be all-caps).
addError() {
  FINAL_OUTPUT="$FINAL_OUTPUT\n${RED}ERR:${NC} $@"
}
