#!/usr/bin/env bash

! osascript -e '
    tell application "System Events"
        tell every desktop
            get picture
        end tell
    end tell' | tr ',' '\n' | grep -v "$MAC_DESKTOP_BACKGROUND"
