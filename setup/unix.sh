#!/usr/bin/env bash
# shellcheck shell=bash disable=SC1090,SC2016

# Installs things that I use on all Unix systems (e.g. macOS and Linux).

set -e

. "$(dirname "$0")"/../helpers/setup.sh # Load helper script from dot/helpers.

npm_modules=(
  javascript-typescript-langserver  # Language server for JavaScript and Typescript files.
  bash-language-server              # Language server for bash and other shell script files.
  dockerfile-language-server-nodejs # Language server for Dockerfiles.
  markdownlint-cli                  # Markdown linter.
  diagnostic-languageserver         # Generic language server (see linters).
  yarn                              # Alternative to npm.
)

pip3_modules=(
  neovim-remote                 # Connect to existing nvim sessions (try `g cm` in a nvim terminal).
  pynvim                        # Python plugin framework for neovim.
  'python-language-server[all]' # Python language server (I use it in neovim).
  vim-vint                      # Vim linter.
)

ruby_gems=(
  solargraph                    # Ruby LanguageServer Client.
)

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

  printf "%s" "$my_git_config" > "$XDG_CONFIG_HOME/git/my-config"

  log_get "Git Config (git name set to $(git config user.name) and email set to $(git config user.email))"
else
  log_skip "Git Config as already set to $(git config user.name) <$(git config user.email)>"
fi

# Set up rbenv for ruby version management.

# Only run make if there were changes.
changed1=$(gitCloneOrUpdate rbenv/rbenv "$XDG_DATA_HOME/rbenv")
changed2=$(gitCloneOrUpdate rbenv/rbenv-default-gems "$XDG_DATA_HOME/rbenv"/plugins/rbenv-default-gems)
if [[ $USER == gib && -n "$changed1" || -n "$changed2" ]]; then
  (pushd "$XDG_DATA_HOME/rbenv" && src/configure && make -C src)
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
readarray -t insecure_dirs <<<"$(zsh -c 'autoload -U compaudit; compaudit')"
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

# Update zsh plugins.
gitCloneOrUpdate zdharma/zinit "$XDG_DATA_HOME/zsh/zinit/bin" # Zsh plugin manager.
zsh -c '
declare -A ZINIT
ZINIT[HOME_DIR]=$XDG_DATA_HOME/zsh/zinit
ZINIT[BIN_DIR]=$XDG_DATA_HOME/zsh/zinit/bin # Where zinit is installed.
ZINIT[ZCOMPDUMP_PATH]=$XDG_CACHE_HOME/zsh/.zcompdump$(hostname)
source "$XDG_DATA_HOME/zsh/zinit/bin/zinit.zsh" # Source plugin manager.
zinit self-update
zinit update --all -p 20
# zinit delete --clean -y # Remove no-longer-used plugins and snippets.
# zinit cclear # Remove outdated completion entries.
'

# Install or update pip modules.
export PATH=/usr/local/bin:$PATH # Make sure brew pip/ruby are the first pip/ruby in the PATH.
pip=pip
exists pip3 && pip=pip3
pip_installed="$($pip list | awk '{print $1}')"
pip_outdated="$($pip list --outdated | awk '{print $1}')"

for module in "${pip3_modules[@]}"; do
  if ! echo "$pip_installed" | grep -qx "${module%[*}" \
      || echo "$pip_outdated" | grep -qx "${module%[*}"; then
    log_get "$pip: $module"
    $pip install -Uq "$module"
  else
    log_skip "$pip: $module"
  fi
done

# Install nvm:
unamem="$(uname -m)"
nvm_prefix="${unamem/x86_64/}"
if [[ $USER == gib ]] && no "$nvm_prefix"/nvm; then
  # No install scripts as path update isn't required, it's done in gibrc.
  gitClone creationix/nvm "$XDG_DATA_HOME/${nvm_prefix}/nvm"
  . "$XDG_DATA_HOME/${nvm_prefix}"/nvm/nvm.sh # Load nvm so we can use it below.
  nvm install --lts # Install the latest LTS version of node.
