#!/usr/bin/env bash

. "$(dirname "$0")"/../helpers/setup.sh # Load helper script from dot/helpers.

set -ex

# Install vim-plug (vim plugin manager):
if no nvim/site/autoload/plug.vim; then
  log_get "Installing vim"
  curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  unset VIM
  { exists nvim && VIM=nvim; } || { exists vim && VIM=vim; } # Take what you can get.
  [[ "$VIM" = vim ]] && mkdir -p ~/.vim && ln -s ~/.local/share/nvim/site/autoload ~/.vim/autoload
  exists $VIM && $VIM +PlugInstall +qall # Install/update vim plugins.
else
  log_update "Vim Plugins"
  { exists nvim && VIM=nvim; } || { exists vim && VIM=vim; } # Take what you can get.
  exists $VIM && $VIM -N -u "$XDG_CONFIG_HOME"/nvim/init.vim -c 'PlugUpgrade | PlugClean | PlugUpdate' -c quitall -e -s
fi

