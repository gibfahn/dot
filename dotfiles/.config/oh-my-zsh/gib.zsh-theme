#!/bin/bash

# If you want to edit this theme, just play with the variables. local variables
# are just building blocks for prompts. Uses the colours defined in oh-my-zsh.

# Choose a prompt character, I like something fat.
local arrow='▶' # Good options: ▶ ❯ ➜ ⇉ ⇏ ⇛ ⇝ ⇨ ⇶ 🢂  ⭆  ➩ ➭ 🡆 🠞 ⇻

# Green arrow if $? is 0, red otherwise:
local colourArrow="%(?:%{$fg_bold[green]%}$arrow:%{$fg_bold[red]%}$arrow)%{$reset_color%}"
# Green full path if $? is 0, red otherwise:
local fullPath="%(?:%{$fg[green]%}%~:%{$fg[red]%}%~)%{$reset_color%}"

# Left prompt is just the arrow (1st column so easy to find).
PROMPT='${colourArrow} '

# Prompt has magenta hostname when you're ssh'ed in to a machine.
if [ "$SSH_CLIENT" -o "$SSH_TTY" ]; then
  PROMPT='%{$fg_bold[magenta]%}%m%{$reset_color%} ${colourArrow} '
fi

# Put full path and git info on right of prompt.
RPROMPT='${fullPath}$(git_prompt_info)'

# * in right prompt means directory is dirty (uncommitted changes).
ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg_bold[blue]%}(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%}*%{$fg[blue]%})"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

