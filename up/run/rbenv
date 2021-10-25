#!/usr/bin/env bash
# Set up rbenv for ruby version management.

set -ex

if [[ $USER == gib ]]; then
  (pushd "$XDG_DATA_HOME/rbenv" && src/configure && make -C src)
fi
