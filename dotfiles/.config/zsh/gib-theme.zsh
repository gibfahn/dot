#!/usr/bin/env zsh

[[ -n "$ssh" ]] || PROMPT="%m " # Set fallback PROMPT in case the below script fails.
PROMPT=$'\n%{\e[38;5;161m%}'"${PROMPT}"$'%{\e[38;5;242m···❯\e[0m%} '

source "$XDG_DATA_HOME/zsh/zsh-async/async.zsh" || return # Async functions used here.

# Based on Pure by Sindre Sorhus (https://github.com/sindresorhus/pure, MIT License)

# %F{1} style variables are zsh variables, test them with:
# print -P '%F{214}%K{123}%m%k%f' (see man zshmisc: EXPANSION OF PROMPT SEQUENCES).
# Added in zsh 4.3.7.

_gib_prompt_format_duration() { # Turns seconds into human readable time (165392 => 1d 21h 56m 32s)
  local output total_secs="$1" var="$2"
  local days=$((total_secs/60/60/24)) hours=$((total_secs/60/60%24)) mins=$((total_secs/60%60)) secs=$((total_secs%60))
  (( days > 0 )) && output+="${days}d "
  (( hours > 0 )) && output+="${hours}h "
  (( mins > 0 )) && output+="${mins}m "
  output+="${secs}s"
  typeset -g "${var}"="${output}" # store output readable time in variable as specified by caller
}

# Stores (into _gib_prompt_cmd_exec_time) the exec time of the last command if set threshold was exceeded
_gib_prompt_check_cmd_exec_time() {
  integer elapsed
  (( elapsed = EPOCHSECONDS - ${_gib_prompt_cmd_timestamp:-$EPOCHSECONDS} ))
  typeset -g _gib_prompt_cmd_exec_time=
  (( elapsed > 1 )) && _gib_prompt_format_duration $elapsed "_gib_prompt_cmd_exec_time"
}

# Run before the prompt is displayed.
_gib_prompt_precmd() {
  # Set window title to current directory.
  print -P "\e]2;%1~\a"
  # printf "\e]2;%s\a" "${PWD/#$HOME/~}"
  # check exec time and store it in a variable
  _gib_prompt_check_cmd_exec_time
  unset _gib_prompt_cmd_timestamp

  # preform async git dirty check and fetch
  _gib_prompt_async_tasks

  # print the preprompt
  _gib_prompt_preprompt_render "precmd"
}

# Run between user hitting Enter key, and command being run.
_gib_prompt_preexec() {
  printf '\033[2 q' # Reset prompt to normal mode.
  # Set window title to first word of exec command.
  [[ "$PWD" == "$HOME" ]] && printf "\e]2;%s\a" "${1%% *}"
  if [[ -n $_gib_prompt_git_fetch_pattern ]]; then
    # detect when git is performing pull/fetch (including git aliases).
    local -H MATCH MBEGIN MEND match mbegin mend
    if [[ $2 =~ (git|hub)\ (.*\ )?($_gib_prompt_git_fetch_pattern)(\ .*)?$ ]]; then
      # we must flush the async jobs to cancel our git fetch in order
      # to avoid conflicts with the user issued pull / fetch.
      async_flush_jobs '_gib_prompt'
    fi
  fi
  typeset -g _gib_prompt_cmd_timestamp=$EPOCHSECONDS
}

