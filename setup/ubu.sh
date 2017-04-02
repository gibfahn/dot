sudo apt install neovim

sudo apt-get -y install libxss1 libappindicator1 libindicator7
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome*.deb || sudo apt-get install -f && sudo dpkg -i google-chrome*.deb
