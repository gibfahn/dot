#!/bin/bash -x
cd ~
mkdir tmp || true
cd tmp
sudo apt install -y dmenu
sudo apt install -y cmake make

git clone https://github.com/enkore/j4-dmenu-desktop.git
cd j4-dmenu-desktop
cmake .
make
sudo make install