# string length ignoring ansi escapes
_gib_prompt_string_length_to_var() {
  local str=$1 var=$2 length
  # perform expansion on str and check length
  length=$(( ${#${(S%%)str//(\%([KF1]|)\{*\}|\%[Bbkf])}} ))

  # store string length in variable as specified by caller
  typeset -g "${var}"="${length}"
}

_gib_prompt_preprompt_render() {
  setopt localoptions noshwordsplit

  # Set color for git branch/dirty status, change color if dirty checking has been delayed.
  local git_color=33
  [[ -n ${_gib_prompt_git_last_dirty_check_timestamp+x} ]] && git_color=242

  # Initialize the preprompt array.
  local git_prompt_parts

  # Git pull/push arrows.
  [[ -n "$_gib_prompt_git_arrows" ]] && git_prompt_parts='%F{226}${_gib_prompt_git_arrows}%f'

  # Add git branch and dirty status info.
  typeset -gA _gib_prompt_git
  [[ -n $_gib_prompt_git[branch] ]] && git_prompt_parts+="%F{$git_color}"'${_gib_prompt_git[branch]}%F{226}${_gib_prompt_git_dirty}%f'

  [[ -n "$git_prompt_parts" ]] && git_prompt_parts="%F{33}($git_prompt_parts%F{33})%f"
  [[ -n "$_gib_prompt_cmd_exec_time" ]] && _gib_prompt_cmd_exec_time="%F{14}$_gib_prompt_cmd_exec_time%f"

  # Add python virtualenv setting to RPROMPT if set.
  local venv=''
  [[ -n "$VIRTUAL_ENV" ]] && venv="%F{242}(${VIRTUAL_ENV##*/})%f"

  local -ah rprompt_parts
  rprompt_parts=(
    $venv
    "%(?:%F{28}:%F{88})%~%f"    # Path to cwd (green or red depending on previous command $?).
    $_gib_prompt_cmd_exec_time  # Command execution time (if more than 1s).
    $git_prompt_parts           # Git info.
  )

  [[ -z "$NORPROMPT" ]] && RPROMPT="${(j. .)rprompt_parts}" # Join up parts (space separated).

  # Expand the prompt for future comparision.
  local expanded_rprompt
  expanded_rprompt="${(S%%)RPROMPT}"

  if [[ $1 != precmd && $_gib_prompt_last_rprompt != $expanded_rprompt ]]; then
    # Redraw the prompt.
    zle && zle .reset-prompt
  fi

  typeset -g _gib_prompt_last_rprompt="$expanded_rprompt"
}

_gib_prompt_async_git_aliases() {
  setopt localoptions noshwordsplit
  local dir=$1
  local -a gitalias pullalias

  # we enter repo to get local aliases as well.
  builtin cd -q $dir

  # list all aliases and split on newline.
  gitalias=(${(@f)"$(command git config --get-regexp "^alias\.")"})
  for line in $gitalias; do
    parts=(${(@)=line})           # split line on spaces
    aliasname=${parts[1]#alias.}  # grab the name (alias.[name])
    shift parts                   # remove aliasname

    # check alias for pull or fetch (must be exact match).
    if [[ $parts =~ ^(.*\ )?(pull|fetch)(\ .*)?$ ]]; then
      pullalias+=($aliasname)
    fi
  done

  print -- ${(j:|:)pullalias}  # join on pipe (for use in regex).
}

_gib_prompt_async_vcs_info() {
  setopt localoptions noshwordsplit
  builtin cd -q $1 2>/dev/null

  # configure vcs_info inside async task, this frees up vcs_info
  # to be used or configured as the user pleases.
  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:*' use-simple true
  # only export two msg variables from vcs_info
  zstyle ':vcs_info:*' max-exports 2
  # export branch (%b) and git toplevel (%R)
  zstyle ':vcs_info:git*' formats '%b' '%R'
  zstyle ':vcs_info:git*' actionformats '%b|%a' '%R'

  vcs_info

  local -A info
  info[top]=$vcs_info_msg_1_
  info[branch]=$vcs_info_msg_0_

  print -r - ${(@kvq)info}
}

# fastest possible way to check if repo is dirty
_gib_prompt_async_git_dirty() {
  setopt localoptions noshwordsplit
  local untracked_dirty=$1 dir=$2

  # use cd -q to avoid side effects of changing directory, e.g. chpwd hooks
  builtin cd -q $dir

  if [[ $untracked_dirty = 0 ]]; then
    command git diff --no-ext-diff --quiet --exit-code
  else
    test -z "$(command git status --porcelain --ignore-submodules -unormal)"
  fi

  return $?
}

_gib_prompt_async_git_fetch() {
  setopt localoptions noshwordsplit
  # use cd -q to avoid side effects of changing directory, e.g. chpwd hooks
  builtin cd -q $1

  # set GIT_TERMINAL_PROMPT=0 to disable auth prompting for git fetch (git 2.3+)
  export GIT_TERMINAL_PROMPT=0
  # set ssh BachMode to disable all interactive ssh password prompting
  export GIT_SSH_COMMAND=${GIT_SSH_COMMAND:-"ssh -o BatchMode=yes"}

  command git -c gc.auto=0 fetch &>/dev/null || return 99

  # check arrow status after a successful git fetch
  _gib_prompt_async_git_arrows $1
}

_gib_prompt_async_git_arrows() {
  setopt localoptions noshwordsplit
  builtin cd -q $1
  command git rev-list --left-right --count HEAD...@'{u}'
}

_gib_prompt_async_tasks() {
  setopt localoptions noshwordsplit

  # initialize async worker
  ((!${_gib_prompt_async_init:-0})) && {
    async_start_worker "_gib_prompt" -u -n
    async_register_callback "_gib_prompt" _gib_prompt_async_callback
    typeset -g _gib_prompt_async_init=1
  }

  typeset -gA _gib_prompt_git

  local -H MATCH MBEGIN MEND
  if ! [[ $PWD = ${_gib_prompt_git[pwd]}* ]]; then
    # stop any running async jobs
    async_flush_jobs "_gib_prompt"

    # reset git preprompt variables, switching working tree
    unset _gib_prompt_git_dirty
    unset _gib_prompt_git_last_dirty_check_timestamp
    unset _gib_prompt_git_arrows
    unset _gib_prompt_git_fetch_pattern
    _gib_prompt_git[branch]=
    _gib_prompt_git[top]=
  fi
  unset MATCH MBEGIN MEND

  async_job "_gib_prompt" _gib_prompt_async_vcs_info $PWD

  # # only perform tasks inside git working tree
  [[ -n $_gib_prompt_git[top] ]] || return

  _gib_prompt_async_refresh
}

_gib_prompt_async_refresh() {
  setopt localoptions noshwordsplit

  if [[ -z $_gib_prompt_git_fetch_pattern ]]; then
    # we set the pattern here to avoid redoing the pattern check until the
    # working three has changed. pull and fetch are always valid patterns.
    typeset -g _gib_prompt_git_fetch_pattern="pull|fetch"
    async_job "_gib_prompt" _gib_prompt_async_git_aliases $working_tree
  fi

  async_job "_gib_prompt" _gib_prompt_async_git_arrows $PWD

  # do not preform git fetch if it is disabled or working_tree == HOME
  if (( ${PURE_GIT_PULL:-1} )) && [[ $working_tree != $HOME ]]; then
    # tell worker to do a git fetch
    async_job "_gib_prompt" _gib_prompt_async_git_fetch $PWD
  fi

  # if dirty checking is sufficiently fast, tell worker to check it again, or wait for timeout
  integer time_since_last_dirty_check=$(( EPOCHSECONDS - ${_gib_prompt_git_last_dirty_check_timestamp:-0} ))
  if (( time_since_last_dirty_check > ${PURE_GIT_DELAY_DIRTY_CHECK:-1800} )); then
    unset _gib_prompt_git_last_dirty_check_timestamp
    # check check if there is anything to pull
    async_job "_gib_prompt" _gib_prompt_async_git_dirty ${PURE_GIT_UNTRACKED_DIRTY:-1} $PWD
  fi
}

_gib_prompt_check_git_arrows() {
  setopt localoptions noshwordsplit
  local arrows left=${1:-0} right=${2:-0}

  (( right > 0 )) && arrows+=${PURE_GIT_DOWN_ARROW:-⇣}
  (( left > 0 )) && arrows+=${PURE_GIT_UP_ARROW:-⇡}

  [[ -n $arrows ]] || return
  typeset -g REPLY=$arrows
}

_gib_prompt_async_callback() {
  setopt localoptions noshwordsplit
  local job=$1 code=$2 output=$3 exec_time=$4 next_pending=$6
  local do_render=0

  case $job in
    _gib_prompt_async_vcs_info)
      local -A info
      typeset -gA _gib_prompt_git

      # parse output (z) and unquote as array (Q@)
      info=("${(Q@)${(z)output}}")
      local -H MATCH MBEGIN MEND
      # check if git toplevel has changed
      if [[ $info[top] = $_gib_prompt_git[top] ]]; then
        # if stored pwd is part of $PWD, $PWD is shorter and likelier
        # to be toplevel, so we update pwd
        if [[ $_gib_prompt_git[pwd] = ${PWD}* ]]; then
          _gib_prompt_git[pwd]=$PWD
        fi
      else
        # store $PWD to detect if we (maybe) left the git path
        _gib_prompt_git[pwd]=$PWD
      fi
      unset MATCH MBEGIN MEND

      # update has a git toplevel set which means we just entered a new
      # git directory, run the async refresh tasks
      [[ -n $info[top] ]] && [[ -z $_gib_prompt_git[top] ]] && _gib_prompt_async_refresh

      # always update branch and toplevel
      _gib_prompt_git[branch]=$info[branch]
      _gib_prompt_git[top]=$info[top]

      do_render=1
      ;;
    _gib_prompt_async_git_aliases)
      if [[ -n $output ]]; then
        # append custom git aliases to the predefined ones.
        _gib_prompt_git_fetch_pattern+="|$output"
      fi
      ;;
    _gib_prompt_async_git_dirty)
      local prev_dirty=$_gib_prompt_git_dirty
      (( code == 0 )) && unset _gib_prompt_git_dirty || typeset -g _gib_prompt_git_dirty="✦"

      [[ "$prev_dirty" != "$_gib_prompt_git_dirty" ]] && do_render=1

      # When _gib_prompt_git_last_dirty_check_timestamp is set, the git info is displayed in a different color.
      # To distinguish between a "fresh" and a "cached" result, the preprompt is rendered before setting this
      # variable. Thus, only upon next rendering of the preprompt will the result appear in a different color.
      (( $exec_time > 5 )) && _gib_prompt_git_last_dirty_check_timestamp=$EPOCHSECONDS
      ;;
    _gib_prompt_async_git_fetch|_gib_prompt_async_git_arrows)
      # _gib_prompt_async_git_fetch executes _gib_prompt_async_git_arrows after a successful fetch.
      if (( code == 0 )); then
        local REPLY
        _gib_prompt_check_git_arrows ${(ps:\t:)output}
        if [[ $_gib_prompt_git_arrows != $REPLY ]]; then
          typeset -g _gib_prompt_git_arrows=$REPLY
          do_render=1
        fi
      elif (( code != 99 )); then
        # Unless the exit code is 99, _gib_prompt_async_git_arrows
        # failed with a non-zero exit status, meaning there is no
        # upstream configured.
        if [[ -n $_gib_prompt_git_arrows ]]; then
          unset _gib_prompt_git_arrows
          do_render=1
        fi
      fi
      ;;
  esac

  if (( next_pending )); then
    (( do_render )) && typeset -g _gib_prompt_async_render_requested=1
    return
  fi

  [[ ${_gib_prompt_async_render_requested:-$do_render} = 1 ]] && _gib_prompt_preprompt_render
  unset _gib_prompt_async_render_requested
}

_gib_prompt_setup() {
  # Prevent percentage showing up if output doesn't end with a newline.
  export PROMPT_EOL_MARK=''

  # Sets prompt options.
  setopt noprompt{bang,cr,percent,subst} prompt{subst,percent}

  zmodload zsh/datetime
  zmodload zsh/zle
  zmodload zsh/parameter

  autoload -Uz add-zsh-hook
  autoload -Uz vcs_info
  autoload -Uz async && async

  add-zsh-hook precmd _gib_prompt_precmd
  add-zsh-hook preexec _gib_prompt_preexec

  # Good prompt options:  ▶ ► ❯ ➜ ⇉ ⇏ ⇛ ⇝ ⇨ ⇶ 🢂  ⭆  ➩ ➭ 🡆 🠞 ⇻
  # Prompt turns red if the previous command didn't exit with 0
  PROMPT=$'\n'

  PROMPT+="%(#:%F{202}%n@%m :%F{161})"
  [[ -n "$ssh" ]] && PROMPT+="%m%f "
  PROMPT+="%(?:%F{46}:%F{196})···❯%f "
}

_gib_prompt_setup "$@"
