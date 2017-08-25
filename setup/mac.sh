#!/bin/bash -e

# Things I like to have on a Mac.

. $(dirname $0)/../helpers/setup.sh # Load helper script from gcfg/helpers.

hasSudo || exit

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
  echo "❯❯❯ Installing: brew"
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Install brew
if brew info brew-cask &>/dev/null; then
  echo "❯❯❯ Already Installed: brew cask"
else
  echo "❯❯❯ Installing: brew cask"
  # Install cask (brew for GUI utils)
  brew tap caskroom/cask
fi

# brew install things. Added them individually so you can comment out lines to skip.
list=""                               # List of things to install.
list+=" bash"                         # Bash on macOS is old, get an up-to-date version.
list+=" zsh"                          # Doesn't come by default amazingly.
list+=" git"                          # Get an up-to-date git.
list+=" rmtrash"                      # Like `rm`, but moves to trash (aliased to `dl` in gcfg).
list+=" gnu-sed gnu-tar gnu-which"    # Get GNU versions of tools (no more weird sed without -i).
list+=" binutils coreutils findutils" # More GNU tools.
list+=" htop perl wget"               # Couple more GNU tools.
list+=" tree"                         # Recursive ls.
list+=" neovim"                       # Better vim (works well with my vim config.
list+=" entr"                         # Run command on file change (Unixy file/folder watcher).
list+=" tig"                          # Some nice additions to git (e.g. `tig log`).
list+=" ctags"                        # Used for IDE autocomplete.
list+=" dfu-util"                     # Used for flashing my ergodox.
list+=" ninja"                        # Superfast build system (used in Node.js).
list+=" python python3"               # Up-to-date python.
list+=" ccache"                       # Makes recompilations faster.
list+=" gdb"                          # GNU debugger.
list+=" kubernetes-cli"               # Kubernetes docker cluster manager.
list+=" kubernetes-helm"              # helm docker cluster package manager.
echo "❯❯❯ brew installing/updating: $list"
brew install $list

brew tap crisidev/homebrew-chunkwm
brew install chunkwm
brew services start chunkwm
brew install koekeishiya/formulae/khd
brew services start khd

# brew cask install things. Added individually so you can comment out lines to skip.
list=""                               # List of things to install.
list+=" google-chrome"                # Bash on macOS is old, get an up-to-date version.
list+=" firefox-nightly"              # Has some really cool new features (and speed).
list+=" meld"                         # Graphical diff between folders.
list+=" gpgtools"                     # Like `rm`, but moves to trash (aliased to `dl` in gcfg).
list+=" docker vagrant virtualbox"    # Get docker and related tools.
list+=" hammerspoon"                  # Lua scripting to automate anything.
list+=" copyq"                        # Clipboard manager with history (needs a bit of manual setup).
echo "❯❯❯ brew cask installing/updating: $list"
brew cask install $list
