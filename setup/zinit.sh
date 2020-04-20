#!/usr/bin/env bash

. "$(dirname "$0")"/../helpers/setup.sh # Load helper script from dot/helpers.

set -ex

# Update zsh plugins.
gitCloneOrUpdate zdharma/zinit "$XDG_DATA_HOME/zsh/zinit/bin" # Zsh plugin manager.
zsh -c '
declare -A ZINIT
ZINIT[HOME_DIR]=$XDG_DATA_HOME/zsh/zinit
ZINIT[BIN_DIR]=$XDG_DATA_HOME/zsh/zinit/bin # Where zinit is installed.
ZINIT[ZCOMPDUMP_PATH]=$XDG_CACHE_HOME/zsh/.zcompdump$(hostname)
source "$XDG_DATA_HOME/zsh/zinit/bin/zinit.zsh" # Source plugin manager.
zinit self-update
zinit update --all -p 20
# zinit delete --clean -y # Remove no-longer-used plugins and snippets.
# zinit cclear # Remove outdated completion entries.
'
