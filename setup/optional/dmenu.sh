#!/bin/bash -x
mkdir ~/tmp || true
cd ~/tmp || { echo "Failed to cd"; exit 1; }
sudo apt install -y dmenu
sudo apt install -y cmake make

git clone https://github.com/enkore/j4-dmenu-desktop.git
cd j4-dmenu-desktop || { echo "Failed to cd"; exit 1; }
cmake .
make
sudo make install
