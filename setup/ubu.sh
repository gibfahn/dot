sudo apt install -y git curl

sudo add-apt-repository -y ppa:neovim-ppa/stable && sudo apt-get update
sudo apt install -y neovim

sudo apt-get -y install libxss1 libappindicator1 libindicator7
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome*.deb || sudo apt-get install -f && sudo dpkg -i google-chrome*.deb

sudo apt install -y entr
