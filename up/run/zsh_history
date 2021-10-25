#!/usr/bin/env bash
# Set up zsh_history for ruby version management.

zsh -i -c '
  set -ex

  # Need to be interactive to use history.
  # set -o interactive

  ls -lh "$HISTFILE" "$ZSH_CLOUD_HISTFILE"
  # Read history from cloud histfile.
  fc -R "$ZSH_CLOUD_HISTFILE"
  # Read history from local histfile.
  fc -R "$HISTFILE"
  # Write history to local histfile.
  fc -W "$HISTFILE"
  ls -lh "$HISTFILE" "$ZSH_CLOUD_HISTFILE"
  # Write history to cloud histfile.
  fc -W "$ZSH_CLOUD_HISTFILE"
  ls -lh "$HISTFILE" "$ZSH_CLOUD_HISTFILE"
'
