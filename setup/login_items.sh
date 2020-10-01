#!/usr/bin/env zsh

set -e

# Login Items that should be added to System Preferences -> Users & Groups -> Login Items
required_login_items=(Rectangle CopyQ Hammerspoon "Time Out")

# Set up login items.
IFS=$'\n' current_login_items=($(osascript -e 'tell application "System Events" to get login items' | sed -e 's/login item //g' -e 's/, /\n/g'))
for item in "${required_login_items[@]}"; do
  if ! (( ${current_login_items[(I)$item]} )); then
    echo "Adding login item $item" >&2
    osascript -e "tell application \"System Events\" to make login item at end with properties {path:\"/Applications/$item.app\", hidden:false}"
  fi
done
