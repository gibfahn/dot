#!/bin/bash

# Both arrow and path are green if $? == 0, and red otherwise.
local arrow="%(?:%{$fg_bold[green]%}❯:%{$fg_bold[red]%}❯)%{$reset_color%}" # Green arrow if $? is 0, red otherwise.
local fullPath="%(?:%{$fg[green]%}%~:%{$fg[red]%}%~)%{$reset_color%}" # Green if $? is 0, red otherwise.

PROMPT='${arrow} '

# Prompt has hostname when you're ssh'ed in to a machine.
if [ "$SSH_CLIENT" -o "$SSH_TTY" ]; then
  PROMPT='%{$fg_bold[magenta]%}%m%{$reset_color%} ${arrow} '
fi

# * means directory is dirty (uncommitted changes).
RPROMPT='${fullPath}$(git_prompt_info)' # Put full path and git info on right of prompt.

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg_bold[blue]%}(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%}*%{$fg[blue]%})"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

