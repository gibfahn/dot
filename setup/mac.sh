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

# Make user keyboard layout the default layout on login (maybe dangerous):
#   sudo cp ~/Library/Preferences/com.apple.HIToolbox.plist /Library/Preferences/com.apple.HIToolbox.plist
#   sudo chmod 644 /Library/Preferences/com.apple.HIToolbox.plist

log_section "Setting macOS defaults."

dock_changed="" menu_changed="" finder_changed="" mail_changed="" safari_changed=""

# -> Kitty:
updateMacOSKeyboardShortcut net.kovidgoyal.kitty "Hide kitty" '~^$\\U00a7'
# -> Mail: ⌘-backspace moves to Archive.
updateMacOSKeyboardShortcut com.apple.mail "Archive" '@\\b'
# -> Mail: ⌘-Enter sends the message.
updateMacOSKeyboardShortcut com.apple.mail "Send" '@\\U21a9'

# Unnatural scrolling direction (swipe down to scroll down).
changed=$(updateMacOSDefault NSGlobalDomain com.apple.swipescrolldirection bool false)
if [[ -n "$changed" ]]; then
  log_debug "Applying scroll direction changes with '/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u' as previous value was '$changed' not false"
  /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
fi

# Enable Tap to Click
updateMacOSDefault -currentHost NSGlobalDomain com.apple.mouse.tapBehavior int 1

# Click strength: Haptic feedback 0: Light 1: Medium 2: Firm
updateMacOSDefault com.apple.AppleMultitouchTrackpad FirstClickThreshold int 0
updateMacOSDefault com.apple.AppleMultitouchTrackpad SecondClickThreshold int 0

# Silent clicking
updateMacOSDefault com.apple.AppleMultitouchTrackpad ActuationStrength int 0

# Keyboard -> Input Sources -> Show Input menu in menu bar.
updateMacOSDefault com.apple.TextInputMenu visible bool true

# Expand save panel by default
updateMacOSDefault NSGlobalDomain NSNavPanelExpandedStateForSaveMode bool true
updateMacOSDefault NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 bool true

# Expand print panel by default
updateMacOSDefault NSGlobalDomain PMPrintingExpandedStateForPrint bool true
updateMacOSDefault NSGlobalDomain PMPrintingExpandedStateForPrint2 bool true

# Disable the “Are you sure you want to open this application?” dialog
updateMacOSDefault com.apple.LaunchServices LSQuarantine bool false

# Always open new things in tabs (not new windows) for document based apps.
updateMacOSDefault NSGlobalDomain AppleWindowTabbingMode string always

# Maximise window when you double-click on the title bar.
updateMacOSDefault NSGlobalDomain AppleActionOnDoubleClick string Maximize

# System Preferences -> View ->
#   "Organise by Category" => false (default)
#   "Organise Alphabetically" => true
updateMacOSDefault com.apple.systempreferences.plist ShowAllMode bool true

# System Preferences > Keyboard > Text > Use smart quotes and dashes -> disable.
updateMacOSDefault NSGlobalDomain NSAutomaticDashSubstitutionEnabled bool false
updateMacOSDefault NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled bool false

# Don't show recents in dock.
dock_changed+=$(updateMacOSDefault com.apple.dock show-recents bool false)

# Check "Displays have separate spaces" (uncheck to allow multi-screen windows).
updateMacOSDefault com.apple.spaces spans-displays bool false

# System Preferences > Trackpad > More Gestures > App Expose > Enable
# Swipe down with 3 fingers to see windows for current app.
dock_changed+=$(updateMacOSDefault com.apple.dock showAppExposeGestureEnabled bool true)

# Greys out hidden apps in the dock (so you can see which are hidden).
dock_changed+=$(updateMacOSDefault com.apple.Dock showhidden bool true)

# System Preferences -> Keyboard -> Shortcuts -> Full Keyboard Access
# Full Keyboard Access: In Windows and Dialogs, press Tab to move keyboard
# focus between:
#   0: Text Boxes and Lists only
#   2: All controls
# Set it to 2 because that's much nicer (you can close confirmation prompts
# with the keyboard, Enter to press the blue one, tab to select between them,
# space to press the Tab-selected one. If there are underlined letters, hold
# Option and press the letter to choose that option.
updateMacOSDefault NSGlobalDomain AppleKeyboardUIMode int 2

# Remove delay in showing the draggable icon in window bars.
# https://mjtsai.com/blog/2020/10/05/big-surs-hidden-document-proxy-icon/
updateMacOSDefault NSGlobalDomain NSToolbarTitleViewRolloverDelay float 0

# Show hidden files in the finder.
finder_changed+=$(updateMacOSDefault com.apple.finder AppleShowAllFiles int 1)

