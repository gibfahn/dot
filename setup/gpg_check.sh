#!/usr/bin/env bash

set -eu

set -x

[[ -d $GNUPGHOME ]] && grep -q 'pinentry-program .*/pinentry-mac' "$GNUPGHOME"/gpg-agent.conf
