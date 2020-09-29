#!/usr/bin/env bash

# Set lock screen and desktop backgrounds.

# Env:
#  - MAC_DESKTOP_BACKGROUND: local path to png to use as background.
#  - MAC_CLOUD_DESKTOP_BACKGROUND: cloud file to copy to local path before using.

if [[ ! -e ${MAC_CLOUD_DESKTOP_BACKGROUND?} ]]; then
  brctl download "$MAC_CLOUD_DESKTOP_BACKGROUND"
fi
if [[ ! -e ${MAC_DESKTOP_BACKGROUND?} ]]; then
  cp "$MAC_CLOUD_DESKTOP_BACKGROUND" "$MAC_DESKTOP_BACKGROUND"
fi

# Set desktop background.
if osascript -e '
    tell application "System Events"
        tell every desktop
            get picture
        end tell
    end tell' | tr ',' '\n' | grep -v "$MAC_DESKTOP_BACKGROUND"; then

  log_get "Setting desktop background to $MAC_DESKTOP_BACKGROUND"
  osascript -e "
    tell application \"System Events\"
        tell every desktop
            set picture to \"$MAC_DESKTOP_BACKGROUND\"
        end tell
    end tell"
else
  log_skip "Setting desktop background to $MAC_DESKTOP_BACKGROUND"
fi

# Set login picture.
lockscreen_picture=$(ls "/Library/Caches/Desktop Pictures/"*/lockscreen.png)
[[ -e $lockscreen_picture ]] || { echo "Lockscreen picture missing: $lockscreen_picture" >&2; exit 1; }
if [[ $(md5 -q "$lockscreen_picture") == $(md5 -q "$MAC_DESKTOP_BACKGROUND") ]]; then
  log_skip "Setting lockscreen picture to $MAC_DESKTOP_BACKGROUND"
else
  log_get "Setting lockscreen picture to $MAC_DESKTOP_BACKGROUND"
  cp "$MAC_DESKTOP_BACKGROUND" "$lockscreen_picture"
fi

