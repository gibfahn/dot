#!/usr/bin/env bash

set -ex

# Skip if env var not set.
[[ -z "$HISTFILE" || ! -e "$ZSH_CLOUD_HISTFILE" ]]
