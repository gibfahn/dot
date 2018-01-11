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
git_prompt_info_gib() {
  [ -d .git -o "$(command git rev-parse --is-inside-work-tree 2>/dev/null)" ] &&
    echo " %F{33}(%F{226}$(upstream_diff_gib)%F{33}$(command git describe --contains --all HEAD)$(parse_git_dirty_gib)%F{33})%f"
}

# Checks if working tree is dirty
parse_git_dirty_gib() {
  [ "$(command git status --porcelain --ignore-submodules=none 2> /dev/null | tail -n1)" ] && echo "%F{226}✦"
}

upstream_diff_gib() {
  local -a diff; diff=($(command git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null))
  if [ "$?" != 0 ]; then
    printf !
  # zsh arrays start at 1 not 0.
  elif [ "${diff[1]}" != 0 -a "${diff[2]}" != 0 ]; then
    printf ⇣⇡
  elif [ "${diff[1]}" != 0 -a "${diff[2]}" = 0 ]; then
    printf ⇡
  elif [ "${diff[2]}" != 0 -a "${diff[1]}" = 0 ]; then
    printf ⇣
  fi
}
