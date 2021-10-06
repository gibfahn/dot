#!/usr/bin/env bash

set -eux

# Check VOLTA_HOME was set (by up).
[[ -n $VOLTA_HOME ]]

# Skip if volta directory exists.
[[ -d "$VOLTA_HOME/bin/volta" ]]
