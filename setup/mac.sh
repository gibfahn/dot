#!/usr/bin/env bash
# shellcheck shell=bash disable=SC1090,SC2016

# Things I like to have on a Mac.

set -e

. "$(dirname "$0")/../helpers/setup.sh" # Load helper script from dot/helpers.

# Link VS Code preferences into the macOS specific folder.
if [[ $USER == gib && -d "$HOME/Library/Application Support/Code/" ]]; then
  for file in "$HOME"/.config/code/*.json; do
    ln -sf "$file" "$HOME/Library/Application Support/Code/User/$(basename "$file")"
  done
fi

# Set Keyboard Shortcuts -> App Shortcuts
# To add your own, first add them in System Preferences -> Keyboard ->
# Shortcuts -> App Shortcuts, then find them in the output of:
#   defaults find NSUserKeyEquivalents
# Use the existing and the help output of `defaults` to work it out.
#   @command, ~option, ^ctrl, $shift
# The global domain NSGlobalDomain NSGlobalDomain is the same as -g or -globalDomain.
# -bool yes/true or no/false correspond to -int 1 or 0.
# You can view plist files with /usr/libexec/PlistBuddy
# To log changing plist files try one of:
#     sudo log stream --level debug --predicate "process == 'cfprefsd' AND eventMessage contains 'wrote the key'"
#     sudo iosnoop -n cfprefsd

# Make user keyboard layout the default layout on login (maybe dangerous):
#   sudo cp ~/Library/Preferences/com.apple.HIToolbox.plist /Library/Preferences/com.apple.HIToolbox.plist
#   sudo chmod 644 /Library/Preferences/com.apple.HIToolbox.plist

log_section "Setting macOS defaults."

# -> Kitty:
updateMacOSKeyboardShortcut net.kovidgoyal.kitty "Hide kitty" '~^$\\U00a7'
# -> Mail: ⌘-b moves to Archive.
updateMacOSKeyboardShortcut com.apple.mail "Archive" '@b'
# -> Mail: ⌘-u sends the message.
updateMacOSKeyboardShortcut com.apple.mail "Send" '@u'

# Unnatural scrolling direction (swipe down to scroll down).
changed=$(updateMacOSDefault NSGlobalDomain com.apple.swipescrolldirection bool false)
if [[ -n "$changed" ]]; then
  log_debug "Applying scroll direction changes with '/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u' as previous value was '$changed' not false"
  /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
fi

# Enable Tap to Click for the current user.
updateMacOSDefault -currentHost NSGlobalDomain com.apple.mouse.tapBehavior int 1

# Prevent Photos from opening automatically when devices are plugged in
updateMacOSDefault -currentHost com.apple.ImageCapture disableHotPlug bool true

# System Preferences > Sound Effects > Select and alert sound: Heroine.
# Change the error sound to the drum.
if [[ -e /System/Library/Sounds/Hero.aiff ]]; then
  updateMacOSDefault NSGlobalDomain com.apple.sound.beep.sound string /System/Library/Sounds/Hero.aiff
else
  echo "Couldn't find file /System/Library/Sounds/Hero.aiff"
  exit 15
fi

if [[ $USER == gib ]]; then # Set keyboard preferences.
  log_section "Setting gib extra macOS defaults."

  # Create global shortcut "Merge all windows" ⌘-M
  updateMacOSKeyboardShortcut NSGlobalDomain "Merge All Windows" '@$m'

  # Set up fastest key repeat rate (needs relogin).
  updateMacOSDefault NSGlobalDomain KeyRepeat int 1

  # Sets a low time before key starts repeating.
  updateMacOSDefault NSGlobalDomain InitialKeyRepeat int 8

  # Use Dark mode.
  updateMacOSDefault NSGlobalDomain AppleInterfaceStyle string Dark
  # Don't brighten window contents (better contrast in Dark Mode).
  # System Preferences > General > Allow wallpaper tinting in windows (true here means uncheck the tickbox).
  updateMacOSDefault NSGlobalDomain AppleReduceDesktopTinting bool true

  # Auto-hide menu bar.
  updateMacOSDefault NSGlobalDomain _HIHideMenuBar bool true
  # Auto-hide dock.
  updateMacOSDefault com.apple.dock autohide bool true

  # Have the Dock only show apps currently running.
  updateMacOSDefault com.apple.dock static-only bool true

  # Make the dock appear instantly.
  # https://simcityltd.medium.com/how-to-get-the-perfect-macos-dock-b2593f9c0f0b
  updateMacOSDefault com.apple.dock autohide-delay float 0
  updateMacOSDefault com.apple.dock autohide-time-modifier float 0.25

  # Allow Finder to be quit (hides Desktop files).
  updateMacOSDefault com.apple.finder QuitMenuItem int 1

  # Disable the animations for opening Quick Look windows
  updateMacOSDefault NSGlobalDomain QLPanelAnimationDuration float 0

  # Set sidebar icon size to medium
  updateMacOSDefault NSGlobalDomain NSTableViewDefaultSizeMode int 2

  # Show all processes in Activity Monitor
  updateMacOSDefault com.apple.ActivityMonitor ShowCategory int 0

  # Enable dictation with double-tap of Fn button.
  updateMacOSDefault com.apple.HIToolbox AppleDictationAutoEnable int 1
  # System Preferences > Keyboard > Press Function key to: Start Dictation.
  #                               > Press and hold Fn key to: Show F1, F2, F3 Keys.
  updateMacOSDefault com.apple.HIToolbox AppleFnUsageType int 3

  # Messages > Preferences > Keep messages: Forever.
  updateMacOSDefault com.apple.MobileSMS KeepMessageForDays int 0

  # Enable Safari’s debug menu
  updateMacOSDefault com.apple.Safari IncludeInternalDebugMenu bool true
  # Enable Safari’s debug menu
  # Prevent Safari from opening ‘safe’ files automatically after downloading
  updateMacOSDefault com.apple.Safari AutoOpenSafeDownloads bool false
  # Default to saving files in ~/tmp.
  updateMacOSDefault com.apple.Safari NSNavLastRootDirectory string '~/tmp'
  # Safari > Preferences > General > Safari opens with: All non-private windows from last session.
  updateMacOSDefault com.apple.Safari OpenPrivateWindowWhenNotRestoringSessionAtLaunch bool false
  # Make Safari’s search banners default to Contains instead of Starts With
  updateMacOSDefault com.apple.Safari FindOnPageMatchesWordStartsOnly bool false

  # Add a context menu item for showing the Web Inspector in web views
  updateMacOSDefault NSGlobalDomain WebKitDeveloperExtras bool true

  # Order matters here for the "has it changed" comparison.
  spotlight_preferences=(
    '{"enabled" = 1;"name" = "APPLICATIONS";}'
    '{"enabled" = 1;"name" = "MENU_EXPRESSION";}'
    '{"enabled" = 1;"name" = "MENU_DEFINITION";}'
    '{"enabled" = 1;"name" = "SYSTEM_PREFS";}'
    '{"enabled" = 0;"name" = "DIRECTORIES";}'
    '{"enabled" = 0;"name" = "PDF";}'
    '{"enabled" = 0;"name" = "FONTS";}'
    '{"enabled" = 0;"name" = "DOCUMENTS";}'
    '{"enabled" = 0;"name" = "MESSAGES";}'
    '{"enabled" = 0;"name" = "CONTACT";}'
    '{"enabled" = 0;"name" = "EVENT_TODO";}'
    '{"enabled" = 0;"name" = "IMAGES";}'
    '{"enabled" = 0;"name" = "BOOKMARKS";}'
    '{"enabled" = 0;"name" = "MUSIC";}'
    '{"enabled" = 0;"name" = "MOVIES";}'
    '{"enabled" = 0;"name" = "PRESENTATIONS";}'
    '{"enabled" = 0;"name" = "SPREADSHEETS";}'
    '{"enabled" = 0;"name" = "SOURCE";}'
    '{"enabled" = 0;"name" = "MENU_OTHER";}'
    '{"enabled" = 1;"name" = "MENU_CONVERSION";}'
    '{"enabled" = 0;"name" = "MENU_WEBSEARCH";}'
    '{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}'
  )

  existing_spotlight_preferences=$(defaults read com.apple.Spotlight orderedItems | tr -d '\n' | tr -d ' ' | tr -d ',' | tr -d '"')
  trimmed_expected_spotlight_preferences=$(printf "(${spotlight_preferences[*]})" | tr -d ' ' | tr -d '"')
  log_debug "Existing spotlight preferences: $existing_spotlight_preferences"
  log_debug "Expected spotlight preferences: $trimmed_expected_spotlight_preferences"
  if [[ $existing_spotlight_preferences == "$trimmed_expected_spotlight_preferences" ]]; then
    log_skip "macOS default Spotlight Preferences"
  else
    log_get "macOS default Spotlight Preferences"

    # Change indexing order and disable some search results
    defaults write com.apple.Spotlight orderedItems -array "${spotlight_preferences[@]}"

    # Load new settings before rebuilding the index
    log_debug "Running 'killall mds'"
    killall mds >&2 || true
    log_debug "Making sure indexing is enabled for the main volume"
    sudo mdutil -i on / >&2
    log_debug "Rebuilding the index from scratch"
    sudo mdutil -E / >&2
  fi

  # Disable the macOS chime sound when you power on the machine.
  # On is %00, off is %01.
  if startup_mute=$(nvram StartupMute | awk '{print $NF}') && [[ $startup_mute == %01 ]]; then
    log_skip "macOS Startup Chime already disabled."
  else
    log_get "Disabling macOS Startup Chime"
    sudo nvram StartupMute=%01
  fi

  # TODO(gib): Add more shortcuts:
  #
  # Make changing windows quicker with keyboard.
  #   defaults write com.apple.dock expose-animation-duration -float 0.1
  # Increase window resize speed for Cocoa animations
  #   defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
  # https://github.com/pawelgrzybek/dotfiles/blob/master/setup-macos.sh
  # https://github.com/mathiasbynens/dotfiles/blob/master/.macos
  # https://github.com/kevinSuttle/macOS-Defaults
  # Show path bar in finder:
  #   defaults write com.apple.finder ShowPathbar -bool true
  # Cmd-Enter sends email in Mail.

else
  log_section "Setting macOS defaults for not gib."

  # Set up a faster key repeat rate (needs relogin).
  updateMacOSDefault NSGlobalDomain KeyRepeat int 2

  # Sets a low time before key starts repeating.
  updateMacOSDefault NSGlobalDomain InitialKeyRepeat int 15
fi

# System Preferences -> Users & Groups -> Login Options -> Show Input menu in login window
sudo=sudo updateMacOSDefault /Library/Preferences/com.apple.loginwindow showInputMenu bool true

# System Preferences -> Software Update -> Automatically keep my mac up to date
sudo=sudo updateMacOSDefault /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload bool true

# Apply any changes made above:

# Increase max file watch limit. See https://eradman.com/entrproject/limits.html
# File downloaded from: https://eradman.com/entrproject/etc/limit.maxfiles.plist
if [[ -e /Library/LaunchDaemons/limit.maxfiles.plist ]]; then
  log_skip "File watcher limit (already increased)."
else
  log_get "File watcher limit."
  cp "$(dirname "$0")"/config/limit.maxfiles.plist /Library/LaunchDaemons/limit.maxfiles.plist
fi

# Allows you to do `locate <name>` to find anywhere in your system.
if [[ -e /var/db/locate.database ]]; then
  log_skip "Enabling updatedb"
else
  log_get "Enabling updatedb"
  sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist
fi
