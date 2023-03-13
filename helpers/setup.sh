# shellcheck shell=bash disable=SC1090

# Helper functions and vars for use in the other setup scripts. Most of these are from
# my gibrc, but that's not necessarily installed yet.

# Include (source) with this line (assuming you're in dot):
# . "$(dirname "$0")"/helpers/setup.sh # Load helper script from dot/helpers.

set -euo pipefail

# No POSIX way to get dir of sourced script.
[ "${BASH_VERSION:-}" ] && thisDir="$(dirname "${BASH_SOURCE[0]}")"
[ "${ZSH_VERSION:-}" ] && thisDir="$(dirname "$0")"
[ -z "$thisDir" ] && thisDir="./helpers"

[[ -z "${dotDir:-}" ]] && dotDir="$(cd "$thisDir"/.. && pwd)"

# Get colour aliases.
. "$thisDir"/colours.sh

export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}  # Config stuff should go here.
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME/.cache"}     # Cache stuff should go here.
export XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"} # Data should go here.

: "${BUILD_DIR:="$HOME/code/build"}" # Directory to clone/build things in.
mkdir -p "$BUILD_DIR"
: "${BIN_DIR:="$HOME/bin"}" # Directory to copy binaries to.
mkdir -p "$BIN_DIR"

mkdir -p "$HOME/tmp/dot_log"
[[ ! -e "$HOME"/tmp/dot_log/dot_$$.log ]] || mv "$HOME"/tmp/dot_log/dot_$$.log{,.old}

exists() { type "$1" >/dev/null 2>&1; } # Check if command exists (is in path).

### Logging functions

# Used when you're going to install something.
log_get() {
  printf "${CYAN}❯❯❯   Installing:${NC} %s\n" "$@" 1>&2
}

# Used when you're not going to install something.
log_skip() {
  printf "${YELLOW}❯❯❯   Skipping:${NC} %s\n" "$@" 1>&2
}

# `hasSudo || exit` in individual install scripts to check for sudo.
hasSudo() {
  if [ "$(id -u)" = 0 ]; then
    return 0
  fi
  if [ "$NO_SUDO" ] || ! sudo -v; then
    log_skip "Packages (user doesn't have sudo)."
    return 1
  else
    log_get "Packages."
    return 0
  fi
}