# Finder: show all filename extensions
updateMacOSDefault NSGlobalDomain AppleShowAllExtensions bool true

# Display full POSIX path as Finder window title
updateMacOSDefault com.apple.finder _FXShowPosixPathInTitle int 1

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `glyv`
updateMacOSDefault com.apple.finder FXPreferredViewStyle string "Nlsv"

# Allow text selection in any QuickLook window.
updateMacOSDefault NSGlobalDomain QLEnableTextSelection int 1

# System Preferences > General > Click in the scrollbar to: Jump to the spot that's clicked
updateMacOSDefault NSGlobalDomain AppleScrollerPagingBehavior int 1

# Increases trackpad tracking speed / sensitivity (SysPref max 3.0).
updateMacOSDefault NSGlobalDomain com.apple.trackpad.scaling float 5
# Disable force clicking.
updateMacOSDefault NSGlobalDomain com.apple.trackpad.forceClick bool false

# System Preferences > Accessibility > Zoom > Use scroll gesture with modifer keys to zoom > Enabled
updateMacOSDefault com.apple.universalaccess closeViewScrollWheelToggle bool true

# System Preferences > Keyboard > Dictation > On
updateMacOSDefault com.apple.assistant.support "Dictation Enabled" bool true

# Show battery percentage in menu bar.
menu_changed+=$(updateMacOSDefault com.apple.controlcenter BatteryShowPercentage bool true)

# Set Menu Bar date format: https://www.unicode.org/reports/tr35/tr35-dates.html#Date_Field_Symbol_Table
# Note that only some formats are allowed. This shows: day of the week, date, time with seconds.
menu_changed+=$(updateMacOSDefault com.apple.menuextra.clock DateFormat string "EEE d MMM  HH:mm:ss")

# Make sure the relevant items from the Control Center are visible.
menu_changed+=$(updateMacOSDefault com.apple.controlcenter "NSStatusItem Visible WiFi" bool true)
menu_changed+=$(updateMacOSDefault com.apple.controlcenter "NSStatusItem Visible Battery" bool true)
menu_changed+=$(updateMacOSDefault com.apple.controlcenter "NSStatusItem Visible Clock" bool true)

# Disabled to use the multicolour accent colour.
# System Preferences > General > Accent Colour > Purple
# updateMacOSDefault NSGlobalDomain AppleAccentColor int 5

# System Preferences > General > Highlight Colour > Blue
updateMacOSDefault NSGlobalDomain AppleAquaColorVariant int 1

# Write hammerspoon config to alternate location.
updateMacOSDefault org.hammerspoon.Hammerspoon MJConfigFile string '~/.config/hammerspoon/init.lua'

# Enable key repeat.
# XXX(gib): Not sure if needed for Hammerspoon key repeat.
updateMacOSDefault NSGlobalDomain ApplePressAndHoldEnabled bool false

# Mail -> Preferences -> Viewing -> Show Message Headers -> Custom
mail_changed+=$(updateMacOSDefault com.apple.mail CustomHeaders array List-ID Message-ID X-Member-Count)
# Mail -> Preferences -> Viewing -> Show most recent message at the top
mail_changed+=$(updateMacOSDefault com.apple.mail ConversationViewSortDescending bool true)
# Mail -> Preferences -> Composing -> Automatically CC Myself.
mail_changed+=$(updateMacOSDefault com.apple.mail ReplyToSelf bool true)
# Mail -> Preferences -> Composing -> When quoting text in replies or forwards -> Include all the original message text.
mail_changed+=$(updateMacOSDefault com.apple.mail AlwaysIncludeOriginalMessage bool true)
# Mail -> Preferences -> Composing -> Mark addresses not ending with (checkbox):
mail_changed+=$(updateMacOSDefault com.apple.mail-shared AlertForNonmatchingDomains bool true)
# Mail -> Preferences -> Composing -> Mark addresses not ending with (addresses not to mark):
mail_changed+=$(updateMacOSDefault com.apple.mail-shared DomainForMatching array "@apple.com" "@group.apple.com")

