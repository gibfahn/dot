#!/usr/bin/env bash

set -eu

set -x

# Set up gpg agent Keychain integration.
# https://stackoverflow.com/questions/39494631/gpg-failed-to-sign-the-data-fatal-failed-to-write-commit-object-git-2-10-0

mkdir -p "$GNUPGHOME"
pinentry_mac_path=$(which pinentry-mac) # Expect it to be in the PATH.
echo "pinentry-program $pinentry_mac_path" >> "$GNUPGHOME"/gpg-agent.conf
