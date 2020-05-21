#!/usr/bin/env bash

set -ex

go_packages=(
  # github.com/sourcegraph/go-langserver # Go language server (used in nvim).
)

# Install or update any go packages we need.
[[ $USER == gib ]] && go get -u "${go_packages[@]}"

