#!/usr/bin/env bash

. "$(dirname "$0")"/../helpers/setup.sh # Load helper script from dot/helpers.

set -ex

ruby_gems=(
  solargraph                    # Ruby LanguageServer Client.
)

# Not needed for other people.
if [[ $USER != gib ]]; then
  exit 0
fi

# Install ruby gems
for gem in "${ruby_gems[@]}"; do
  if gem list -I "$gem" >/dev/null; then
    log_get "gem: $gem"
    gem install "$gem"
  else
    log_skip "gem: $gem"
  fi
done

# Update ruby gems.
gem update "$(gem outdated | awk '{print $1}')"
