# shellcheck shell=bash disable=SC1090

# Helper functions and vars for use in the other setup scripts. Most of these are from
# my gibrc, but that's not necessarily installed yet.

# Include (source) with this line (assuming you're in dot):
# . $(dirname $0)/helpers/setup.sh # Load helper script from dot/helpers.

set -e

# No POSIX way to get dir of sourced script.
[ "$BASH_VERSION" ] && thisDir="$(dirname "${BASH_SOURCE[0]}")"
[ "$ZSH_VERSION" ] && thisDir="$(dirname "$0")"
[ -z "$thisDir" ] && thisDir="./helpers"

[[ -z "$dotDir" ]] && dotDir="$(cd "$thisDir"/.. && pwd)"

# Get colour aliases.
. "$thisDir"/colours.sh

export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"} # Config stuff should go here.
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME/.cache"} # Cache stuff should go here.
export XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"} # Data should go here.

: "${BUILD_DIR:="$HOME/code/build"}" # Directory to clone/build things in.
mkdir -p "$BUILD_DIR"
: "${BIN_DIR:="$HOME/bin"}" # Directory to copy binaries to.
mkdir -p "$BIN_DIR"

mkdir -p "$HOME/tmp"
[[ ! -e "$HOME"/tmp/dot.log ]] || mv "$HOME"/tmp/dot.log{,.old}

exists() { type "$1" >/dev/null 2>&1; } # Check if command exists (is in path).

### Logging functions

# Used when you're starting a new section.
log_section() {
  printf "❯❯❯ %s\n" "$@" 1>&2
}

# Used when you're going to install something.
log_get() {
  printf "${CYAN}❯❯❯   Installing:${NC} %s\n" "$@" 1>&2
}

# Used when you're going to update something.
log_update() {
  printf "${CYAN}❯❯❯   Updating:${NC} %s\n" "$1" 1>&2
}

# Used when you're not going to install something.
log_skip() {
  printf "${YELLOW}❯❯❯   Skipping:${NC} %s\n" "$@" 1>&2
}

log_debug() {
    printf "%s\n" "$1" >> "$HOME"/tmp/dot.log
}

log_error() {
    printf "    ${RED}ERROR:${NC} %s\n" "$1" 1>&2
}

# Just normal logging things.
log_info() {
  printf "    %s\n" "$1"
}

# `if no foo` then foo isn't in $XDG_DATA_HOME and we should install it.
no() { # Do we need to install $1?
  if [ ! -e "$XDG_DATA_HOME/$1" ]; then
    log_get "$1"
    return 0 # Directory is missing.
  else
    log_skip "$1 (already exists)."
    return 1 # Directory not missing.
  fi
}

# `if not foo` then foo isn't in path and we should install it.
not() { # Do we need to install $1?
  if ! exists "$1"; then
    log_get "$@"
    return 0 # Binary not in path.
  else
    log_skip "$@"
    return 1 # Binary in path.
  fi
}

# Some machines can't understand GitHub's https certs for some reason.
gitClone() {
  log_get "$@"
  REPO=$1; shift # First arg is repo, rest are passed on to git clone.
  git clone "git@github.com:$REPO.git" "$@" ||
    git clone "https://github.com/$REPO.git" "$@"
}

