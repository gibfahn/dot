#!/bin/bash

# Things I like to have on Ubuntu.

$(dirname $0)/helpers.sh # Load my helper functions from this script's directory.

if sudo -v; then
  echo "❯❯❯ Installing ubuntu packages with apt"
else
  echo "❯❯❯ User doesn't have sudo, skipping apt installs"
  exit
fi

sudo add-apt-repository
sudo apt install -y git curl zsh
sudo apt install -y gnome-terminal i3 # I use gnome-terminal in $c/i3/config

sudo add-apt-repository -y ppa:neovim-ppa/stable && sudo apt-get update
sudo apt install -y neovim # Nicer version of vim.
sudo apt install -y entr # Run command on file change.

if exists google-chrome; then
  echo "❯❯❯ Already Installed: Google Chrome"
else
  echo "❯❯❯ Installing: Google Chrome"
  sudo apt install -y libxss1 libappindicator1 libindicator7
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo dpkg -i google-chrome-stable_current_amd64.deb || sudo apt-get install -f && sudo dpkg -i google-chrome-stable_current_amd64.deb
  rm google-chrome-stable_current_amd64.deb
fi
