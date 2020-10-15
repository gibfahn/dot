#!/usr/bin/env bash

set -eu

current=$(sha256sum /Library/Preferences/com.apple.HIToolbox.plist | awk '{print $1}')
original=$(sha256sum "$(dirname "$0")"/config/original_com.apple.HIToolbox.plist | awk '{print $1}')


RED='\033[0;31m' # Red.
NC='\033[0m' # No Colour.

if [[ "$original" != "$current" ]]; then
  echo -e "${RED}Error:${NC} unexpected contents of /Library/Preferences/com.apple.HIToolbox.plist

Actual: $current
Expected: $original" >&2
  exit 7
fi

sudo cp "$(dirname "$0")"/config/colemak_com.apple.HIToolbox.plist  /Library/Preferences/com.apple.HIToolbox.plist
sudo chmod 644 /Library/Preferences/com.apple.HIToolbox.plist
