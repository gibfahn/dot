#!/bin/bash

# Things I like to have on a Mac.

. $(dirname $0)/helpers.sh # Load my helper functions from this script's directory.

if sudo -v; then
  echo "❯❯❯ Installing mac packages with brew"
else
  echo "❯❯❯ User doesn't have sudo, skipping brew installs"
  exit
fi

# Install xcode command line tools
echo "❯❯❯ Installing xcode command line tools"
xcode-select --install

echo "❯❯❯ Set key preferences"
# Set up fastest key repeat rate (needs relogin).
defaults write NSGlobalDomain KeyRepeat -int 1
# Sets a low time before key starts repeating.
defaults write NSGlobalDomain InitialKeyRepeat -int 8
# Increases trackpad sensitivity (SysPref max 3.0).
defaults write -g com.apple.trackpad.scaling -float 5.0

# Tell Hammerspoon to use $XDG_CONFIG_HOME.
defaults write org.hammerspoon.Hammerspoon MJConfigFile "$XDG_CONFIG_HOME/hammerspoon/init.lua"

# Install brew
if exists brew; then
  echo "❯❯❯ Already Installed: brew"
else
  echo "❯❯❯ Installing: brew and cask"
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  # Install cask (brew for GUI utils)
  brew tap caskroom/cask
fi

# Brew stuff
echo "❯❯❯ Use brew to install a bunch of stuff"
brew install bash zsh git rmtrash # rmtrash = move to trash

brew tap crisidev/homebrew-chunkwm
brew install chunkwm
brew services start chunkwm
brew install koekeishiya/formulae/khd
brew services start khd

brew install entr # Run command on file change
brew install gnu-sed gnu-tar gnu-which htop perl tree wget # GNU tools (no more weird sed).
brew install binutils coreutils findutils neovim tig zsh ctags
brew install dfu-util # Ergodox file uploader.
brew install ninja python python3 ccache gdb # Build utilities
# brew install fzf # Fuzzy finder used in vim
# brew install exercism # Am I still doing this?
# brew install mongodb redis postgresql # Not sure if I'll need these

# Brew cask stuff
brew cask install google-chrome firefox meld
brew cask install gpgtools
brew cask install docker vagrant virtualbox
brew cask install hammerspoon # Did I even do lua scripting?
