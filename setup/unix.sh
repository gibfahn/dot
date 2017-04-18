# Set default shell to zsh
if [ "${SHELL##*/}" != "zsh" ]; then
  echo "❯❯❯ Current shell is $SHELL, changing to /bin/zsh"
  chsh -s /bin/zsh
fi

no() { # Do we need to install $1?
  if [ ! -e "$XDG_DATA_HOME/$1" ]; then
    echo "❯❯❯ Installing: $1"
    return 0 # Directory is missing.
  else
    echo "❯❯❯ Already Installed : $1"
    return 1 # Directory not missing.
  fi
}


# Install oh-my-zsh:
if no oh-my-zsh; then
  ZSH="$XDG_DATA_HOME/oh-my-zsh" sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

## Install zplug: Disabled as slowed down zsh.
#if no zplug; then
#  git clone https://github.com/zplug/zplug "$XDG_DATA_HOME/zplug"
#fi

# Set up autocompletions:
if no zfunc; then
  mkdir -p "$XDG_DATA_HOME/zfunc"
fi

# Set up zsh scripts:
if no zsh; then
  mkdir -p "$XDG_DATA_HOME/zsh"
fi

if no zsh/zsh-syntax-highlighting; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$XDG_DATA_HOME/zsh/zsh-syntax-highlighting"
fi


# Install nvm:
if no nvm; then
  export NVM_DIR="$XDG_DATA_HOME/nvm"
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash
  nvm install stable

  # Autocompletion for npm (probably needed)
  npm completion > ~/.zfunc/_npm
fi

if no rustup || no cargo; then
  # Install rustup
  curl https://sh.rustup.rs -sSf | sh
  # Install stable and nightly
  rustup install nightly
  rustup install stable
  # Download zsh completion
  mkdir ~/.zfunc
  curl https://raw.githubusercontent.com/rust-lang-nursery/rustup.rs/master/src/rustup-cli/zsh/_rustup >~/.zfunc/_rustup

  # Download docs and src
  rustup component add rust-src
  rustup component add rust-docs
fi

# Install vim-plug:
if no nvim/site/autoload/plug.vim; then
  curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
