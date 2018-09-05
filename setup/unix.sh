#!/bin/bash

# Installs things that I use on all Unix systems (e.g. macOS and Linux).

. $(dirname $0)/../helpers/setup.sh # Load helper script from dot/helpers.

npm_modules=(
  javascript-typescript-langserver # Language server for JavaScript and Typescript files.
  bash-language-server             # Language server for bash and other shell script files.
)

pip3_modules=(
  neovim-remote                 # Connect to existing nvim sessions (try `g cm` in a nvim terminal).
  neovim                        # Python plugin framework for neovim.
  'python-language-server[all]' # Python language server (I use it in neovim).
)

ruby_gems=(
  solargraph                    # Ruby LanguageServer Client.
)

rust_crates=(
  tally                         # Nicer time (shows memory, page faults etc).
  svgcleaner                    # Remove unnecessary info from svgs.
  oxipng                        # Compress png images.
)

# These are installed and updated through brew on Darwin.
if [[ "$(uname)" == Linux ]]; then
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

# These are a bit more esoteric.
if [[ -n "$HARDCORE" ]]; then
  rust_crates+=(
  )
fi

# Initialise and update submodules (not yet mandatory).
git submodule init && git submodule update || true

# Set default shell to zsh (or $NEWSHELL if set).

# $SHELL isn't updated until we logout, so check whether chsh was already run.
if [[ "$(uname)" == Darwin ]]; then # macOS
  shell=$(dscl . -read $HOME UserShell)
elif [[ "$(uname)" == Linux ]]; then # Linux.
  shell=$(cat /etc/passwd | grep $USER | awk -F : '{print $NF}')
fi
# Fall back to $SHELL if that doesn't work.
shell=${shell:-$SHELL}
if [[ -z "$ZSH_VERSION" && "${shell##*/}" != zsh ]]; then
  NEWSHELL=${NEWSHELL-$(cat /etc/shells | grep zsh | tail -1)} # Set NEWSHELL for a different shell.
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
if exists git && [[ "$(whoami)" != gib ]] && {
 grep -q 'name = Gibson Fahnestock # REPLACEME' "$XDG_CONFIG_HOME/git/config" ||
 grep -q 'email = gibfahn@gmail.com # REPLACEME' "$XDG_CONFIG_HOME/git/config"
}; then
  # Allow manual override with `GIT_NAME` and `GIT_EMAIL`.
  [[ -n "$GIT_NAME" ]] && GITNAME="$GIT_NAME"
  [[ -n "$GIT_EMAIL" ]] && GITEMAIL="$GIT_EMAIL"
  if [[ -z "$GIT_NAME" || -z "$GIT_EMAIL" ]] && [[ -e "$HOME/.gitconfig" ]]; then
    GITNAME=$(git config --global user.name)
    GITEMAIL=$(git config --global user.email)
    get "Git Config (moving ~/.gitconfig to ~/backup/.gitconfig, preserving name as '$GITNAME' and email
    as '$GITEMAIL'. Make sure to move any settings you want preserved across)."
    mv "$HOME/.gitconfig" "$HOME/backup/.gitconfig"
    git config --global user.name "$GITNAME"
    git config --global user.email "$GITEMAIL"
  fi
  if [[ -z "$GITNAME" || "$(git config --global user.name)" == "Gibson Fahnestock" ]]; then
    read -p "Git name not set, what's your full name? " GITNAME
    git config --global user.name "$GITNAME"
  fi
  if [[ -z "$GITEMAIL" || "$(git config --global user.email)" == "gibfahn@gmail.com" ]]; then
    read -p "Git email not set, what's your email address? " GITEMAIL
    git config --global user.email "$GITEMAIL"
  fi
  get "Git Config (git name set to $(git config --global user.name) and email set to $(git config --global user.email))"
fi

gitCloneOrUpdate rbenv/rbenv "$XDG_DATA_HOME/rbenv"
# Only run make if there were changes.
if [[ "$?" == 0 ]]; then
  ln -sf "$XDG_DATA_HOME/rbenv/completions/rbenv.zsh" "$XDG_DATA_HOME/zfunc/rbenv.zsh"
  (pushd "$XDG_DATA_HOME/rbenv" && src/configure && make -C src)
fi

gitCloneOrUpdate so-fancy/diff-so-fancy "$XDG_DATA_HOME/diff-so-fancy"
if not diff-so-fancy; then
  ln -sf "$XDG_DATA_HOME/diff-so-fancy/diff-so-fancy" "$HOME/bin/diff-so-fancy"
fi

# Set up a default ssh config
if [[ ! -e ~/.ssh/config ]]; then
  get "SSH Config (copying default)."
  [[ ! -d ~/.ssh ]] && mkdir ~/.ssh && chmod 700 ~/.ssh || true
  cp $(dirname $0)/config/ssh-config ~/.ssh/config
