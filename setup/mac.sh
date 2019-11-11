#!/bin/bash
# shellcheck shell=bash disable=SC1090,SC2016

# Things I like to have on a Mac.

. "$(dirname "$0")/../helpers/setup.sh" # Load helper script from dot/helpers.

if ! grep -q gib ~/Library/Preferences/com.apple.Terminal.plist; then
  log_get "gib Terminal profile."
  # Install my terminal profile.
  open "$(dirname "$0")/config/gib.terminal"

  # Change the default to my profile (swap it back in settings if you want).
  if [[ "$(defaults read com.apple.Terminal "Default Window Settings")" != gib ]]; then
    defaults write com.apple.Terminal "Default Window Settings" gib
  fi
else
  log_skip "gib Terminal profile (already installed)."
fi

# Link VS Code preferences into the macOS specific folder.
if [[ -d "$HOME/Library/Application Support/Code/" ]]; then
  for file in "$HOME"/.config/code/*.json; do
    ln -sf "$file" "$HOME/Library/Application Support/Code/User/$(basename "$file")"
  done
fi

# Install xcode command line tools
# If these are messed up run `xcode-select -p`. It will normally print one of:
# - /Library/Developer/CommandLineTools
# - /Applications/Xcode.app/Contents/Developer
if ! xcode-select -p &>/dev/null; then
  log_skip "Xcode Command Line Tools."
  xcode-select --install
else
  log_skip "Xcode Command Line Tools (already installed)."
fi

if [ "$HARDCORE" ]; then # Set keyboard preferences.
  log_section "Setting macOS defaults."

  # Set Keyboard Shortcuts -> App Shortcuts
  # To add your own, first add them in System Preferences -> Keyboard ->
  # Shortcuts -> App Shortcuts, then find them in the output of:
  #   defaults find NSUserKeyEquivalents
  # Use the existing and the help output of `defaults` to work it out.
  #   @command, ~option, ^ctrl, $shift
  # The global domain NSGlobalDomain NSGlobalDomain is the same as -g or -globalDomain.
  # -bool YES/TRUE or FALSE/NO correspond to -int 1 or 0.
  # You can view plist files with /usr/libexec/PlistBuddy

  # Make user keyboard layout the default layout on login (maybe dangerous):
  #   sudo cp ~/Library/Preferences/com.apple.HIToolbox.plist /Library/Preferences/com.apple.HIToolbox.plist
  #   sudo chmod 644 /Library/Preferences/com.apple.HIToolbox.plist

  # Create global shortcut "Merge all windows" ⌘-M
  updateMacOSKeyboardShortcut NSGlobalDomain "Merge All Windows" '@$m'

  # Remove ⌘-h as a Hide Window shortcut in relevant apps.
  # -> IntelliJ Community Edition:
  # Removed because I haven't installed it.
  # updateMacOSKeyboardShortcut com.jetbrains.intellij.ce "Hide IntelliJ IDEA" '@~^\\U00a7'
  # -> IntelliJ:
  updateMacOSKeyboardShortcut com.jetbrains.intellij "Hide IntelliJ IDEA" '~^$\\U00a7'
  # -> Kitty:
  updateMacOSKeyboardShortcut net.kovidgoyal.kitty "Hide kitty" '~^$\\U00a7'
  # -> Mail: ⌘-backspace moves to Archive.
  updateMacOSKeyboardShortcut com.apple.mail "Archive" '@\\b'
  # -> Mail: ⌘-Enter sends the message.
  updateMacOSKeyboardShortcut com.apple.mail "Send" '@\\U21a9'

  # Radar: Ctrl-Alt-C copies as Markdown:
  updateMacOSKeyboardShortcut com.apple.ist.Radar7 "Copy as Markdown" "~^c"

  # Set up fastest key repeat rate (needs relogin).
  updateMacOSDefault NSGlobalDomain KeyRepeat -int 1

  # Sets a low time before key starts repeating.
  updateMacOSDefault NSGlobalDomain InitialKeyRepeat -int 8

  # Increases trackpad sensitivity (SysPref max 3.0).
  updateMacOSDefault NSGlobalDomain com.apple.trackpad.scaling -float 5

  # Increases trackpad sensitivity (SysPref max 3.0).
  updateMacOSDefault NSGlobalDomain com.apple.trackpad.forceClick -int 0

  # Unnatural scrolling direction (swipe down to scroll down).
  updateMacOSDefault NSGlobalDomain com.apple.swipescrolldirection -int 0

  # Expand save panel by default
  updateMacOSDefault NSGlobalDomain NSNavPanelExpandedStateForSaveMode -int 1
  updateMacOSDefault NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -int 1

  # Disable the “Are you sure you want to open this application?” dialog
  updateMacOSDefault com.apple.LaunchServices LSQuarantine -int 0

  # Expand print panel by default
  updateMacOSDefault NSGlobalDomain PMPrintingExpandedStateForPrint -int 1
  updateMacOSDefault NSGlobalDomain PMPrintingExpandedStateForPrint2 -int 1

  # Disables window minimizing animations.
  updateMacOSDefault NSGlobalDomain NSAutomaticWindowAnimationsEnabled -int 0

  # Always open new things in tabs (not new windows) for document based apps.
  updateMacOSDefault NSGlobalDomain AppleWindowTabbingMode -string always

  # Maximise window when you double-click on the title bar.
  updateMacOSDefault NSGlobalDomain AppleActionOnDoubleClick -string Maximize

  # Use Dark mode.
  updateMacOSDefault NSGlobalDomain AppleInterfaceStyle -string Dark

  # Auto-hide menu bar.
  updateMacOSDefault NSGlobalDomain _HIHideMenuBar -int 1
  # Auto-hide dock.
  updateMacOSDefault com.apple.dock autohide -int 1
  # Don't show recents in dock.
  updateMacOSDefault com.apple.dock show-recents -int 0

  # Greys out hidden apps in the dock (so you can see which are hidden).
  updateMacOSDefault com.apple.Dock showhidden -int 1 && killall Dock

  # System Preferences -> Keyboard -> Shortcuts -> Full Keyboard Access
  # Full Keyboard Access: In Windows and Dialogs, press Tab to move keyboard
  # focus between:
  #   0: Text Boxes and Lists only
  #   2: All controls
  # Set it to 2 because that's much nicer (you can close confirmation prompts
  # with the keyboard, Enter to press the blue one, tab to select between them,
  # space to press the Tab-selected one. If there are underlined letters, hold
  # Option and press the letter to choose that option.
  updateMacOSDefault NSGlobalDomain AppleKeyboardUIMode -int 2

  # Show hidden files in the finder.
  oldFinderValue="$(defaults read com.apple.finder QuitMenuItem)"
  updateMacOSDefault com.apple.finder AppleShowAllFiles -int 1
  if [[ "$oldFinderValue" != 1 ]]; then
    killall Finder
    open ~
  fi

  # Finder: show all filename extensions
  updateMacOSDefault NSGlobalDomain AppleShowAllExtensions -int 1

  # Display full POSIX path as Finder window title
  updateMacOSDefault com.apple.finder _FXShowPosixPathInTitle -int 1

  # Use list view in all Finder windows by default
  # Four-letter codes for the other view modes: `icnv`, `clmv`, `glyv`
  updateMacOSDefault com.apple.finder FXPreferredViewStyle -string "Nlsv"

  # Allow text selection in any QuickLook window.
  updateMacOSDefault NSGlobalDomain QLEnableTextSelection -int 1

  # Allow Finder to be quit (hides Desktop files).
  oldFinderValue="$(defaults read com.apple.finder QuitMenuItem)"
  updateMacOSDefault com.apple.finder QuitMenuItem -int 1
  if [[ "$oldFinderValue" != 1 ]]; then
    killall Finder
    open ~
  fi

  # Disable the animations for opening Quick Look windows
  updateMacOSDefault NSGlobalDomain QLPanelAnimationDuration -float 0

  # System Preferences > General > Click in the scrollbar to: Jump to the spot that's clicked
  updateMacOSDefault NSGlobalDomain AppleScrollerPagingBehavior -int 1

  # Set sidebar icon size to medium
  updateMacOSDefault NSGlobalDomain NSTableViewDefaultSizeMode -int 2

  # Show developer options in Radar 8.
  updateMacOSDefault com.apple.radar.gm shouldShowDeveloperOptions -int 1

  # Show all processes in Activity Monitor
  updateMacOSDefault com.apple.ActivityMonitor ShowCategory -int 0

  spotlight_preferences=(
    '{"enabled" = 1;"name" = "APPLICATIONS";}'
    '{"enabled" = 1;"name" = "MENU_EXPRESSION";}'
    '{"enabled" = 1;"name" = "MENU_DEFINITION";}'
    '{"enabled" = 0;"name" = "SYSTEM_PREFS";}'
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
    '{"enabled" = 0;"name" = "MENU_CONVERSION";}'
    '{"enabled" = 0;"name" = "MENU_WEBSEARCH";}'
    '{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}'
  )

  existing_spotlight_preferences=$(defaults read com.apple.Spotlight orderedItems | tr -d '\n' | tr -d ' ' | tr -d ',' | tr -d '"')
  trimmed_expected_spotlight_preferences=$(printf "(${spotlight_preferences[*]})" | tr -d ' ' | tr -d '"')
  if  [[ $existing_spotlight_preferences == $trimmed_expected_spotlight_preferences ]]; then
    log_skip "macOS default Spotlight Preferences"
  else
    log_get "macOS default Spotlight Preferences"

    # Change indexing order and disable some search results
    defaults write com.apple.Spotlight orderedItems -array "${spotlight_preferences[@]}"

    # Load new settings before rebuilding the index
    killall mds > /dev/null 2>&1
    # Make sure indexing is enabled for the main volume
    sudo mdutil -i on / > /dev/null
    # Rebuild the index from scratch
    sudo mdutil -E / > /dev/null
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
  log_skip "Not setting macOS defaults (HARDCORE not set)."
  # You can still change them in System Preferences/{Trackpad,Keyboard}.
fi

# Setup spectacle config.
specConfig="$HOME/Library/Application Support/Spectacle/Shortcuts.json"
if [ ! -L "$specConfig" ]; then
  log_get "Overwriting Spectacle shortcuts with link to dot ones."
  mkdir -p "$HOME/.backup"
  [ -e "$specConfig" ] && mv "$specConfig" "$HOME/.backup/Shortcuts.json"
  mkdir -p "$XDG_CONFIG_HOME"/Spectacle
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

# Install brew
if exists brew; then
  log_skip "brew (already installed)."
else
  log_get "brew."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

sogou_dir_old="$(ls -a /usr/local/Caskroom/sogouinput 2>/dev/null || true)"

# brew install things. Edit config/Brewfile to adjust.
brew tap Homebrew/bundle
if brew bundle --file="$(dirname "$0")"/config/Brewfile check >/dev/null; then
  log_skip "brew packages."
else
  log_get "brew packages."
  brew bundle --file="$(dirname "$0")"/config/Brewfile | grep -Evx "Using [-_/0-9a-zA-Z ]+"
fi

# Set up HARDCORE brew packages.
if [[ -e "$HARDCORE" ]] && ! brew bundle --file="$(dirname "$0")"/config/Brewfile-hardcore check >/dev/null; then
  log_get "brew HARDCORE packages."
  brew bundle --file="$(dirname "$0")"/config/Brewfile-hardcore | grep -Evx "Using [-_/0-9a-zA-Z ]+"
else
  log_skip "brew HARDCORE packages."
fi

# Upgrade everything, even things that weren't in your Brewfile.
brew upgrade
brew cask upgrade # You may occasionally want to run `brew cask upgrade --greedy` in case built-in updaters aren't working.

sogou_dir_new="$(ls -a /usr/local/Caskroom/sogouinput 2>/dev/null || true)"
# If sogouinput was updated
if [[ "$sogou_dir_old" != "$sogou_dir_new" ]]; then
  log_update  "Sogou Input"
  sogou_dir="$(brew cask info sogouinput | awk '/^\/usr\/local\/Caskroom\/sogouinput\// { print $1 }')"
  [[ -n "$sogou_dir" ]] && open "$sogou_dir"/sogou*.app
fi

# Update Mac App Store apps.
softwareupdate --install --all || log_skip "To autorestart run:
sudo softwareupdate --install --all --restart"

# Swift LanguageServer.
sourcekit_lsp_path="$XDG_DATA_HOME"/sourcekit-lsp
gitCloneOrUpdate apple/sourcekit-lsp "$sourcekit_lsp_path" && {
  (cd "$XDG_DATA_HOME"/sourcekit-lsp || error "Failed to cd to the langserver directory"; swift package update && swift build -c release)
  ln -sf "$sourcekit_lsp_path"/.build/release/sourcekit-lsp "$HOME"/bin/sourcekit-lsp
}
