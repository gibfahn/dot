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

dock_changed="" menu_changed="" finder_changed=""

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
updateMacOSDefault NSGlobalDomain com.apple.mouse.tapBehavior int 1 -currentHost

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

# System Preferences > Keyboard > Text > Use smart quotes and dashes -> disable.
updateMacOSDefault NSGlobalDomain NSAutomaticDashSubstitutionEnabled bool false
updateMacOSDefault NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled bool false

# Don't show recents in dock.
dock_changed+=$(updateMacOSDefault com.apple.dock show-recents bool false)

# Uncheck "Displays have separate spaces" to allow multi-screen windows.
updateMacOSDefault com.apple.spaces spans-displays bool true

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
menu_changed=$(updateMacOSDefault com.apple.menuextra.battery ShowPercent string YES)

# Add the bluetooth settings to the Menu Bar.
if [[ ! -e "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" ]]; then
  # Make sure the menu item exists before adding it so we don't trash the machine.
  log_error "Can no longer find the bluetooth menu item."
  exit 1
fi
# Add the bluetooth settings to the Menu Bar.
if [[ ! -e "/System/Library/CoreServices/Menu Extras/Volume.menu" ]]; then
  # Make sure the menu item exists before adding it so we don't trash the machine.
  log_error "Can no longer find the Volume menu item."
  exit 1
fi
menu_changed+=$(updateMacOSDefault com.apple.systemuiserver menuExtras array-add "/System/Library/CoreServices/Menu Extras/Bluetooth.menu")
menu_changed+=$(updateMacOSDefault com.apple.systemuiserver menuExtras array-add "/System/Library/CoreServices/Menu Extras/Volume.menu")

# System Preferences > General > Accent Colour > Purple
updateMacOSDefault NSGlobalDomain AppleAccentColor int 5

# System Preferences > General > Highlight Colour > Blue
updateMacOSDefault NSGlobalDomain AppleAquaColorVariant int 1

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

  # Radar: Ctrl-Alt-C copies as Markdown:
  updateMacOSKeyboardShortcut com.apple.ist.Radar7 "Copy as Markdown" "~^c"

  # Set up fastest key repeat rate (needs relogin).
  updateMacOSDefault NSGlobalDomain KeyRepeat int 1

  # Sets a low time before key starts repeating.
  updateMacOSDefault NSGlobalDomain InitialKeyRepeat int 8

  # Disables window minimizing animations.
  updateMacOSDefault NSGlobalDomain NSAutomaticWindowAnimationsEnabled int 0

  # Use Dark mode.
  updateMacOSDefault NSGlobalDomain AppleInterfaceStyle string Dark

  # Auto-hide menu bar.
  updateMacOSDefault NSGlobalDomain _HIHideMenuBar bool true
  # Auto-hide dock.
  dock_changed+=$(updateMacOSDefault com.apple.dock autohide bool true)

  # Allow Finder to be quit (hides Desktop files).
  finder_changed+=$(updateMacOSDefault com.apple.finder QuitMenuItem int 1)

  # Disable the animations for opening Quick Look windows
  updateMacOSDefault NSGlobalDomain QLPanelAnimationDuration float 0

  # Set sidebar icon size to medium
  updateMacOSDefault NSGlobalDomain NSTableViewDefaultSizeMode int 2

  # Show developer options in Radar 8.
  updateMacOSDefault com.apple.radar.gm shouldShowDeveloperOptions int 1

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
    killall mds 2>&1 | log_debug_pipe
    # Make sure indexing is enabled for the main volume
    sudo mdutil -i on / 2>&1 | log_debug_pipe
    # Rebuild the index from scratch
    sudo mdutil -E / 2>&1 | log_debug_pipe
  fi

  # TODO(gib): Add more shortcuts:
  #
  # Make changing windows quicker with keyboard.
  #   defaults write com.apple.dock expose-animation-duration -float 0.1
  # Don't wait to hide the dock.
  #   defaults write com.apple.Dock autohide-delay -float 0
  # Reduce motion (fewer distracting animations).
  #   defaults write com.apple.universalaccess reduceMotion -bool true
  # Increase window resize speed for Cocoa animations
  #   defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
  # Have the Dock show only active apps
  #   defaults write com.apple.dock static-only -bool true; killall Dock
  # Remove dock animation animation.
  #   defaults write com.apple.dock autohide-time-modifier -float 1; killall Dock
  # https://github.com/pawelgrzybek/dotfiles/blob/master/setup-macos.sh
  # https://github.com/mathiasbynens/dotfiles/blob/master/.macos
  # https://github.com/kevinSuttle/macOS-Defaults
  # Show path bar in finder:
  #   defaults write com.apple.finder ShowPathbar -bool true
  # Cmd-Enter sends email in Mail.