# TODO(gib): Should this update from the up remote?
# TODO(gib): Return error code if rebase had conflicts (and print next steps).
# TODO(gib): Maybe create a backup branch.
# Args:
#   $1: directory to update.
# Prints nothing to stdout if there were no changes.
gitUpdate() {
  DIR="$1" # First arg is directory.

  local work_done return_code uncommitted_changes upstream_commits upstream_submodule_updates
  pushd "$DIR" >/dev/null || return 1

  git fetch --all >/dev/null || return 1

  work_done="" # Work we did in this update (defaults to nothing).
  return_code=0 # Return 0 unless something went wrong.
  uncommitted_changes="$(git status --porcelain)" # Is there anything in the working tree.
  upstream_commits="$(git rev-list -1 '@{u}' --not HEAD)" # Does upstream have something we don't.
  upstream_submodule_updates="$(git submodule status --recursive 2>/dev/null | grep -q '^+' || true)"

  if [[ -n "$upstream_commits" || -n "$upstream_submodule_updates" ]]; then
    work_done=1 # We need to do some work.

    # If you have uncommitted changes, commit them.
    if [[ -n "$uncommitted_changes" ]]; then
      git add -A 1>&2
      # Amend the previous commit if it's an autogenerated one.
      local flags=""
      { [[ "$(g show -s --pretty=%s)" = "My changes as of "* ]] && flags=--amend; } || true
      git commit -m "My changes as of $(date)" $flags 1>&2
    fi

    # If upstream is a different commit as HEAD, rebase:
    if [[ -n "$upstream_commits" ]]; then
      git rebase 1>&2

      if [ -d "$(git rev-parse --git-path rebase-merge &>/dev/null)" ] ||
         [ -d "$(git rev-parse --git-path rebase-apply &>/dev/null)" ]; then
        addError "Git rebase failed for $1"
        return_code=1
        git rebase --abort 1>&2
      fi
    fi

    # If upstream submodule is a different sha from head, update it:
    if [ "$upstream_submodule_updates" ]; then
      git submodule update --rebase --recursive 1>&2
    fi
  fi

  { [[ -n "$work_done" ]] && log_update "$@"; } || log_skip "$@"
  printf "%s\n" "$work_done" # If we did work print to stdout.
  popd >/dev/null || return 1
  return "$return_code"
}

# Git clone or update.
# If the repo isn't there, clone it, if it is, update it.
# Args:
#   $1: repo to clone (org/repo).
#   $2: dir to clone into.
#   $3-: Args to pass to git clone.
gitCloneOrUpdate() {
  local DIR="$2" # Directory to clone into.
  if [ ! -d "$DIR" ]; then
    gitClone "$@"
  else
    gitUpdate "$2"
  fi
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

# Summary of what has run, pass fail status plus optional error message. $1 is
# what it's the status of (should be all-caps).
finalOutput() {
  local status="$?"
  printf "${BCYAN}❯❯❯ %s STATUS:${NC} %s\n" "$1" "$status"
  [ "$FINAL_OUTPUT" ] && printf "${BGBRED}❯❯❯ FINAL OUTPUT:${NC} %s\n" "$FINAL_OUTPUT"
  exit "$status"
}

# Summary of what has run, pass fail status plus optional error message. $1 is
# what it's the status of (should be all-caps).
addError() {
  FINAL_OUTPUT="$FINAL_OUTPUT\n${RED}ERR:${NC} $*"
}

# For usage see updateMacOSKeyboardShortcut
updateMacOSDefaultDict() {
  local domain subdomain key val val2 current_val;
  domain="$1"; shift
  subdomain="$1"; shift
  key="$1"; shift
  val="$1"; shift
  [[ "$#" != 0 ]] && printf "Wrong number of args" && return 1
  val2="$(sed 's/\\/\\\\/g' <<<"$val")"  # `defaults` doubles the \ for no reason sometimes.

  # If the dict hasn't been initialised yet, create it.
  if ! defaults read "$domain" "$subdomain" >/dev/null; then
    defaults write "$domain" "$subdomain" -dict
  fi

  # Get the current value of the dict[key] (empty if unset).
  current_val="$(defaults read "$domain" "$subdomain"                 \
                | grep -F "$key"                                     \
                | sed -E "s/ *\"?$key\"? *= *\"?([^\"]*)\"?;/\1/" \
              )"

  if [[ "$current_val" == "$val" || "$current_val" == "$val2" ]]; then
    log_skip "macOS default shortcut $domain $key is already set to '$current_val'"
    return 0
  fi

  if [[ -n "$current_val" ]]; then
    log_update  "macOS default shortcut $domain $key is currently set to '$current_val', changing to '$val'"
  else
    log_update  "macOS default shortcut $domain $key is unset, setting it to '$val'"
  fi

  defaults write "$domain" "$subdomain" -dict-add "$key" "$val"
}

