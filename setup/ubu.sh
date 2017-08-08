#!/bin/bash -e

# Things I like to have on Ubuntu.

. $(dirname $0)/../helpers/setup.sh # Load helper script from gcfg/helpers.

hasSudo || exit

sudo apt install -y git curl zsh tree
sudo apt install -y gnome-terminal # Used as default in config.
sudo apt install -y gcc make

# Add all ppas at the same time. Just do the one apt update.
! exists nvim && sudo add-apt-repository -y ppa:neovim-ppa/stable && sudo apt update
! exists copyq && sudo add-apt-repository -y ppa:hluk/copyq && sudo apt update

sudo apt install -y neovim # Nicer version of vim.
sudo apt install -y copyq # Cross-platform clipboard manager.
sudo apt install -y entr # Run command on file change.

sudo apt install i3 # I think I'll be using bspwm going forward, so this is legacy.

if not bspwm; then
  # Install bspwm dependencies.
  sudo apt install -y xcb libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-xinerama0-dev libasound2-dev libxcb-xtest0-dev
  sudo apt install -y cmake

  # Build bspwm:
  for i in baskerville/{bspwm,sxhkd,xdo,sutils,xtitle} LemonBoy/bar; do
    gitClone $i "$BUILD_DIR/$i"
    pushd "$BUILD_DIR/$i" >/dev/null
    make
    sudo make install
    popd >/dev/null
  done
  sudo cp "$BUILD_DIR/baskerville/bspwm/contrib/freedesktop/bspwm.desktop" /usr/share/xsessions/
  cp "$BUILD_DIR"/baskerville/bspwm/examples/panel/panel{,_bar,_colors} "$BIN_DIR"
fi

# Build j4-dmenu-desktop (used in bspwm).
if not j4-dmenu-desktop; then
  # This is an extension for dmenu, so make sure we have that.
  sudo apt install -y dmenu
  mkdir -p "$BUILD_DIR"
  gitClone enkore/j4-dmenu-desktop "$BUILD_DIR/j4-dmenu-desktop"
  pushd "$BUILD_DIR/j4-dmenu-desktop" >/dev/null
  cmake .
  make
  sudo make install
  popd >/dev/null
fi

if exists google-chrome; then
  echo "❯❯❯ Already Installed: Google Chrome"
else
  echo "❯❯❯ Installing: Google Chrome"
  sudo apt install -y libxss1 libappindicator1 libindicator7
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo dpkg -i google-chrome-stable_current_amd64.deb || sudo apt-get install -f && sudo dpkg -i google-chrome-stable_current_amd64.deb
  rm google-chrome-stable_current_amd64.deb
fi
