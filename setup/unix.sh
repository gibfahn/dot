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

rust_crates=(
  # tally                         # Nicer time (shows memory, page faults etc), I'm using hyperfine instead.
  # svgcleaner                    # Remove unnecessary info from svgs.
  # oxipng                        # Compress png images.
  # find_unicode                  # Find unicode.
  proximity-sort
  cargo-edit
)

go_packages=(
  github.com/sourcegraph/go-langserver # Go language server (used in nvim).
)

# These are installed and updated through brew on Darwin.
if [[ -n $HARDCORE && $(uname) == Linux ]]; then
  rust_crates+=(
    # exa
    # watchexec                   # Like entr (evaluating which one is better).
    # xsv                         # csv manipulator.
    bat                         # Nicer cat with syntax highlighting etc.
    hyperfine                   # Benchmark commands (time but a benchmarking suite).
  )
fi

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
if [[ -n $HARDCORE ]] && [[ -n "$changed1" ]] \
  || [[ -n "$changed2" ]]; then
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

# Set up less file (colors for less).
# We don't save the input to a lesskey file because we need the terminal to
# resolve the tput commands.
if exists lesskey; then
  log_update  "Lesskey"
  lesskey -o "$XDG_CACHE_HOME/less" <(
cat << EOF
$(echo "#env") # Get a comment.
LESS_TERMCAP_md = $(tput bold; tput setaf 6)
LESS_TERMCAP_me = $(tput sgr0)
LESS_TERMCAP_so = $(tput bold; tput setaf 3; tput setab 4)
LESS_TERMCAP_se = $(tput rmso; tput sgr0)
LESS_TERMCAP_us = $(tput smul; tput bold; tput setaf 7)
LESS_TERMCAP_ue = $(tput rmul; tput sgr0)
LESS_TERMCAP_mr = $(tput rev)
LESS_TERMCAP_mh = $(tput dim)
EOF
  )
else
  log_skip "Lesskey"
fi

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
# Broken by https://github.com/zdharma/zinit/issues/1
# gitCloneOrUpdate zdharma/zinit "$XDG_DATA_HOME/zsh/zplugin/bin" # Zsh plugin manager.
zsh -c '
declare -A ZPLGM
ZPLGM[HOME_DIR]=$XDG_DATA_HOME/zsh/zplugin
ZPLGM[BIN_DIR]=$XDG_DATA_HOME/zsh/zplugin/bin # Where zplugin is installed.
ZPLGM[ZCOMPDUMP_PATH]=$XDG_CACHE_HOME/zsh/.zcompdump$(hostname)
source "$XDG_DATA_HOME/zsh/zplugin/bin/zplugin.zsh" # Source plugin manager.
# Broken by https://github.com/zdharma/zinit/issues/1
# zplugin self-update
zplugin update --all -p 20'

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
if [[ -n $HARDCORE ]] && no "$nvm_prefix"/nvm; then
  # No install scripts as path update isn't required, it's done in gibrc.
  gitClone creationix/nvm "$XDG_DATA_HOME/${nvm_prefix}/nvm"
  . "$XDG_DATA_HOME/${nvm_prefix}"/nvm/nvm.sh # Load nvm so we can use it below.
  nvm install --lts # Install the latest LTS version of node.
fi

# Add rbenv to path in case it was only just installed.
if [[ -n $HARDCORE ]] && not rbenv; then
  export PATH="$XDG_DATA_HOME/rbenv/bin:$PATH"
  export PATH="$XDG_CACHE_HOME/rbenv/shims:$PATH"
  export RBENV_ROOT="${RBENV_ROOT:-"$XDG_CACHE_HOME/rbenv"}" # Set rbenv location.
fi

# Install latest version of ruby if changed.
[[ -n $HARDCORE ]] && {
  latest_ruby_version=$(rbenv install --list | awk '/^\s*[0-9]+\.[0-9]+\.[0-9]+\s*$/ {a=$1} END { print a }')
  rbenv install --skip-existing "$latest_ruby_version"
  rbenv global "$latest_ruby_version"
}

# Install ruby gems
if [[ -n $HARDCORE ]]; then
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
  exists $VIM && $VIM -N -c 'PlugUpgrade | PlugClean | PlugUpdate' -c quitall -e -s -V1
fi

# Symlink fzf
if not fzf && [[ -d "$XDG_DATA_HOME"/fzf/bin/ ]]; then
  ln -sf "$XDG_DATA_HOME"/fzf/bin/* "$HOME"/bin/
fi

# Install npm modules.
if [[ -n "$HARDCORE" ]]; then
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
if [[ -n "$HARDCORE" && -n "$changed" ]]; then
    (
      cd "$XDG_DATA_HOME/KotlinLanguageServer" || { echo "Failed to cd"; exit 1; }
      ./gradlew installDist # If tests passed we could use `./gradlew build`
      ln -sf "$XDG_DATA_HOME/KotlinLanguageServer/server/build/install/server/bin/kotlin-language-server" "$HOME/bin/kotlin-language-server"
    )
fi

if [[ -n $HARDCORE ]]; then
  if no rustup || no cargo; then # Install/set up rust.
    # Install rustup. Don't modify path as that's already in gibrc.
    RUSTUP_HOME="$XDG_DATA_HOME"/rustup CARGO_HOME="$XDG_DATA_HOME"/cargo curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

    if [[ -d "$HOME/.rustup" ]]; then
      # Move to proper directories
      mv "$HOME/.rustup" "$XDG_DATA_HOME/rustup"
      mv "$HOME/.cargo" "$XDG_DATA_HOME/cargo"
    fi

    export PATH="$XDG_DATA_HOME/cargo/bin:$PATH"

    # Install stable and nightly (stable should be a no-op).
    rustup install nightly
    rustup install stable

    # Make sure we have useful components:
    rustup component add --toolchain stable rls rust-analysis rust-src clippy rustfmt
    rustup component add --toolchain nightly rls rust-analysis rust-src clippy rustfmt
  else
    log_update  "Rust compiler and Cargo"
    rustup update
    log_update  "Global Cargo packages"
    not cargo-install-update && cargo install cargo-update
    cargo install-update -ia "${rust_crates[@]}" # Update everything installed with cargo install.
  fi
fi

# Install or update any go packages we need.
[[ -n "$HARDCORE" ]] && go get -u "${go_packages[@]}"

log_get "Updating ZSH Completions"
# There are two types of completion files. One is an actual zsh completion file (e.g. rustup). The
# other is a file you source that generates the relevant functions (e.g. npm). Put the latter in
# zfunc/source.
mkdir -p "$XDG_DATA_HOME/zfunc/source"

exists rustup && {
  rustup completions zsh > "$XDG_DATA_HOME/zfunc/_rustup"
  ln -sf "$(realpath "$(dirname "$(rustup which cargo)")"/../share/zsh/site-functions)"/* "$XDG_DATA_HOME/zfunc/"
}
exists rbenv && ln -sf "$XDG_DATA_HOME/rbenv/completions/rbenv.zsh" "$XDG_DATA_HOME/zfunc/source/_rbenv"
ln -sf "$XDG_DATA_HOME"/fzf/shell/completion.zsh "$XDG_DATA_HOME/zfunc/source/_fzf"
if exists npm; then
  npm completion --loglevel=error > "$XDG_DATA_HOME/zfunc/source/_npm"
fi

# TODO(gib): Does this actually work?
# Run the source
# zplugin creinstall "$XDG_DATA_HOME"/zfunc/
