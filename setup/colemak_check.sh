#!/usr/bin/env bash

set -eu

current=$(sha256sum /Library/Preferences/com.apple.HIToolbox.plist | awk '{print $1}')
fixed=$(sha256sum "$(dirname "$0")"/config/colemak_com.apple.HIToolbox.plist | awk '{print $1}')

# Skip (0 exit code) if /etc/pam.d/sudo is already the fixed version.
[[ "$current" == "$fixed" ]]
