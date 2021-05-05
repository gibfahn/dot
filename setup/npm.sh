#!/usr/bin/env bash

. "$(dirname "$0")"/../helpers/setup.sh # Load helper script from dot/helpers.

set -ex

# Install nvm:
unamem="$(uname -m)"
nvm_prefix="${unamem/x86_64/}"
if [[ $USER == gib ]] && no "$nvm_prefix"/nvm; then
  # No install scripts as path update isn't required, it's done in gibrc.
  gitClone creationix/nvm "$XDG_DATA_HOME/${nvm_prefix}/nvm"
  . "$XDG_DATA_HOME/${nvm_prefix}"/nvm/nvm.sh # Load nvm so we can use it below.
  nvm install --lts                           # Install the latest LTS version of node.
fi

npm_modules=(
  bash-language-server              # Language server for bash and other shell script files.
  diagnostic-languageserver         # Generic language server (see linters).
  dockerfile-language-server-nodejs # Language server for Dockerfiles.
  javascript-typescript-langserver  # Language server for JavaScript and Typescript files.
  markdownlint-cli                  # Markdown linter.
  write-good                        # English text linter.
  yarn                              # Alternative to npm.
)

# Install npm modules.
if [[ $USER == gib ]]; then
  not npm && . "$XDG_DATA_HOME/${nvm_prefix}"/nvm/nvm.sh # Load nvm so we can use npm.
  installed_npm_module_versions="$(npm ls -g --depth=0 --loglevel=error | grep -Ex '.* [-_A-Za-z0-9]+@([0-9]+\.){2}[0-9]+' | sed -E 's/^.+ //' | sed 's/@/ /')"
  for module in "${npm_modules[@]}"; do
    if ! echo "$installed_npm_module_versions" | grep -qx "$module .*" \
      || [[ "$(echo "$installed_npm_module_versions" | grep -x "$module .*" | awk '{print $NF}')" != "$(npm info --loglevel=error "$module" version)" ]]; then
      log_get "npm: $module"
      npm install --global --loglevel=error "$module"@latest
    else
      log_skip "npm: $module"
    fi
  done
fi
