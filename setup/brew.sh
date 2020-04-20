#!/usr/bin/env bash

. "$(dirname "$0")/../helpers/setup.sh" # Load helper script from dot/helpers.

set -ex

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