# Safari -> General -> Safari opens with -> All non-private windows from last session
safari_changed+=$(updateMacOSDefault com.apple.Safari AlwaysRestoreSessionAtLaunch bool true)
safari_changed+=$(updateMacOSDefault com.apple.Safari ExcludePrivateWindowWhenRestoringSessionAtLaunch bool true)
# Safari -> General -> New windows open with -> Empty page
safari_changed+=$(updateMacOSDefault com.apple.Safari NewTabBehavior int 1)
# Safari -> General -> New tabs open with -> Empty page
safari_changed+=$(updateMacOSDefault com.apple.Safari NewWindowBehavior int 1)
# Safari -> General -> Remove history items -> Manually
safari_changed+=$(updateMacOSDefault com.apple.Safari HistoryAgeInDaysLimit int 36500)
# Safari -> Tabs -> Open pages in tabs instead of windows -> Always
safari_changed+=$(updateMacOSDefault com.apple.Safari TabCreationPolicy int 2)
# Safari -> Advanced -> Show full website address
safari_changed+=$(updateMacOSDefault com.apple.Safari ShowFullURLInSmartSearchField bool true)
# Safari -> Advanced -> Show Develop menu in menu bar
safari_changed+=$(updateMacOSDefault com.apple.Safari IncludeDevelopMenu bool true)
safari_changed+=$(updateMacOSDefault com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey bool true)
safari_changed+=$(updateMacOSDefault com.apple.Safari WebKitPreferences.developerExtrasEnabled bool true)

if [[ $USER == gib ]]; then # Set keyboard preferences.
  log_section "Setting gib extra macOS defaults."

  # Create global shortcut "Merge all windows" ⌘-M
  updateMacOSKeyboardShortcut NSGlobalDomain "Merge All Windows" '@$m'

  # Remove ⌘-h as a Hide Window shortcut in relevant apps.
  # -> IntelliJ Community Edition:
  # Removed because I haven't installed it.
  # updateMacOSKeyboardShortcut com.jetbrains.intellij.ce "Hide IntelliJ IDEA" '@~^\\U00a7'
  # -> IntelliJ:
  updateMacOSKeyboardShortcut com.jetbrains.intellij "Hide IntelliJ IDEA" '~^$\\U00a7'

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
  dock_changed+=$(updateMacOSDefault com.apple.dock autohide bool true)

  # Have the Dock only show apps currently running.
  dock_changed+=$(updateMacOSDefault com.apple.dock static-only bool true)

  # Allow Finder to be quit (hides Desktop files).
  finder_changed+=$(updateMacOSDefault com.apple.finder QuitMenuItem int 1)

  # Disable the animations for opening Quick Look windows
  updateMacOSDefault NSGlobalDomain QLPanelAnimationDuration float 0

  # Set sidebar icon size to medium
  updateMacOSDefault NSGlobalDomain NSTableViewDefaultSizeMode int 2

  # Show developer options in Radar 8.
  updateMacOSDefault com.apple.radar.gm shouldShowDeveloperOptions bool true
  # Keep all tabs in same window.
  updateMacOSDefault com.apple.radar.gm RDARWindowTabbingAllowMixedDocumentTypes bool true

  # Show all processes in Activity Monitor
  updateMacOSDefault com.apple.ActivityMonitor ShowCategory int 0

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
  if  [[ $existing_spotlight_preferences == "$trimmed_expected_spotlight_preferences" ]]; then
    log_skip "macOS default Spotlight Preferences"
  else
    log_get "macOS default Spotlight Preferences"

    # Change indexing order and disable some search results
    defaults write com.apple.Spotlight orderedItems -array "${spotlight_preferences[@]}"

    # Load new settings before rebuilding the index
    log_debug "Running 'killall mds'"
    killall mds >&2
    log_debug "Making sure indexing is enabled for the main volume"
    sudo mdutil -i on / >&2
    log_debug "Rebuilding the index from scratch"
    sudo mdutil -E / >&2
  fi

  # TODO(gib): Add more shortcuts:
  #
  # Make changing windows quicker with keyboard.
  #   defaults write com.apple.dock expose-animation-duration -float 0.1
  # Don't wait to hide the dock.
  #   defaults write com.apple.Dock autohide-delay -float 0
  # Remove dock animation animation.
  #   defaults write com.apple.dock autohide-time-modifier -float 1; killall Dock
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

if [[ -n "$dock_changed" ]]; then
  log_debug "Applying expose changes with 'killall Dock' as dock values changed: '$dock_changed'"
  killall Dock && true
fi

if [[ -n "$mail_changed" ]]; then
  log_debug "Applying Mail.app changes with 'killall Mail' as Mail values changed: '$mail_changed'"
  killall Mail && true
fi

if [[ -n "$safari_changed" ]]; then
  log_debug "Applying Safari.app changes with 'killall Safari' as Safari values changed: '$safari_changed'"
  killall Safari && true
fi

if [[ -n "$finder_changed" ]]; then
  log_debug "Applying AppleShowAllFiles changes with 'killall Finder' as finder values changed '$finder_changed'"
  killall Finder && true
  open ~
fi

if [[ -n "$menu_changed" ]]; then
  log_debug "Applying menu changes with 'killall SystemUIServer' as menu values changed '$menu_changed'"
  killall SystemUIServer && true
fi

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