else
  log_skip "Not setting gib macOS defaults."
fi

# Apply any changes made above:

if [[ -n "$dock_changed" ]]; then
  log_debug "Applying expose changes with 'killall Dock' as dock values changed: '$dock_changed'"
  killall Dock
fi

if [[ -n "$finder_changed" ]]; then
  log_debug "Applying AppleShowAllFiles changes with 'killall Finder' as finder values changed '$finder_changed'"
  killall Finder
  open ~
fi

if [[ -n "$menu_changed" ]]; then
  log_debug "Applying menu changes with 'killall SystemUIServer' as menu values changed '$menu_changed'"
  killall SystemUIServer
fi

# Setup spectacle config.
specConfig="$HOME/Library/Application Support/Spectacle/Shortcuts.json"
if [ ! -L "$specConfig" ]; then
  log_get "Overwriting Spectacle shortcuts with link to dot ones."
  mkdir -p "$HOME/.backup"
  [ -e "$specConfig" ] && mv "$specConfig" "$HOME/.backup/Shortcuts.json"
  mkdir -p "$(dirname "$specConfig")"
  ln -s "$XDG_CONFIG_HOME/Spectacle/Shortcuts.json" "$specConfig"
fi

# Set up gpg agent Keychain integration.
# https://stackoverflow.com/questions/39494631/gpg-failed-to-sign-the-data-fatal-failed-to-write-commit-object-git-2-10-0
mkdir -p "${GNUPGHOME:="$XDG_DATA_HOME"/gnupg}"
if grep -q 'pinentry-program /usr/local/bin/pinentry-mac' "$GNUPGHOME"/gpg-agent.conf; then
  log_skip "Pinentry gpg config"
else
  log_get "Pinentry gpg config"
  echo "pinentry-program /usr/local/bin/pinentry-mac" >> "$GNUPGHOME"/gpg-agent.conf
  # Disabling this as it breaks tty use-cases, not sure if needed.
  # grep no-tty "$GNUPGHOME"/gpg.conf || echo "no-tty" >> "$GNUPGHOME"/gpg.conf
fi

# Increase max file watch limit. See http://entrproject.org/limits.html
if [[ -e /Library/LaunchDaemons/limit.maxfiles.plist ]]; then
  log_skip "File watcher limit (already increased)."
else
  log_get "File watcher limit."
  sudo curl -sL http://entrproject.org/etc/limit.maxfiles.plist -o /Library/LaunchDaemons/limit.maxfiles.plist
fi

if [[ -f ~/bin/fix-brew ]]; then
  log_update "Fixing brew permissions."
  ~/bin/fix-brew
fi

# Install brew and Xcode Command Line Tools.
if exists brew; then
  log_skip "brew (already installed)."
else
  log_get "brew."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# Install xcode command line tools (should have already been brew installed).
# If these are messed up run `xcode-select -p`. It will normally print one of:
# - /Library/Developer/CommandLineTools
# - /Applications/Xcode.app/Contents/Developer
if ! xcode-select -p &>/dev/null; then
  log_skip "Xcode Command Line Tools."
  xcode-select --install
else
  log_skip "Xcode Command Line Tools (already installed)."
fi

sogou_dir_old="$(ls -a /usr/local/Caskroom/sogouinput 2>/dev/null || true)"

log_update "Brew update && upgrade"
# Upgrade everything, even things that weren't in your Brewfile.
brew update
brew upgrade
brew cask upgrade # You may occasionally want to run `brew cask upgrade --greedy` in case built-in updaters aren't working.

