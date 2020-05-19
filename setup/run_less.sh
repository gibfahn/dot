#!/usr/bin/env bash

set -ex

# Set up less file (colors for less).
# We don't save the input to a lesskey file because we need the terminal to
# resolve the tput commands.
  lesskey -o "$XDG_CACHE_HOME/less" <(
cat << EOF
$(echo "#env") # Get a comment.

LESS_TERMCAP_ZN = $(tput ssubm)
LESS_TERMCAP_ZO = $(tput ssupm)
LESS_TERMCAP_ZV = $(tput rsubm)
LESS_TERMCAP_ZW = $(tput rsupm)
# green
LESS_TERMCAP_mb = $(tput bold; tput setaf 2)
# Blue.
LESS_TERMCAP_md = $(tput bold; tput setaf 74)
LESS_TERMCAP_me = $(tput sgr0)
# Dim (half-bright) mode.
LESS_TERMCAP_mh = $(tput dim)
# Reverse mode.
LESS_TERMCAP_mr = $(tput rev)
# End standout-mode.
LESS_TERMCAP_se = $(tput rmso; tput sgr0)
# Begin standout-mode - info box (yellow on blue).
LESS_TERMCAP_so = $(tput bold; tput setaf 3; tput setab 4)
 # End underline.
LESS_TERMCAP_ue = $(tput rmul; tput sgr0)
# Begin underline (white).
LESS_TERMCAP_us = $(tput smul; tput bold; tput setaf 146)
EOF
  )
