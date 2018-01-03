#!/usr/bin/env zsh

# %F{1} style variables are zsh variables, test them with:
# print -P '%F{214}%K{123}%m%k%f' (see man zshmisc: EXPANSION OF PROMPT SEQUENCES).

# Good options: ▶ ❯ ➜ ⇉ ⇏ ⇛ ⇝ ⇨ ⇶ 🢂  ⭆  ➩ ➭ 🡆 🠞 ⇻
PROMPT="$([ "$SSH_CLIENT" -o "$SSH_TTY" ] && echo "%F{161}%m%f ")%(?:%F{46}:%F{196})▶▶▶%f "

# Put full path and git info on right of prompt.
# RPROMPT='$fullPath$timer_prompt$(git_prompt_info)'
RPROMPT='%(?:%F{28}:%F{88})%~%f%F{14}$timer_prompt%f$(git_prompt_info_gib)'

# Record the time at which the command began before zsh executes the command.
preexec() { unset timer_prompt; timer="${timer:-$SECONDS}"; }

# Log the time the command took if at least 1s before zsh shows the result of the command.
precmd() { [ "$timer" -a "$SECONDS" != "$timer" ] && timer_prompt=" $(($SECONDS - $timer))s" || unset timer_prompt; unset timer; }

# Outputs current branch info in prompt format
function git_prompt_info_gib() {
  local ref
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
  echo " %F{33}(${ref#refs/heads/}$(parse_git_dirty_gib)%f"
}

# Checks if working tree is dirty
function parse_git_dirty_gib() {
  local STATUS=''
  local -a FLAGS
  FLAGS=('--porcelain')
  if [[ "$(command git config --get oh-my-zsh.hide-dirty)" != "1" ]]; then
    if [ $POST_1_7_2_GIT -gt 0 ]; then
      FLAGS+='--ignore-submodules=dirty'
    fi
    if [ "$DISABLE_UNTRACKED_FILES_DIRTY" = "true" ]; then
      FLAGS+='--untracked-files=no'
    fi
    STATUS=$(command git status ${FLAGS} 2> /dev/null | tail -n1)
  fi
  [ -n "$STATUS" ] && echo "%F{226}✦%F{33})" || echo ")"
}

# Compares the provided version of git to the version installed and on path
# Outputs -1, 0, or 1 if the installed version is less than, equal to, or
# greater than the input version, respectively.
function git_compare_version() {
  local INPUT_GIT_VERSION INSTALLED_GIT_VERSION
  INPUT_GIT_VERSION=(${(s/./)1})
  INSTALLED_GIT_VERSION=($(command git --version 2>/dev/null))
  INSTALLED_GIT_VERSION=(${(s/./)INSTALLED_GIT_VERSION[3]})

  for i in {1..3}; do
    if [[ $INSTALLED_GIT_VERSION[$i] -gt $INPUT_GIT_VERSION[$i] ]]; then
      echo 1
      return 0
    fi
    if [[ $INSTALLED_GIT_VERSION[$i] -lt $INPUT_GIT_VERSION[$i] ]]; then
      echo -1
      return 0
    fi
  done
  echo 0
}

# This is unlikely to change so make it all statically assigned
POST_1_7_2_GIT=$(git_compare_version "1.7.2")
# Clean up the namespace slightly by removing the checker function
unfunction git_compare_version
