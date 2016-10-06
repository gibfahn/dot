# Install rustup
curl https://sh.rustup.rs -sSf | sh
# Install stable and nightly
rustup install nightly && rustup install stable
# Download zsh completion
mkdir ~/.zfunc
curl https://raw.githubusercontent.com/rust-lang-nursery/rustup.rs/master/src/rustup-cli/zsh/_rustup >~/.zfunc/_rustup


