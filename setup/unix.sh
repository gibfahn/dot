#!/bin/bash
# shellcheck shell=bash disable=SC1090,SC2016

# Installs things that I use on all Unix systems (e.g. macOS and Linux).

. "$(dirname "$0")"/../helpers/setup.sh # Load helper script from dot/helpers.

npm_modules=(
  javascript-typescript-langserver  # Language server for JavaScript and Typescript files.
  bash-language-server              # Language server for bash and other shell script files.
  dockerfile-language-server-nodejs # Language server for Dockerfiles.
  markdownlint-cli                  # Markdown linter.
  diagnostic-languageserver         # Generic language server (see linters).
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
  tally                         # Nicer time (shows memory, page faults etc).
  svgcleaner                    # Remove unnecessary info from svgs.
  oxipng                        # Compress png images.
)

go_packages=(
  github.com/sourcegraph/go-langserver # Go language server (used in nvim).
)

# These are installed and updated through brew on Darwin.
if [[ -z $MINIMAL && $(uname) == Linux ]]; then
  rust_crates+=(
    ripgrep                     # Super-fast version of grep/ack/ag that handles unicode etc.
    fd-find                     # Faster version of find.
    bat                         # Nicer cat with syntax highlighting etc.
    xsv                         # csv manipulator.
    watchexec                   # Like entr (evaluating which one is better).
    hyperfine                   # Benchmark commands (time but a benchmarking suite).
  )

  # Less likely to be used and on brew.
  if [[ -n "$HARDCORE" ]]; then
    rust_crates+=(
      exa
    )
  fi
fi

# Initialise and update submodules (not yet mandatory).
{ git submodule init && git submodule update; } || true

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
    get "Shell change (Current shell is $shell, changing to $NEWSHELL)."
    chsh -s "$NEWSHELL" || skip "Shell change (chsh failed)."
  else
    skip "Shell change (current shell is $shell (\$SHELL=$SHELL) but shell $NEWSHELL (zsh) doesn't exist)
    Install zsh and then run chsh -s /path/to/zsh"
  fi
else
  skip "Shell change ($shell is already the default shell)"
fi

# Change git user.name and user.email
if exists git && [[ $(whoami) != gib && $(id -u) != 0 ]] && {
 grep -q 'name = Gibson Fahnestock # REPLACEME' "$XDG_CONFIG_HOME/git/config" ||
 grep -q 'email = gibfahn@gmail.com # REPLACEME' "$XDG_CONFIG_HOME/git/config"
}; then
  # Allow manual override with `GIT_NAME` and `GIT_EMAIL`.
  # shellcheck disable=SC2153
  [[ -n "$GIT_NAME" ]] && git_name="$GIT_NAME"
  # shellcheck disable=SC2153
  [[ -n "$GIT_EMAIL" ]] && git_email="$GIT_EMAIL"
  if [[ -z "$GIT_NAME" || -z "$GIT_EMAIL" ]] && [[ -e "$HOME/.gitconfig" ]]; then
    git_name=$(git config --global user.name)
    git_email=$(git config --global user.email)
    get "Git Config (moving ~/.gitconfig to ~/backup/.gitconfig, preserving name as '$git_name' and email
    as '$git_email'. Make sure to move any settings you want preserved across)."
    mv "$HOME/.gitconfig" "$HOME/backup/.gitconfig"
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
  fi
  if [[ -z "$git_name" || "$(git config --global user.name)" == "Gibson Fahnestock" ]]; then
    read -rp "Git name not set, what's your full name? " git_name
    git config --global user.name "$git_name"
  fi
  if [[ -z "$git_email" || "$(git config --global user.email)" == "gibfahn@gmail.com" ]]; then
    read -rp "Git email not set, what's your email address? " git_email
    git config --global user.email "$git_email"
  fi
  get "Git Config (git name set to $(git config --global user.name) and email set to $(git config --global user.email))"
fi

# Set up rbenv for ruby version management.