fi

# Add rbenv to path in case it was only just installed.
if [[ $USER == gib ]] && not rbenv; then
  export PATH="$XDG_DATA_HOME/rbenv/bin:$PATH"
  export PATH="$XDG_CACHE_HOME/rbenv/shims:$PATH"
  export RBENV_ROOT="${RBENV_ROOT:-"$XDG_CACHE_HOME/rbenv"}" # Set rbenv location.
fi

# Install latest version of ruby if changed.
[[ $USER == gib ]] && {
  latest_ruby_version=$(rbenv install --list | awk '/^\s*[0-9]+\.[0-9]+\.[0-9]+\s*$/ {a=$1} END { print a }')
  rbenv install --skip-existing "$latest_ruby_version"
  rbenv global "$latest_ruby_version"
}

# Install ruby gems
if [[ $USER == gib ]]; then
  for gem in "${ruby_gems[@]}"; do
    if gem list -I "$gem" >/dev/null; then
      log_get "gem: $gem"
      gem install "$gem"
    else
      log_skip "gem: $gem"
    fi
  done
fi

# Update ruby gems.
gem update "$(gem outdated | awk '{print $1}')"

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

# Symlink fzf
if not fzf && [[ -d "$XDG_DATA_HOME"/fzf/bin/ ]]; then
  ln -sf "$XDG_DATA_HOME"/fzf/bin/* "$HOME"/bin/
fi

# Install npm modules.
if [[ $USER == gib ]]; then
  not npm && . "$XDG_DATA_HOME/${nvm_prefix}"/nvm/nvm.sh # Load nvm so we can use npm.
  installed_npm_module_versions="$(npm ls -g --depth=0 --loglevel=error | grep -Ex '.* [-_A-Za-z0-9]+@([0-9]+\.){2}[0-9]+' | sed -E 's/^.+ //' | sed 's/@/ /')"
  for module in "${npm_modules[@]}"; do
    if ! echo "$installed_npm_module_versions" | grep -qx "$module .*" \
      || [[ "$(echo "$installed_npm_module_versions" | grep -x "$module .*" | awk '{print $NF}')" != "$(npm info --loglevel=error "$module" version)" ]]; then
      log_get "npm: $module"
      npm install --global --loglevel=error "$module"@latest
    else
      log_skip "npm: $module"
    fi
  done
fi

changed=$(gitCloneOrUpdate fwcd/KotlinLanguageServer "$XDG_DATA_HOME/KotlinLanguageServer")
if [[ $USER == gib && -n "$changed" ]]; then
    (
      cd "$XDG_DATA_HOME/KotlinLanguageServer" || { echo "Failed to cd"; exit 1; }
      ./gradlew installDist # If tests passed we could use `./gradlew build`
      ln -sf "$XDG_DATA_HOME/KotlinLanguageServer/server/build/install/server/bin/kotlin-language-server" "$HOME/bin/kotlin-language-server"
    )
fi

log_get "Updating ZSH Completions"
# Put completion files into this dir so they get picked up by zinit in gibrc.
# Anything that pulls directly from a URL can be added directly to _gib_completion_files in gibrc.
mkdir -p "$XDG_DATA_HOME/zsh/completions"

# _rustup and _cargo
exists rustup && {
  rustup completions zsh > "$XDG_DATA_HOME/zsh/completions/_rustup"
  # Creates "$XDG_DATA_HOME/zsh/completions/_cargo"
  ln -sf "$(realpath "$(dirname "$(rustup which cargo)")"/../share/zsh/site-functions)"/* "$XDG_DATA_HOME/zsh/completions/"
}
# _rbenv
exists rbenv && ln -sf "$XDG_DATA_HOME/rbenv/completions/rbenv.zsh" "$XDG_DATA_HOME/zsh/completions/_rbenv"

# _kitty
if exists kitty; then
  # Completion for kitty
  kitty + complete setup zsh > "$XDG_DATA_HOME/zsh/completions/_kitty"
fi
