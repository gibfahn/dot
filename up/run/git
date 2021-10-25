#!/usr/bin/env bash

set -eu

# Things that I want to do to every git repository, every time.

# If a repo isn't in $_Z_DATA then add it.
if ! grep -q "^$PWD|" "$_Z_DATA"; then
  echo >&2 "z: adding $PWD to $_Z_DATA"
  echo "$PWD|10|$(date +%s)" >>"$_Z_DATA"
fi