else
  skip "SSH Config (not overwriting ~/.ssh/config, copy manually from ./config/ssh-config as necessary)."
fi

# Set up autocompletions:
mkdir -p "$XDG_DATA_HOME/zfunc"

# Set up zsh scripts:
mkdir -p "$XDG_DATA_HOME/zsh"

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
nvm_prefix="$([[ "$(uname -m)" != x86_64 ]] && echo "$(uname -m)/")"
if no "$nvm_prefix"nvm; then
  # No install scripts as path update isn't required, it's done in gibrc.
  gitClone creationix/nvm "$XDG_DATA_HOME/${nvm_prefix}nvm"
  . "$XDG_DATA_HOME/${nvm_prefix}"nvm/nvm.sh # Load nvm so we can use it below.
  nvm install --lts # Install the latest LTS version of node.

  # Autocompletion for npm (probably needed)
  mkdir -p "$XDG_DATA_HOME/.zfunc"
  npm completion --loglevel=error > "$XDG_DATA_HOME/.zfunc/_npm"
fi

# Install rvm
if not rbenv; then
  export PATH="$XDG_DATA_HOME/rbenv/bin:$PATH"
  export PATH="$XDG_CACHE_HOME/rbenv/shims:$PATH"
  export RBENV_ROOT="${RBENV_ROOT:-"$XDG_CACHE_HOME/rbenv"}" # Set rbenv location.
fi

# Install latest version of ruby if changed.
rbenv install --skip-existing $(rbenv install --list | grep -v - | tail -1)

# Symlink fzf
if not fzf; then
  ln -s "$XDG_DATA_HOME"/fzf/bin/* "$HOME"/bin/
fi

# Install ruby gems
for gem in "${ruby_gems[@]}"; do
  if gem list -i "$gem"; then
    get "gem: $gem"
    gem install "$gem"
  else
    skip "gem: $gem"
  fi
done

# Update ruby gems.
gem update $(gem outdated | cut -d ' ' -f 1)

# Install vim-plug (vim plugin manager):
if no nvim/site/autoload/plug.vim; then
  curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  unset VIM
  { exists nvim && VIM=nvim; } || { exists vim && VIM=vim; } # Take what you can get.
  [[ "$VIM" = vim ]] && mkdir -p ~/.vim && ln -s ~/.local/share/nvim/site/autoload ~/.vim/autoload
  exists $VIM && $VIM +PlugInstall +qall # Install/update vim plugins.
fi

# Install npm modules.
not npm && . "$XDG_DATA_HOME/${nvm_prefix}"nvm/nvm.sh # Load nvm so we can use npm.
installed_npm_module_versions="$(npm ls -g --depth=0 --loglevel=error | grep -Ex '.* [-_A-Za-z0-9]+@([0-9]+\.){2}[0-9]+' | sed -E 's/^\W+ //' | sed 's/@/ /')"
for module in "${npm_modules[@]}"; do
  if ! echo "$installed_npm_module_versions" | grep -qx "$module .*" \
    || [[ "$(echo "$installed_npm_module_versions" | grep -x "$module .*" | awk '{print $NF}')" != "$(npm info --loglevel=error "$module" version)" ]]; then
    get "npm: $module"
    npm install --global --loglevel=error "$module"@latest
  else
    skip "npm: $module"
  fi
done

# If you don't use rust just choose the cancel option.
if [[ -n "$HARDCORE" ]] && { no rustup || no cargo; }; then # Install/set up rust.
  # Install rustup. Don't modify path as that's already in gibrc.
  RUSTUP_HOME="$XDG_DATA_HOME"/rustup CARGO_HOME="$XDG_DATA_HOME"/cargo curl https://sh.rustup.rs -sSf | bash -s -- -y --no-modify-path
  # Download zsh completion
  exists zsh && curl https://raw.githubusercontent.com/rust-lang-nursery/rustup.rs/master/src/rustup-cli/zsh/_rustup >"$XDG_DATA_HOME/zfunc/_rustup"

  if [[ -d "$HOME/.rustup" ]]; then
    # Move to proper directories
    mv "$HOME/.rustup" "$XDG_DATA_HOME/rustup"
    mv "$HOME/.cargo" "$XDG_DATA_HOME/cargo"
  fi

  export PATH="$XDG_DATA_HOME/cargo/bin:$PATH"

  # Install stable and nightly (stable should be a no-op).
  rustup install nightly
  rustup install stable

  # Download rls (https://github.com/rust-lang-nursery/rls):
  rustup component add rls-preview rust-analysis rust-src clippy-preview rustfmt-preview
else
  update "Rust compiler and Cargo"
  rustup update
  update "Global Cargo packages"
  not cargo-install-update && cargo install cargo-update
  cargo install-update -a # Update everything installed with cargo install.
fi

# Install any crates that are missing.
cargo install-update -i "${rust_crates[@]}"
