#!/bin/bash

# shellcheck shell=bash disable=SC2059

# This script symlinks everything from $FROMPATH (default: ./dotfiles/) into
# $TOPATH (default: $HOME). Anything that would be overwritten is copied into
# $BACKUP (default: $TOPATH/backup/).

# Basically you put your dotfiles in ./dotfiles/, in the same structure they
# were in relative to $HOME. Then if you want to edit your .bashrc (for
# example) you just edit ~/.bashrc, and as it's a symlink it'll actually edit
# dotfiles/.bashrc. Then you can add and commit that change.

set -eu

RED='\033[0;31m'    # Red.
BBLACK='\033[1;30m' # Bright black (dark grey).
NC='\033[0m'        # No Colour.

: "${TOPATH:="$HOME"}"          # Where to write links to, update if necessary.
: "${BACKUP:="$TOPATH/backup"}" # Place to back up old files.
mkdir -p "$BACKUP"

run_cmd=${DRY_RUN:+echo} # Set DRY_RUN to echo what we would do.

if [ -z "${FROMPATH:-}" ]; then
  cd "$(dirname "$0")/dotfiles/"
else
  cd "$FROMPATH"
fi
: "${FROMPATH:="$PWD"}" # Where you keep your dotfiles.

printf "❯❯❯ Updating dotfile symlinks (linking from path: $FROMPATH)\n\n"

while read -r FILE; do
  $run_cmd mkdir -p "$TOPATH/$(dirname "$FILE")"
  if [[ -d "$TOPATH/$FILE" && ! -L "$TOPATH/$FILE" ]]; then      # Directory.
    printf "${RED}DIRSKIP: $TOPATH/$FILE is a directory!${NC}\n" # This shouldn't happen.
    continue
  elif [ -L "$TOPATH/$FILE" ]; then # Symlink.
    if [ "$(readlink "$TOPATH/$FILE")" = "$FROMPATH/$FILE" ]; then
      printf "${BBLACK}SKIP: $TOPATH/$FILE already points to $FROMPATH/$FILE.${NC}\n"
      continue
    fi
    printf "CHANGE: '$TOPATH/$FILE' from '$(readlink "$TOPATH/$FILE")' -> '$FROMPATH/$FILE'\n"
    $run_cmd mkdir -p "$BACKUP/$(dirname "$FILE")"
    $run_cmd rm -f "$TOPATH/$FILE" "$BACKUP/$FILE"
  elif [ -e "$TOPATH/$FILE" ]; then # File.
    printf "MOVE: '$TOPATH/$FILE' exists, moving to '$BACKUP/$FILE'\n"
    $run_cmd mkdir -p "$BACKUP/$(dirname "$FILE")"
    $run_cmd mv "$TOPATH/$FILE" "$BACKUP/$FILE"
  else # Nothing there.
    printf "LINK: $TOPATH/$FILE -> $FROMPATH/$FILE\n"
  fi
  $run_cmd ln -s "$FROMPATH/$FILE" "$TOPATH/$FILE"
done <<<"$(find . -type f -o -type l | sed 's|./||')"

[[ "$(ls -A "$BACKUP")" ]] || $run_cmd rm -r "$BACKUP" # Clean up backup folder if empty
