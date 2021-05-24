#!/usr/bin/env zsh

set -eu

autoload -U colors && colors

current=$(sha256sum /Library/Preferences/com.apple.HIToolbox.plist | awk '{print $1}')
original=$(sha256sum "$(dirname "$0")"/config/original_com.apple.HIToolbox.plist | awk '{print $1}')

if [[ "$original" != "$current" ]]; then
  echo -e "${fg[red]}Error:${reset_color} unexpected contents of /Library/Preferences/com.apple.HIToolbox.plist

Actual: $current
Expected: $original" >&2
  exit 7
fi

sudo cp "$(dirname "$0")"/config/colemak_com.apple.HIToolbox.plist /Library/Preferences/com.apple.HIToolbox.plist
sudo chmod 644 /Library/Preferences/com.apple.HIToolbox.plist
