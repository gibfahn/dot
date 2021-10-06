#!/usr/bin/env bash

set -eux

# Check VOLTA_HOME was set (by up).
[[ -n $VOLTA_HOME ]]

curl https://get.volta.sh | bash -s -- --skip-setup
volta install node@lts yarn