# brew install things. Edit config/Brewfile to adjust.
brew tap Homebrew/bundle
if [[ $USER == gib ]]; then
  brewfiles=$(ls "$XDG_CONFIG_HOME"/brew/*)
else
  brewfiles=$(ls "$XDG_CONFIG_HOME"/brew/* | grep -v hardcore)
fi
# Replace '\n' with ' ':
brewfiles=${brewfiles//
/ }

if brew bundle --file=<(cat $brewfiles) check >/dev/null; then
  log_skip "brew packages."
else
  log_get "brew packages."
  brew bundle --file=<(cat $brewfiles) | grep -Evx "Using [-_/0-9a-zA-Z ]+"
fi

# Useful to see what you need to add to your Brewfiles.
log_get "Brew packages that would be cleaned up, run this to actually clean:
  brew bundle cleanup --force --file=<(cat $brewfiles)"
brew bundle cleanup --file=<(cat $brewfiles)

sogou_dir_new="$(ls -a /usr/local/Caskroom/sogouinput 2>/dev/null || true)"
# If sogouinput was updated
if [[ "$sogou_dir_old" != "$sogou_dir_new" ]]; then
  log_update  "Sogou Input"
  sogou_dir="$(brew cask info sogouinput | awk '/^\/usr\/local\/Caskroom\/sogouinput\// { print $1 }')"
  [[ -n "$sogou_dir" ]] && open "$sogou_dir"/sogou*.app
fi

export PATH=/usr/local/bin:$PATH
# Install broot symlink.
if [[ ! -e "$XDG_CONFIG_HOME"/zsh/broot.zsh ]]; then
  log_get "broot shell function."
  mkdir -p "$XDG_CONFIG_HOME"/.config/zsh
  broot --print-shell-function zsh >"$XDG_CONFIG_HOME"/zsh/broot.zsh
else
  log_skip "broot shell function."
fi

# Remove the default set of things that are in the dock.
if [[ $USER == gib && -n $(dockutil --list) ]]; then
  log_get "Cleaning Dock"
  dockutil --remove all
else
  log_skip "Cleaning Dock"
fi

if [[ ! -e ~/Library/Containers/com.sindresorhus.Dato/Data/Library/Preferences/com.sindresorhus.Dato.plist ]]; then
  log_get "Setting up dato preferences."
  mkdir -p ~/Library/Containers/com.sindresorhus.Dato/Data/Library/Preferences/
  cp "$dotDir"/config/dato/com.sindresorhus.Dato.plist ~/Library/Containers/com.sindresorhus.Dato/Data/Library/Preferences/com.sindresorhus.Dato.plist
else
  log_skip "Setting up dato preferences."
fi

if [[ -n "$(diff <(plutil -p ~/Library/Containers/com.sindresorhus.Dato/Data/Library/Preferences/com.sindresorhus.Dato.plist | grep -v SS_launchCount) <(plutil -p "$dotDir"/config/dato/com.sindresorhus.Dato.plist | grep -v SS_launchCount))" ]]; then
  log_get "Pulling dato preferences into repo"
  cp ~/Library/Containers/com.sindresorhus.Dato/Data/Library/Preferences/com.sindresorhus.Dato.plist "$dotDir"/config/dato/com.sindresorhus.Dato.plist
  log_info "Changes were:"
  git -C "$dotDir" diff-plist config/dato/com.sindresorhus.Dato.plist
  git -C "$dotDir" reset
  git -C "$dotDir" add config/dato/com.sindresorhus.Dato.plist
  git -C "$dotDir" commit -m 'fix(dato): update preferences file'
else
  log_skip "Pulling dato preferences into repo"
fi

# Allows you to do `locate <name>` to find anywhere in your system.
if [[ -e /var/db/locate.database ]]; then
  log_skip "Enabling updatedb"
else
  log_get "Enabling updatedb"
  sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist
fi

# Swift LanguageServer.
sourcekit_lsp_path="$XDG_DATA_HOME"/sourcekit-lsp
if [[ $USER == gib ]]; then
  changed=$(gitCloneOrUpdate apple/sourcekit-lsp "$sourcekit_lsp_path")
  if [[ -n "$changed" ]]; then
    (cd "$XDG_DATA_HOME"/sourcekit-lsp || error "Failed to cd to the langserver directory"; swift package update && swift build -c release)
    ln -sf "$sourcekit_lsp_path"/.build/release/sourcekit-lsp "$HOME"/bin/sourcekit-lsp
  fi
fi
