#!/usr/bin/env bash

. "$(dirname "$0")"/../helpers/setup.sh # Load helper script from dot/helpers.

set -ex

# Only run make if there were changes.
changed1=$(gitCloneOrUpdate rbenv/rbenv "$XDG_DATA_HOME/rbenv")
changed2=$(gitCloneOrUpdate rbenv/rbenv-default-gems "$XDG_DATA_HOME/rbenv"/plugins/rbenv-default-gems)

[[ -z $changed1 && -z $changed2 ]] # Only update if one changed.
