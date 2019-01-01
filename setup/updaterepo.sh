#!/bin/bash
# shellcheck shell=bash disable=SC2016

# Update this repo to the latest upstream version, preserving your changes.

cd "$(dirname "$0")" || { echo "Failed to cd"; exit 1; }

git fetch --all

if [ "$(git status --porcelain)" ]; then
  git add -A
  # Amend the previous commit if it's one you made.
  [[ $(git show -s --pretty=%an) = $(git config user.name) ]] && FLAGS=--amend
  git commit $FLAGS -m "My changes as of $(date)"
fi

echo 'Fix any conflicts with `git mc` and `git rebase --continue`, if you changed sth, consider raising a PR!'
git rebase

git submodule update --rebase --recursive

./up
