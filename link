#!/bin/bash

# This script symlinks everything from $FROMPATH (default: ./dotfiles/) into
# $TOPATH (default: $HOME). Anything that would be overwritten is copied into
# $BACKUP (default: $TOPATH/backup/).

# Basically you put your dotfiles in ./dotfiles/, in the same structure they
# were in relative to $HOME. Then if you want to edit your .bashrc (for
# example) you just edit ~/.bashrc, and as it's a symlink it'll actually edit
# dotfiles/.bashrc. Then you can add and commit that change.

. $(dirname $0)/helpers/colours.sh # Load helper script from dot/helpers.


: ${TOPATH:="$HOME"} # Where to write links to, update if necessary.
: ${BACKUP:="$TOPATH/backup"} # Place to back up old files.
mkdir -p "$BACKUP"

if [ -z "$FROMPATH" ]; then
  cd "$(dirname $0)/dotfiles/"
else
  cd "$FROMPATH"
fi
: ${FROMPATH:="$PWD"} # Where you keep your dotfiles.

printf "❯❯❯ Updating dotfile symlinks (linking from path: $FROMPATH)\n\n"

for FILE in $(find . -type f -o -type l | sed 's|./||'); do
  mkdir -p "$TOPATH/$(dirname $FILE)"
  if [ -d "$TOPATH/$FILE" -a ! -L "$TOPATH/$FILE" ]; then # Directory.
    printf "${RED}DIRSKIP: $TOPATH/$FILE is a directory!${NC}\n" # This shouldn't happen.
    continue
  elif [ -L "$TOPATH/$FILE" ]; then # Symlink.
    if [ "$(ls -l $TOPATH/$FILE | awk '{print $NF}')" = "$FROMPATH/$FILE" ]; then
      printf "${BBLACK}SKIP: $TOPATH/$FILE already points to $FROMPATH/$FILE.${NC}\n"
      continue
    fi
    printf "CHANGE: $TOPATH/$FILE $(ls -l $TOPATH/$FILE | awk '{print $NF}') -> $FROMPATH/$FILE\n"
    mkdir -p "$BACKUP/$(dirname $FILE)"
    rm "$TOPATH/$FILE" "$BACKUP/$FILE"
  elif [ -e "$TOPATH/$FILE" ]; then # File.
    printf "MOVE: $TOPATH/$FILE exists, moving to $BACKUP/$FILE\n"
    mkdir -p "$BACKUP/$(dirname $FILE)"
    mv "$TOPATH/$FILE" "$BACKUP/$FILE"
  else # Nothing there.
    printf "LINK: $TOPATH/$FILE -> $FROMPATH/$FILE\n"
  fi
  ln -s "$FROMPATH/$FILE" "$TOPATH/$FILE"
done

[ "$(ls -A $BACKUP)" ] || rm -r "$BACKUP" # Clean up backup folder if empty
