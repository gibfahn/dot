#!/bin/bash -e

# Things I like to have on Ubuntu.

. $(dirname $0)/../helpers/setup.sh # Load helper script from gcfg/helpers.

hasSudo || exit

# Add all ppas at the same time. Just do the one apt update.
addAptRepo() {
  for i in $@; do
    if ! grep -q "^deb .*$i" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
      sudo add-apt-repository -y "$i"
    fi
  done
  sudo apt update
}

addAptRepo ppa:neovim-ppa/stable ppa:hluk/copyq ppa:git-core/ppa

# Apt install things. Added them individually so you can comment out lines to skip.
list=""                               # List of things to install.
list+=" git"                          # Get an up-to-date git from the git-core ppa.
list+=" curl"                         # Amazingly some installaions don't come with curl.
list+=" zsh"                          # I use zsh wherever possible.
list+=" tree"                         # Recursive ls.
list+=" gcc make"                     # Needed to build C/C++ apps from source (and run Makefiles).
list+=" gnome-terminal"               # Good basic terminal, used in my bspwm config.
list+=" neovim"                       # Better vim (works well with my vim config.
list+=" copyq"                        # Clipboard manager with history (needs a bit of manual setup).
list+=" meld"                         # Graphical diff between folders.
list+=" entr"                         # Run command on file change (Unixy file/folder watcher).
list+=" xclip"                        # Copy/paste shell commands, used in gcfg.
list+=" tig"                          # Some nice additions to git (e.g. `tig log`).
list+=" i3"                           # Window manager. Obsolete since I moved to bspwm.
list+=" dfu-util"                     # Used for flashing my ergodox.
list+=" ccache"                       # Makes recompilations faster.
echo "❯❯❯ apt installing/updating: $list"
sudo apt install -y $list

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
