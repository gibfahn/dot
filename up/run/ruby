#!/usr/bin/env zsh

set -eux

ruby_gems=(
  reek       # Ruby style checker for code smells.
  rubocop    # Ruby style checker and formatter.
  solargraph # Ruby LanguageServer Client.
)

# Not needed for other people.
if [[ $USER != gib ]]; then
  exit 0
fi

# Install ruby gems
for gem in "${ruby_gems[@]}"; do
  if gem list --no-installed "$gem" >/dev/null; then
    gem install "$gem"
  fi
done

# Update ruby gems.
outdated_gems=("${(@f)$(gem outdated | awk '{print $1}')}")
gem update "${outdated_gems[@]}"