# Only run make if there were changes.
if [[ -z $MINIMAL ]] && gitCloneOrUpdate rbenv/rbenv "$XDG_DATA_HOME/rbenv" \
  || gitCloneOrUpdate rbenv/rbenv-default-gems "$XDG_DATA_HOME/rbenv"/plugins/rbenv-default-gems; then
  (pushd "$XDG_DATA_HOME/rbenv" && src/configure && make -C src)
fi

gitCloneOrUpdate so-fancy/diff-so-fancy "$XDG_DATA_HOME/diff-so-fancy"
if not diff-so-fancy; then
  ln -sf "$XDG_DATA_HOME/diff-so-fancy/diff-so-fancy" "$HOME/bin/diff-so-fancy"
fi

# Set up a default ssh config
if [[ ! -e ~/.ssh/config ]]; then
  get "SSH Config (copying default)."
  [[ -d ~/.ssh ]] || { mkdir ~/.ssh && chmod 700 ~/.ssh; }
  cp "$(dirname "$0")"/config/ssh-config ~/.ssh/config
else
  skip "SSH Config (not overwriting ~/.ssh/config, copy manually from ./config/ssh-config as necessary)."
fi

# Set up autocompletions and source dir:
mkdir -p "$XDG_DATA_HOME/zfunc/source"

# Set up zsh scripts:
mkdir -p "$XDG_DATA_HOME/zsh"

# Set up less file (colors for less).
# We don't save the input to a lesskey file because we need the terminal to
# resolve the tput commands.
if exists lesskey; then
  update "Lesskey"
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
  skip "Lesskey"
fi

gitCloneOrUpdate zsh-users/zsh-syntax-highlighting "$XDG_DATA_HOME/zsh/zsh-syntax-highlighting"

# Install or update pip modules.
pip=pip
exists pip3 && pip=pip3
pip_installed="$($pip list | awk '{print $1}')"
pip_outdated="$($pip list --outdated | awk '{print $1}')"

for module in "${pip3_modules[@]}"; do
  if ! echo "$pip_installed" | grep -qx "${module%[*}" \
      || echo "$pip_outdated" | grep -qx "${module%[*}"; then
    get "$pip: $module"
    $pip install -Uq "$module"
  else
    skip "$pip: $module"
  fi
done

gitCloneOrUpdate mafredri/zsh-async "$XDG_DATA_HOME/zsh/zsh-async"

# Install nvm:
unamem="$(uname -m)"
nvm_prefix="${unamem/x86_64/}"
if [[ -z $MINIMAL ]] && no "$nvm_prefix"/nvm; then
  # No install scripts as path update isn't required, it's done in gibrc.
  gitClone creationix/nvm "$XDG_DATA_HOME/${nvm_prefix}/nvm"
  . "$XDG_DATA_HOME/${nvm_prefix}"/nvm/nvm.sh # Load nvm so we can use it below.
  nvm install --lts # Install the latest LTS version of node.
fi

# Add rbenv to path in case it was only just installed.
if [[ -z $MINIMAL ]] && not rbenv; then
  export PATH="$XDG_DATA_HOME/rbenv/bin:$PATH"
  export PATH="$XDG_CACHE_HOME/rbenv/shims:$PATH"
  export RBENV_ROOT="${RBENV_ROOT:-"$XDG_CACHE_HOME/rbenv"}" # Set rbenv location.
fi

# Install latest version of ruby if changed.
[[ -z $MINIMAL ]] && {
  latest_ruby_version=$(rbenv install --list | awk '/^\s*[0-9]+\.[0-9]+\.[0-9]+\s*$/ {a=$1} END { print a }')
  rbenv install --skip-existing "$latest_ruby_version"
  rbenv global "$latest_ruby_version"
}

# Install ruby gems
if [[ -z $MINIMAL ]]; then
  for gem in "${ruby_gems[@]}"; do
    if gem list -I "$gem" >/dev/null; then
      get "gem: $gem"
      gem install "$gem"
    else
      skip "gem: $gem"
    fi
  done
fi

# Update ruby gems.
gem update "$(gem outdated | awk '{print $1}')"

