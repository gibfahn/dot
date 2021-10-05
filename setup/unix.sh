#!/usr/bin/env bash
# shellcheck shell=bash disable=SC1090,SC2016

# Installs things that I use on all Unix systems (e.g. macOS and Linux).

set -ex

. "$(dirname "$0")"/../helpers/setup.sh # Load helper script from dot/helpers.

if [[ -e "$XDG_CACHE_HOME"/z ]]; then
  log_skip "z cache file"
else
  log_get "z cache file"
  mkdir -p "$XDG_CACHE_HOME"
  touch "$XDG_CACHE_HOME"/z
fi

# Set default shell to zsh (or $NEWSHELL if set).

# $SHELL isn't updated until we logout, so check whether chsh was already run.
if [[ "$(uname)" == Darwin ]]; then # macOS
  shell=$(dscl . -read "$HOME" UserShell)
elif [[ "$(uname)" == Linux ]]; then # Linux.
  shell=$(grep "$USER" /etc/passwd | awk -F : '{print $NF}')
fi
# Fall back to $SHELL if that doesn't work.
shell=${shell:-$SHELL}
if [[ -z "$ZSH_VERSION" && "${shell##*/}" != zsh ]]; then
  NEWSHELL=${NEWSHELL-$(grep zsh /etc/shells | tail -1)} # Set NEWSHELL for a different shell.
  if [[ -e "$NEWSHELL" ]]; then
    log_get "Shell change (Current shell is $shell, changing to $NEWSHELL)."
    chsh -s "$NEWSHELL" || log_skip "Shell change (chsh failed)."
  else
    log_skip "Shell change (current shell is $shell (\$SHELL=$SHELL) but shell $NEWSHELL (zsh) doesn't exist)
    Install zsh and then run chsh -s /path/to/zsh"
  fi
else
  log_skip "Shell change ($shell is already the default shell)"
fi

# Change git user.name and user.email
if [[ ! -f "$XDG_CONFIG_HOME/git/my-config" ]]; then
  # Allow manual override with `GIT_NAME` and `GIT_EMAIL`.
  # shellcheck disable=SC2153
  [[ -n "$GIT_NAME" ]] && git_name="$GIT_NAME"
  # shellcheck disable=SC2153
  [[ -n "$GIT_EMAIL" ]] && git_email="$GIT_EMAIL"

  if [[ "$USER" == gib ]]; then
    git_name=${git_name:-"Gibson Fahnestock"}
    git_email=${git_email:-"gibfahn@gmail.com"}
  fi

  if [[ -e "$HOME/.gitconfig" ]]; then
    git_name=${git_name:-"$(git config user.name)"}
    git_email=${git_email:-"$(git config user.email)"}
    log_get "Git Config (moving ~/.gitconfig to ~/backup/.gitconfig, preserving name as '$git_name' and email
    as '$git_email'. Make sure to move any settings you want preserved across)."
    mv "$HOME/.gitconfig" "$HOME/backup/.gitconfig"
  fi

  if [[ -z "$git_name" ]]; then
    read -rp "Git name not set, what's your full name? " git_name
  fi
  if [[ -z "$git_email" ]]; then
    read -rp "Git email not set, what's your email address? " git_email
  fi

  my_git_config="# vi filetype=gitconfig

[user]
  # Needs to match gpg signing email.
  name = $git_name
  email = $git_email
"

  printf "%s" "$my_git_config" >"$XDG_CONFIG_HOME/git/my-config"

  log_get "Git Config (git name set to $(git config user.name) and email set to $(git config user.email))"
else
  log_skip "Git Config as already set to $(git config user.name) <$(git config user.email)>"
fi

# Set up a default ssh config
if [[ ! -e ~/.ssh/config ]]; then
  log_get "SSH Config (copying default)."
  [[ -d ~/.ssh ]] || { mkdir ~/.ssh && chmod 700 ~/.ssh; }
  cp "$(dirname "$0")"/config/ssh-config ~/.ssh/config
else
  log_skip "SSH Config (not overwriting ~/.ssh/config, copy manually from ./config/ssh-config as necessary)."
fi

# Set up zsh scripts:
mkdir -p "$XDG_DATA_HOME/zsh"

# Cleanup any zsh completion dirs with bad permissions.
insecure_dirs=()
while read -r val; do
  insecure_dirs+=("$val")
done <<<"$(zsh -c 'autoload -U compaudit; compaudit')"
if [[ -n ${insecure_dirs[*]} ]]; then
  log_get "compinit (zsh completion dir permissions)"

  user="$(id -un)" group="$(id -gn)"
  for insecure_dir in "${insecure_dirs[@]}"; do
    sudo chown "$user:$group" "$insecure_dir"
    sudo chmod -R 755 "$insecure_dir"
  done
else
  log_skip "compinit (zsh completion dir permissions)"
fi

# Symlink fzf
if not fzf && [[ -d "$XDG_DATA_HOME"/fzf/bin/ ]]; then
  ln -sf "$XDG_DATA_HOME"/fzf/bin/* "$HOME"/bin/
fi

log_get "Updating ZSH Completions"
# Put completion files into this dir so they get picked up by zinit in gibrc.
# Anything that pulls directly from a URL can be added directly to _gib_completion_files in gibrc.
mkdir -p "$XDG_DATA_HOME/zsh/completions"

# _rustup and _cargo
exists rustup && {
  rustup completions zsh >"$XDG_DATA_HOME/zsh/completions/_rustup"
  # Creates "$XDG_DATA_HOME/zsh/completions/_cargo"
  ln -sf "$(realpath "$(dirname "$(rustup which cargo)")"/../share/zsh/site-functions)"/* "$XDG_DATA_HOME/zsh/completions/"
}
# _rbenv
exists rbenv && ln -sf "$XDG_DATA_HOME/rbenv/completions/rbenv.zsh" "$XDG_DATA_HOME/zsh/completions/_rbenv"

# _up
if exists up; then
  # Completion for up-rs
  up completions zsh >"$XDG_DATA_HOME/zsh/completions/_up"
fi

# _kitty
if exists kitty; then
  # Completion for kitty
  kitty + complete setup zsh >"$XDG_DATA_HOME/zsh/completions/_kitty"
fi
