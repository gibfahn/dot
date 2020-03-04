#!/bin/bash

# shellcheck shell=bash disable=SC1090,SC2016

# Things I like to have on Alpine.

set -e

. "$(dirname "$0")"/../helpers/setup.sh # Load helper script from dot/helpers.

hasSudo || exit

# Apk install things. Added them individually so you can comment out lines to skip.
apk_list=(           # List of things to install.
  bash
  zsh                # I use zsh wherever possible.
  git                # Get an up-to-date git from the git-core ppa.
  curl               # Amazingly some installations don't come with curl.
  tree               # Recursive ls.
  neovim             # Better vim (works well with my vim config.
  entr               # Run command on file change (Unixy file/folder watcher).
  python3            # Used to run things that need python.
  python3-dev        # Used to pip install python things.
  gnupg              # gpg (used to sign git commits among other things)
  less               # Pager, e.g. for man or git.
  openssh            # Used to clone ssh repos among other things.
  nodejs             # One version of node is fine for now.
  sudo
  coreutils
  ncurses
  gcc g++
)

log_get "apk installing/updating: ${apk_list[*]}"
$sudo apk update
$sudo apk add "${apk_list[@]}"
$sudo apk upgrade

# It's alpine and we're running as root, assume we want to have a gib
# user.
if [[ $(id -u) == 0 ]] && ! id gib; then
  adduser -h /home/gib -s /bin/zsh -D gib
  passwd -u gib
  echo "gib ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

  sed -i 's/.*requiretty$/#Defaults requiretty/' /etc/sudoers

  chown -R gib ~gib
  echo "Now rerun the script as the gib user (you probably want to move the repo)"
  echo "mkdir -p /home/gib/code && mv $(realpath $(dirname $0)/..) /home/gib/code/dot"
  exit 1
fi