# Install vim-plug (vim plugin manager):
if no nvim/site/autoload/plug.vim; then
  curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  unset VIM
  { exists nvim && VIM=nvim; } || { exists vim && VIM=vim; } # Take what you can get.
  [[ "$VIM" = vim ]] && mkdir -p ~/.vim && ln -s ~/.local/share/nvim/site/autoload ~/.vim/autoload
  exists $VIM && $VIM +PlugInstall +qall # Install/update vim plugins.
fi

# Symlink fzf
if not fzf; then
  ln -sf "$XDG_DATA_HOME"/fzf/bin/* "$HOME"/bin/
fi

# Install npm modules.
if [[ -z $MINIMAL ]]; then
  not npm && . "$XDG_DATA_HOME/${nvm_prefix}"/nvm/nvm.sh # Load nvm so we can use npm.
  installed_npm_module_versions="$(npm ls -g --depth=0 --loglevel=error | grep -Ex '.* [-_A-Za-z0-9]+@([0-9]+\.){2}[0-9]+' | sed -E 's/^.+ //' | sed 's/@/ /')"
  for module in "${npm_modules[@]}"; do
    if ! echo "$installed_npm_module_versions" | grep -qx "$module .*" \
      || [[ "$(echo "$installed_npm_module_versions" | grep -x "$module .*" | awk '{print $NF}')" != "$(npm info --loglevel=error "$module" version)" ]]; then
      get "npm: $module"
      npm install --global --loglevel=error "$module"@latest
    else
      skip "npm: $module"
    fi
  done
fi

gitCloneOrUpdate fwcd/KotlinLanguageServer "$XDG_DATA_HOME/KotlinLanguageServer"
if [[ $? != 200 ]]; then
  (
    cd "$XDG_DATA_HOME/KotlinLanguageServer" || { echo "Failed to cd"; exit 1; }
    ./gradlew installDist # If tests passed we could use `./gradlew build`
    ln -sf "$XDG_DATA_HOME/KotlinLanguageServer/server/build/install/server/bin/server" "$HOME/bin/kotlin-language-server"
  )
fi

# If you don't use rust just choose the cancel option.
if [[ -z $MINIMAL && -n $HARDCORE ]]; then
  if no rustup || no cargo; then # Install/set up rust.
    # Install rustup. Don't modify path as that's already in gibrc.
    RUSTUP_HOME="$XDG_DATA_HOME"/rustup CARGO_HOME="$XDG_DATA_HOME"/cargo curl https://sh.rustup.rs -sSf | bash -s -- -y --no-modify-path

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
    rustup component add rls rust-analysis rust-src clippy rustfmt
  else
    update "Rust compiler and Cargo"
    rustup update
    update "Global Cargo packages"
    not cargo-install-update && cargo install cargo-update
    cargo install-update -ia "${rust_crates[@]}" # Update everything installed with cargo install.
  fi
  [[ -d "$XDG_DATA_HOME/zfunc" ]] || mkdir -p "$XDG_DATA_HOME/zfunc"
fi

# Install or update any go packages we need.
go get -u "${go_packages[@]}"

get "Updating ZSH Completions"
# There are two types of completion files. One is an actual zsh completion file (e.g. rustup). The
# other is a file you source that generates the relevant functions (e.g. npm). Put the latter in
# zfunc/source.
exists rustup && {
  rustup completions zsh > "$XDG_DATA_HOME/zfunc/_rustup"
  ln -sf "$(realpath "$(dirname "$(rustup which cargo)")"/../share/zsh/site-functions)"/* "$XDG_DATA_HOME/zfunc/"
}
exists rbenv && ln -sf "$XDG_DATA_HOME/rbenv/completions/rbenv.zsh" "$XDG_DATA_HOME/zfunc/source/_rbenv"
ln -sf "$XDG_DATA_HOME"/fzf/shell/completion.zsh "$XDG_DATA_HOME/zfunc/source/_fzf"
exists npm && npm completion --loglevel=error > "$XDG_DATA_HOME/zfunc/source/_npm"