# Run:
#   defaults find NSUserKeyEquivalents
# Example output:
#   Found 1 keys in domain 'com.foo.bar': {
#       NSUserKeyEquivalents =     {
#           baz = bat;
#       };
#   }
# Call to use:
#   updateKeyboardShortcuts "com.foo.bar" "baz" "bat"
# Set sudo=sudo for commands that need root access.
updateMacOSKeyboardShortcut() {
  updateMacOSDefaultDict "$1" NSUserKeyEquivalents "$2" "$3"
  if ! defaults read com.apple.universalaccess com.apple.custommenu.apps | grep -qF "$1"; then
    log_update  "macOS default shortcut $1 is not in com.apple.universalaccess com.apple.custommenu.apps, adding it."
    log_debug "defaults write com.apple.universalaccess com.apple.custommenu.apps -array-add \"$1\""
    defaults write com.apple.universalaccess com.apple.custommenu.apps -array-add "$1" || {
      return_code=$?
      log_error "Add the current Terminal app to System Preferences -> Security & Privacy -> Full Disk Access."
      return "$return_code"
    }
  fi
}

# Read a macOS default with the correct type.
# Errors:
#   1: Incorrect args passed.
#   2: type mismatch
#   3: defaults returned an unexpected type.
#   4: user provided an unexpected type.
#   5: defaults returned an unexpected value.
# Examples:
#  readMacOSDefault NSGlobalDomain com.apple.swipescrolldirection bool
readMacOSDefault() {
  local domain key expected_type host # args to function.
  local parsed_type actual_type

  domain="$1"; shift
  key="$1"; shift
  expected_type="$1"; shift
  host="$1"; shift
  [[ "$#" != 0 ]] && log_error "Wrong number of args" && return 1

  parsed_value=$(defaults $host read "$domain" "$key") || return 0
  parsed_type=$(defaults $host read-type "$domain" "$key")

  if grep -q "Type is " <<<"$parsed_type"; then
    parsed_type=$(sed 's/^Type is //' <<<"$parsed_type")
  else
    return 1
  fi

  case $parsed_type in
    boolean) actual_type=bool ;;
    integer) actual_type=int ;;
    dictionary) actual_type=dict ;;
    float|string|array) actual_type=$parsed_type ;;
    *) log_error "Unexpected type $parsed_type"; return 3 ;;
  esac

  case $expected_type in
    boolean) expected_type=bool ;;
    integer) expected_type=int ;;
    dictionary) expected_type=dict ;;
    array-add) expected_type=array ;;
    float|string|array|bool|int|dict) ;;
    *) log_error "Unexpected expected_type $expected_type"; return 4 ;;
  esac

  if [[ $expected_type != "$actual_type" ]]; then
    log_error "Expected type for $domain $key to be $expected_type with but was $actual_type with value $parsed_value."
    return 2
  fi

  if [[ $expected_type == bool ]]; then
    case $parsed_value in
      1) echo "TRUE" ;;
      0) echo "FALSE" ;;
      *) log_error "Unexpected parsed value $parsed_value"; return 5 ;;
    esac
  else
    echo "$parsed_value"
  fi
}

# If you get:
#   defaults read foo bar -> 1
#   defaults read-type foo bar -> Type is integer
# Then you should set with:
#   updateMacOSDefault foo bar int 1 -currentHost
# Prints nothing to stdout if there were no changes.
updateMacOSDefault() {
  local domain key val_type val host # Args.
  local current_val
  domain="$1"; shift
  key="$1"; shift
  val_type="$1"; shift
  val="$1"; shift
  [[ -n ${1+x} ]] && host="$1" && shift

  [[ "$#" != 0 ]] && log_error "Wrong number of args" && return 1
  current_val=$(readMacOSDefault "$domain" "$key" "$val_type" "$host") || return "$?"

  if [[ "$val_type" == array-add ]]; then
    if grep -q "$val" <<<"$current_val"; then
      log_skip "macOS default $host $domain $key already contains $val"
      return 0
    fi
  else
    if [[ "$current_val" == "$val" ]]; then
      log_skip "macOS default $host $domain $key is already set to $val"
      return 0
    fi
  fi

  echo "$host $domain $key $current_val -> $val; "
  if [[ -n "$current_val" ]]; then
    log_update  "macOS default $host $domain $key is currently set to $current_val, changing to $val"
  else
    log_update  "macOS default $host $domain $key is unset, setting it to $val"
  fi

  log_debug "defaults $host write \"$domain\" \"$key\" \"-$val_type\" \"$val\""
  defaults $host write "$domain" "$key" "-$val_type" "$val" 1>&2
}
