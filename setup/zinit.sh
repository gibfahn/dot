#!/usr/bin/env bash

. "$(dirname "$0")"/../helpers/setup.sh # Load helper script from dot/helpers.

set -ex

# Update zsh plugins.
gitCloneOrUpdate zdharma/zinit "$XDG_DATA_HOME/zsh/zinit/bin" # Zsh plugin manager.

hermetic_zinit self-update
hermetic_zinit update --all -p 20
# hermetic_zinit delete --clean -y # Remove no-longer-used plugins and snippets.
# hermetic_zinit cclear # Remove outdated completion entries.
