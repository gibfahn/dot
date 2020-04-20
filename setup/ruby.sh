#!/usr/bin/env bash

. "$(dirname "$0")"/../helpers/setup.sh # Load helper script from dot/helpers.

set -ex

ruby_gems=(
  solargraph                    # Ruby LanguageServer Client.
)

export PATH=/usr/local/bin:$PATH # Make sure brew pip/ruby are the first pip/ruby in the PATH.

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
