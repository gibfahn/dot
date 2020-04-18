#!/usr/bin/env bash

set -ex

# Set up less file (colors for less).
# We don't save the input to a lesskey file because we need the terminal to
# resolve the tput commands.
  lesskey -o "$XDG_CACHE_HOME/less" <(
cat << EOF
$(echo "#env") # Get a comment.
LESS_TERMCAP_md = $(tput bold; tput setaf 6)
LESS_TERMCAP_me = $(tput sgr0)
LESS_TERMCAP_so = $(tput bold; tput setaf 3; tput setab 4)
LESS_TERMCAP_se = $(tput rmso; tput sgr0)
LESS_TERMCAP_us = $(tput smul; tput bold; tput setaf 7)
LESS_TERMCAP_ue = $(tput rmul; tput sgr0)
LESS_TERMCAP_mr = $(tput rev)
LESS_TERMCAP_mh = $(tput dim)
EOF
  )
