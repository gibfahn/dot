#!/usr/bin/env bash

. "$(dirname "$0")"/../helpers/setup.sh # Load helper script from dot/helpers.

set -ex

changes=$(gitCloneOrUpdate fwcd/KotlinLanguageServer "$XDG_DATA_HOME/KotlinLanguageServer")

log_info "$changes"

[[ -z $changes ]] # Skip if no changes.
