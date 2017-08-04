#!/bin/bash

local arr1="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )" # Green arrow if $? is 0, red otherwise.
local arr2="%(?:%{$fg_bold[green]%}❯ :%{$fg_bold[red]%}❯ )" # Green arrow if $? is 0, red otherwise.

PROMPT='${arr1} %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info) ${arr2} '

if [ "$SSH_CLIENT" -o "$SSH_TTY" ]; then # Different prompt with hostname for when you're ssh'ed in to a machine.
  PROMPT='${arr1} %{$fg[magenta]%}%m%{$reset_color%}
  %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info) ${arr2} '
fi

RPROMPT='%~' # Put full path on right of prompt.

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

