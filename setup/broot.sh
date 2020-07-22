#!/usr/bin/env bash

set -eux

# Install broot symlink.
mkdir -p "$XDG_CONFIG_HOME"/.config/zsh
broot --print-shell-function zsh >"$XDG_CONFIG_HOME"/zsh/broot.zsh
