#!/usr/bin/env bash

. "$(dirname "$0")"/../helpers/setup.sh # Load helper script from dot/helpers.

set -ex

# Swift LanguageServer.
sourcekit_lsp_path="$XDG_DATA_HOME"/sourcekit-lsp
if [[ $USER == gib ]]; then
  changed=$(gitCloneOrUpdate apple/sourcekit-lsp "$sourcekit_lsp_path")
  if [[ -n "$changed" ]]; then
    (cd "$XDG_DATA_HOME"/sourcekit-lsp || error "Failed to cd to the langserver directory"; swift package update && swift build -c release)
    ln -sf "$sourcekit_lsp_path"/.build/release/sourcekit-lsp "$HOME"/bin/sourcekit-lsp
  fi
fi
