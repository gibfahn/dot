#!/usr/bin/env bash

lockscreen_picture=$(ls "/Library/Caches/Desktop Pictures/"*/lockscreen.png)

! osascript -e '
    tell application "System Events"
        tell every desktop
            get picture
        end tell
    end tell' | tr ',' '\n' | grep -v "$MAC_DESKTOP_BACKGROUND" && [[ -e $lockscreen_picture ]] && [[ $(md5 -q "$lockscreen_picture") == $(md5 -q "$MAC_DESKTOP_BACKGROUND") ]]
