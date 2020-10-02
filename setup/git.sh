#!/usr/bin/env bash

set -eu

# Things that I want to do to every git repository, every time.

# If a repo isn't in $_Z_DATA then add it.
grep -q "^$PWD|" "$_Z_DATA" && echo "$PWD|1|$(date +%s)" >> "$_Z_DATA"

# Update the repo.
"${dot_dir:-$HOME/code/dot}/dotfiles/bin/git-update"
