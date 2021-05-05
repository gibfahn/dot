#!/bin/bash

# shellcheck shell=bash disable=SC1090,SC2016

# Things I like to have on Ubuntu.

set -e

# TODO(gib): Get newer version of less (at least version 520) to fix the -RF bug.

. "$(dirname "$0")/../helpers/setup.sh" # Load helper script from dot/helpers.

hasSudo || exit

# Add all ppas at the same time. Just do the one apt update.
addPPA() {
  local added
  for i in "$@"; do
    if ! grep -q "^deb .*${i#ppa:}" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
      log_get "Adding ppa: $i"
      sudo add-apt-repository -y "$i"
      added="true"
    fi
  done
  [[ -z "$added" ]] || sudo apt -y update
}

addPPA ppa:neovim-ppa/stable ppa:hluk/copyq ppa:git-core/ppa ppa:ubuntu-mozilla-daily/ppa universe

# Apt install things. Added them individually so you can comment out lines to skip.
apt_list=(# List of things to install.
  git            # Get an up-to-date git from the git-core ppa.
  gcc g++        # Should be there already, but make sure.
  curl           # Amazingly some installations don't come with curl.
  zsh            # I use zsh wherever possible.
  tree           # Recursive ls.
  fd-find        # Faster find (installed as fd-find, needs to be aliased).
  ripgrep        # Faster grep.
  gcc make       # Needed to build C/C++ apps from source (and run Makefiles).
  gnome-terminal # Good basic terminal, used in my bspwm config.
  neovim         # Better vim (works well with my vim config.
  copyq          # Clipboard manager with history (needs a bit of manual setup).
  meld           # Graphical diff between folders.
  entr           # Run command on file change (Unixy file/folder watcher).
  xclip          # Copy/paste shell commands, used in gibrc.
  i3             # Window manager. Obsolete since I moved to bspwm.
  dfu-util       # Used for flashing my ergodox.
  scrot          # Take screenshots (works from the command line).
  firefox-trunk  # Nightly (superfast) version of Firefox.
  ccache         # Makes recompilations faster.
  vagrant        # Spin up VMs with the convenience of Docker.
  python3-pip    # pip3 (used for newer python installers). Remove once python3 is default.
  fonts-firacode # Nicer font for your terminal.
  golang-go      # Go programming language.
)

log_get "apt installing/updating: ${apt_list[*]}"
sudo apt install -y "${apt_list[@]}"

if [[ $USER == gib ]] && not bspwm; then
  # Install bspwm dependencies.
  sudo apt install -y xcb libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev libxcb-icccm4-dev \
    libxcb-keysyms1-dev libxcb-xinerama0-dev libasound2-dev libxcb-xtest0-dev
  sudo apt install -y cmake

  # Build bspwm:
  for i in baskerville/{bspwm,sxhkd,xdo,sutils,xtitle} LemonBoy/bar; do
    gitClone $i "$BUILD_DIR/$i"
    pushd "$BUILD_DIR/$i" >/dev/null || {
      echo "Failed to cd"
      exit 1
    }
    make
    sudo make install
    popd >/dev/null || {
      echo "Failed to cd"
      exit 1
    }
  done
  sudo cp "$BUILD_DIR/baskerville/bspwm/contrib/freedesktop/bspwm.desktop" /usr/share/xsessions/
  cp "$BUILD_DIR"/baskerville/bspwm/examples/panel/panel{,_bar,_colors} "$BIN_DIR"
fi

# Build j4-dmenu-desktop (used in bspwm).
if [[ $USER == gib ]] && not j4-dmenu-desktop; then
  # This is an extension for dmenu, so make sure we have that.
  sudo apt install -y dmenu
  mkdir -p "$BUILD_DIR"
  gitClone enkore/j4-dmenu-desktop "$BUILD_DIR/j4-dmenu-desktop"
  pushd "$BUILD_DIR/j4-dmenu-desktop" >/dev/null || {
    echo "Failed to cd"
    exit 1
  }
  cmake .
  make
  sudo make install
  popd >/dev/null || {
    echo "Failed to cd"
    exit 1
  }
fi

# Change default version of gpg to gpg2 (which Ubuntu should be doing soon, it's
# in Debian Stretch). Don't do anything unless we're sure.
gpgVersion=$(gpg --version | head -1 | awk '{print $NF}')
if [[ ${gpgVersion%%.*} == 1 ]] && exists gpg2 \
  && [[ "$(command -v gpg)" = /usr/bin/gpg && "$(command -v gpg2)" = /usr/bin/gpg2 ]]; then
  log_get "Setting default gpg to gpg2 not gpg1"
  sudo mv /usr/bin/gpg /usr/bin/gpg1
  sudo update-alternatives --verbose --install /usr/bin/gpg gnupg /usr/bin/gpg2 50
else
  log_skip "Setting gpg2 as default (not messing with default)"
fi

if not google-chrome; then
  sudo apt install -y libxss1 libappindicator1 libindicator7
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo dpkg -i google-chrome-stable_current_amd64.deb || sudo apt-get install -f && sudo dpkg -i google-chrome-stable_current_amd64.deb
  rm google-chrome-stable_current_amd64.deb
fi

if [[ $USER == gib ]] && not slack; then
  echo "deb https://packagecloud.io/slacktechnologies/slack/debian/ jessie main" | sudo tee /etc/apt/sources.list.d/slack.list >/dev/null
  sudo apt install -y slack
fi

sudo apt -y update \
  && sudo apt -y upgrade \
  && sudo apt -y autoremove --purge

# Make Ctrl-[Shift]-Tab switch tabs in Gnome-Terminal, rather than Ctrl-PgUp/PgDn.
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ next-tab '<Primary>Tab'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ prev-tab '<Primary><Shift>Tab'
# TODO(gib): Add setting to make gnome-terminal use the FiraCode font (installed above).

XKB=/usr/share/X11/xkb/
if [[ $USER == gib && ! -d "$XKB".git ]]; then # Set up xkb key remapping.
  log_get "Setting up personal xkb shortcuts at $XKB."
  sudo chown -R "$USER:$(id -gn)" "$XKB"
  pushd /usr/share/X11/xkb || {
    echo "Failed to cd"
    exit 1
  }
  git init
  git remote add up git@github.com:gibfahn/xkb.git
  git fetch --all
  git reset up/master
  if [ "$(git status --porcelain)" ]; then
    echo "ERROR: $XKB didn't match git version, resolve manually!"
    echo 'Fix conflicts then do: `git checkout gibLayout; sudo dpkg-reconfigure xkb-data`'
    exit 1
  fi
  git checkout gibLayout
  sudo dpkg-reconfigure xkb-data
else
  log_skip "Not setting up personal xkb shortcuts (user != gib or non-standard xkb dir)."
fi
