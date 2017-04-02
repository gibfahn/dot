# Set default shell to zsh
chsh -s /bin/zsh

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Use nvm
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash
nvm install stable

mkdir -p ~/.zfunc

# Autocompletion for npm (probably needed)
npm completion > ~/.zfunc/_npm

# Install rustup
curl https://sh.rustup.rs -sSf | sh
# Install stable and nightly
rustup install nightly && rustup install stable
# Download zsh completion
curl https://raw.githubusercontent.com/rust-lang-nursery/rustup.rs/master/src/rustup-cli/zsh/_rustup >~/.zfunc/_rustup

