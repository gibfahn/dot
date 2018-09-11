#!/bin/bash

# Things I like to have on a Mac.

. $(dirname $0)/../helpers/setup.sh # Load helper script from dot/helpers.

if ! cat ~/Library/Preferences/com.apple.Terminal.plist | grep -q gib; then
  get "gib Terminal profile."
  # Install my terminal profile.
  open $(dirname $0)/config/gib.terminal

  # Change the default to my profile (swap it back in settings if you want).
  if [[ "$(defaults read com.apple.Terminal "Default Window Settings")" != gib ]]; then
    defaults write com.apple.Terminal "Default Window Settings" gib
  fi
else
  skip "gib Terminal profile (already installed)."
fi

# Link VS Code preferences into the macOS specific folder.
if [[ -d "$HOME/Library/Application Support/Code/" ]]; then
  for file in "$HOME"/.config/code/*.json; do
    ln -sf "$file" "$HOME/Library/Application Support/Code/User/$(basename "$file")"
  done
fi

# Install xcode command line tools
if ! xcode-select -p &>/dev/null; then
  skip "Xcode Command Line Tools."
  xcode-select --install
else
  skip "Xcode Command Line Tools (already installed)."
fi

if [ "$HARDCORE" ]; then # Set keyboard preferences.
  get "Setting keyboard/trackpad preferences."

  # Set Keyboard Shortcuts -> App Shortcuts
  # To add your own, first add them in System Preferences -> Keyboard ->
  # Shortcuts -> App Shortcuts, then find them in the output of:
  #   defaults read
  # Use the existing and the help output of `defaults` to work it out.
  # @command, ~option, ^ctrl, $shift

  # Create global shortcut "Merge all windows" ⌘-M
  if ! defaults read 'Apple Global Domain' NSUserKeyEquivalents | grep -q "Merge All Windows"; then
    defaults write 'Apple Global Domain' NSUserKeyEquivalents -dict-add "Merge All Windows" '@$m'
  fi

  # Remove ⌘-h as a Hide Window shortcut in relevant apps.
  # -> IntelliJ Community Edition:
  if ! defaults read com.jetbrains.intellij.ce NSUserKeyEquivalents | grep -q "Hide IntelliJ IDEA"; then
    defaults write com.jetbrains.intellij.ce NSUserKeyEquivalents -dict-add "Hide IntelliJ IDEA" '@~^\\U00a7'
  fi
  # -> IntelliJ:
  if ! defaults read com.jetbrains.intellij NSUserKeyEquivalents | grep -q "Hide IntelliJ IDEA"; then
    defaults write com.jetbrains.intellij NSUserKeyEquivalents -dict-add "Hide IntelliJ IDEA" '@~^\\U00a7'
  fi
  # -> Kitty:
  if ! defaults read net.kovidgoyal.kitty NSUserKeyEquivalents | grep -q "Hide kitty"; then
    defaults write net.kovidgoyal.kitty NSUserKeyEquivalents -dict-add "Hide kitty" '~^$\\U00a7'
  fi
  # -> Mail: ⌘-backspace moves to Archive.
  if ! defaults read com.apple.mail NSUserKeyEquivalents | grep -q "Archive"; then
    defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Archive" '@\U0008'
  fi

  # Set up fastest key repeat rate (needs relogin).
  if [[ "$(defaults read NSGlobalDomain KeyRepeat)" != 1 ]]; then
    defaults write NSGlobalDomain KeyRepeat -int 1
  fi

  # Sets a low time before key starts repeating.
  if [[ "$(defaults read NSGlobalDomain InitialKeyRepeat)" != 8 ]]; then
    defaults write NSGlobalDomain InitialKeyRepeat -int 8
  fi

  # Increases trackpad sensitivity (SysPref max 3.0).
  if [[ "$(defaults read -g com.apple.trackpad.scaling)" != 5 ]]; then
    defaults write -g com.apple.trackpad.scaling -float 5.0
  fi

  # Disables window minimizing animations.
  if [[ "$(defaults read NSGlobalDomain NSAutomaticWindowAnimationsEnabled)" != 0 ]]; then
    defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -int 0
  fi

  # Greys out hidden apps in the dock (so you can see which are hidden).
  if [[ "$(defaults read com.apple.Dock showhidden)" != 1 ]]; then
    defaults write com.apple.Dock showhidden -int 1 && killall Dock
  fi

  # System Preferences -> Keyboard -> Shortcuts -> Full Keyboard Access
  # Full Keyboard Access: In Windows and Dialogs, press Tab to move keyboard
  # focus between:
  #   0: Text Boxes and Lists only
  #   2: All controls
  # Set it to 2 because that's much nicer (you can close confirmation prompts
  # with the keyboard, Enter to press the blue one, tab to select between them,
  # space to press the Tab-selected one. If there are underlined letters, hold
  # Option and press the letter to choose that option.
  if [[ "$(defaults read -g AppleKeyboardUIMode)" != 2 ]]; then
    defaults write -g AppleKeyboardUIMode -int 2
  fi

  # Show hidden files in the finder.
  if [[ "$(defaults read com.apple.finder AppleShowAllFiles)" != 1 ]]; then
    defaults write com.apple.finder AppleShowAllFiles -int 1 && killall Finder
  fi

  # Allow text selection in any QuickLook window.
  if [[ "$(defaults read -g QLEnableTextSelection)" != 1 ]]; then
    defaults write -g QLEnableTextSelection -int 1
  fi

  # Allow Finder to be quit (hides Desktop files).
  if [[ "$(defaults read com.apple.finder QuitMenuItem)" != 1 ]]; then
    defaults write com.apple.finder QuitMenuItem -bool YES
    killall Finder
    open ~
  fi

  # Show system info at the login screen when you click the clock icon.
  if [[ "$(defaults read /Library/Preferences/com.apple.loginwindow AdminHostInfo)" != HostName ]]; then
    sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName
  fi

  # Disable the animations for opening Quick Look windows
  if [[ "$(defaults read -g QLPanelAnimationDuration)" != 0 ]]; then
    defaults write -g QLPanelAnimationDuration -float 0
  fi

  # System Preferences > General > Click in the scrollbar to: Jump to the spot that's clicked
  if [[ "$(defaults read -g AppleScrollerPagingBehavior)" != 1 ]]; then
    defaults write -globalDomain AppleScrollerPagingBehavior -int 1
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
  #   defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" "@\U21a9"

else
  skip "Not setting keyboard/trackpad preferences (HARDCORE not set)."
  # You can still change them in System Preferences/{Trackpad,Keyboard}.
fi

# Setup spectacle config.
specConfig="$HOME/Library/Application Support/Spectacle/Shortcuts.json"
if [ ! -L "$specConfig" ]; then
  get "Overwriting Spectacle shortcuts with link to dot ones."
  mkdir -p "$HOME/.backup"
  [ -e "$specConfig" ] && mv "$specConfig" "$HOME/.backup/Shortcuts.json"
  ln -s "$XDG_CONFIG_HOME/Spectacle/Shortcuts.json" "$specConfig"
fi

# Increase max file watch limit. See http://entrproject.org/limits.html
if [[ -e /Library/LaunchDaemons/limit.maxfiles.plist ]]; then
  skip "File watcher limit (already increased)."
else
  get "File watcher limit."
  sudo curl -sL http://entrproject.org/etc/limit.maxfiles.plist -o /Library/LaunchDaemons/limit.maxfiles.plist
fi

# Install brew
if exists brew; then
  skip "brew (already installed)."
else
  get "brew."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# brew install things. Edit config/Brewfile to adjust.
get "brew installing/updating."
brew tap Homebrew/bundle
brew bundle --file=$(dirname $0)/config/Brewfile | grep -Evx "Using [-_/0-9a-zA-Z]+"

if [ "$HARDCORE" ]; then # Set up HARDCORE brew packages.
  get "brew HARDCORE packages."
  brew bundle --file=$(dirname $0)/config/Brewfile-hardcore | grep -Evx "Using [-_/0-9a-zA-Z]+"
else
  skip "brew HARDCORE packages (HARDCORE not specified)."
fi

# Upgrade everything, even things that weren't in your Brewfile.
brew upgrade
brew cask upgrade # You may occasionally want to run `brew cask upgrade --greedy` in case built-in updaters aren't working.

# Update Mac App Store apps.
softwareupdate -i -a

if not langserver-swift && ! not swift; then
  gitClone rlovelett/langserver-swift "$HOME"/bin/src/langserver-swift
  (cd "$HOME/bin/src/langserver-swift"; make release)
  ln -s "$HOME/bin/src/langserver-swift/.build/$(uname -m)"-*/release/langserver-swift "$HOME"/bin/langserver-swift
fi
