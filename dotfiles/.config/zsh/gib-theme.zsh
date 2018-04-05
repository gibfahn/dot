#!/usr/bin/env zsh

# %F{1} style variables are zsh variables, test them with:
# print -P '%F{214}%K{123}%m%k%f' (see man zshmisc: EXPANSION OF PROMPT SEQUENCES).
# Added in zsh 4.3.7.

# Good prompt options:  ▶ ► ❯ ➜ ⇉ ⇏ ⇛ ⇝ ⇨ ⇶ 🢂  ⭆  ➩ ➭ 🡆 🠞 ⇻

PROMPT="$([ "$SSH_CLIENT" -o "$SSH_TTY" ] && echo "%F{161}%m%f ")%(?:%K{46}:%K{196})%F{0}···%(?:%F{46}:%F{196})%k%f "

# Uncomment this line if you want a less visible prompt or use a font that doesn't support the triangle glyph ().
# PROMPT="$([ "$SSH_CLIENT" -o "$SSH_TTY" ] && echo "%F{161}%m%f ")%(?:%F{46}:%F{196})···❯%f "

# Put full path and git info on right of prompt.
RPROMPT='%(?:%F{28}:%F{88})%~%f%F{14}$timer_prompt%f$(_git_prompt_info_gib)'

# Record the time at which the command began before zsh executes the command.
preexec() { unset timer_prompt; timer="${timer:-$SECONDS}"; }

# Log the time the command took if at least 1s before zsh shows the result of the command.
precmd() { [ "$timer" -a "$SECONDS" != "$timer" ] && timer_prompt=" $(($SECONDS - $timer))s" || unset timer_prompt; unset timer; }

# Timeout a command after $1 microseconds (returns 142 exit code if it times out).
_timeout() {
  perl -e 'use Time::HiRes "ualarm"; ualarm shift; exec @ARGV' "$@"
}

# Outputs current branch info in prompt format
_git_prompt_info_gib() {
  [[ -d .git || "$(_timeout 100000 git rev-parse --is-inside-work-tree 2>/dev/null; echo $?)" =~ '0|142' ]] &&
    echo " %F{33}(%F{226}$(_git_upstream_diff_gib)%F{33}$(timeout 100000 git describe --contains --all --always HEAD 2>/dev/null || echo "?")$(_parse_git_dirty_gib)%F{33})%f"
}

# Checks if working tree is dirty
_parse_git_dirty_gib() {
  local git_status
  git_status="$(_timeout 100000 git status --porcelain --ignore-submodules=none 2> /dev/null | tail -n1)"
  [ "$?" = 142 ] && echo "%F{226}¿"
  [ "$git_status" ] && echo "%F{226}✦"
}

_git_upstream_diff_gib() {
  local -a diff; diff=($(_timeout 100000 git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null))
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
