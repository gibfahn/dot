#!/usr/bin/env bash

set -ex

go_packages=(
  # github.com/sourcegraph/go-langserver # Go language server (used in nvim).
)

# Install or update any go packages we need.
if [[ $USER == gib && ${#go_packages} != 0 ]]; then
  go get -u "${go_packages[@]}"
fi
