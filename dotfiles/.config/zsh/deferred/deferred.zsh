# {{{ Environment Variables

export ATOM_HOME="$XDG_DATA_HOME"/atom # Atom data goes here.
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME/aws/config"
export AWS_SHARED_CREDENTIALS_FILE="$HOME/.ssh/tokens/aws/credentials"
export BABEL_CACHE_PATH=${BABEL_CACHE_PATH="$XDG_CACHE_HOME/babel/cache.json"} # Set babel cache location.
export BAT_THEME="TwoDark" # Set the default theme for bat and delta.
export CCACHE_CONFIGPATH="$XDG_CONFIG_HOME"/ccache.config
export CCACHE_DIR="$XDG_CACHE_HOME"/ccache # Ccache cache.
export COURSIER_CREDENTIALS="$XDG_CONFIG_HOME/coursier/credentials.properties"
export FZF_ALT_C_COMMAND='fd --type d --hidden --no-ignore --follow --exclude .git'
export FZF_CTRL_R_OPTS="--height=100% --preview-window=down:30%:noborder --preview 'file-preview - --language=zsh -- <<<\$(echo {2..})', --bind='ctrl-y:execute(${aliases[cpy]} <<< {2..})'"
export FZF_CTRL_T_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_OPTS="--height=100% --preview-window=right:60%:noborder"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git' # Use fd for fuzzy finding if available.
# Ctrl-a -> select/deselect all, Ctrl-y -> copy line, Alt-s -> sneak to line, Alt-Shift-s -> sneak to line + enter, Ctrl-p is open/close preview window.
export FZF_DEFAULT_OPTS="--select-1 --exit-0 --preview-window=right:50% --preview 'file-preview {}' -m --bind='ctrl-o:execute(\$VISUAL {} </dev/tty >/dev/tty),ctrl-a:toggle-all,ctrl-s:toggle-sort,alt-w:toggle-preview-wrap,alt-s:jump,alt-up:half-page-up,alt-down:half-page-down,alt-S:jump-accept,ctrl-p:toggle-preview,ctrl-y:execute(${aliases[cpy]} <<< {})'"
export GNUPGHOME="$XDG_DATA_HOME"/gnupg # Gpg data.
export GRADLE_USER_HOME="$XDG_DATA_HOME"/gradle # Also contains gradle.properties (symlink from XDG_CONFIG_HOME).
export HELM_HOME="$XDG_DATA_HOME/helm" # Move Helm data dir from ~.
export HTTPIE_CONFIG_DIR="$XDG_CONFIG_HOME/httpie" # https://github.com/jakubroztocil/httpie/issues/145
export IPYTHONDIR="$XDG_CACHE_HOME/ipython" # Move iPython dir from ~.
export LESSHISTFILE="$XDG_CACHE_HOME/less/history" # Get less to put its history here.
export LESSKEY="$XDG_CACHE_HOME/less" # Less color settings.
export MINIKUBE_HOME="$XDG_CACHE_HOME/minikube" # https://github.com/kubernetes/minikube/issues/4109
export NODE_REPL_HISTORY="$XDG_CACHE_HOME/node_repl_history" # Set node-gyp download location.
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm" # Set npm cache location.
export NPM_CONFIG_DEVDIR="$XDG_CACHE_HOME/node-gyp" # Set node-gyp download location.
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/config" # Set up my npm config location.
export OP_BIOMETRIC_UNLOCK_ENABLED=true # https://developer.1password.com/docs/cli/app-integration/#set-the-biometric-unlock-environment-variable
export PAGER=less
export PEX_ROOT="$XDG_CACHE_HOME/pex" # Cache directory for https://github.com/pantsbuild/pex.
export RBENV_ROOT="$XDG_CACHE_HOME/rbenv" # Set rbenv location.
export RUSTUP_HOME="$XDG_DATA_HOME/rustup" # Rustup goes here.
export SCCACHE_DIR="$XDG_CACHE_HOME/sccache" # sccache cache dir.
export TIME_STYLE=long-iso # See `man gls` on macOS, sets the time style for `ls -l`.
export VIRTUAL_ENV_DISABLE_PROMPT=1 # Add the virtualenv prompt myself.

_LESS=(
  --tabs=4 # tab is 4 spaces
  --ignore-case # smartcase search
  --Raw-control-chars # show colors,
  --quit-if-one-screen # exit if file fits in one screen
  --Long-prompt # verbose prompt
  --Hilite-unread # highlight first unread line moving
  --window=-4 # keep 4 lines overlapping when scrolling with the space key
)
export LESS=${_LESS[*]}
unset _LESS

[[ -d "$XDG_CONFIG_HOME/terminfo" ]] && export TERMINFO="$XDG_CONFIG_HOME/terminfo" # Put terminal info in here.

CDPATH=~ # Check ~ for directories after checking . (`c/d/` matches `./c*/d*/`, then tries `~/c*/d*/`).
HELPDIR=$brew_prefix/share/zsh/help # Used in run-help below.
[[ $TERM == xterm ]] && TERM=xterm-256color

# }}} Environment Variables

# {{{ Aliases

# Make help work <https://superuser.com/questions/1563825/is-there-a-zsh-equivalent-to-the-bash-help-builtin>
unalias run-help # Remove unuseful built-in `alias run-help=man`
autoload -Uz run-help # Load better run-help function.
alias help=run-help # `help export` for help on the export builtin.

(( $+commands[gsed] )) && alias sed=gsed
# fda is find all (don't ignore anything).
(( $+commands[fd] )) && alias fda='fd --no-ignore --hidden --exclude=.git' || fd() { find . -iname "*$**"; } # Find by filename (case insensitive).
(( $+commands[rg] )) && alias rg='rg --smart-case' rga='rg --smart-case --hidden --no-ignore --glob=!.git' # rga is grep all (don't ignore anything).
# Footgun, means your shell has sudo privileges forever, make sure you only use this for a single command, after that exit the shell.
# e.g. sudo_later; sleep 1000; sudo halt
alias sudo_later="sudo -v; (while sudo -v; do sleep 60; done) &" # Preserve sudo for a command you'll run later.
alias bounce="echo -n '\a'" # Ring the terminal bell (bounce the dock icon in macOS).
alias pstree="pstree -g 3" # Use the nicest pstree output (unicode).
# Run command every $1 seconds until it succeeds, e.g. `every 60 curl https://example.com`
every() { local delay=${1?}; shift; while ! "$@"; do sleep $delay; echo "❯ $*"; done; }

alias c=cargo ru=rustup  # Rust commands (try `c b`, `c r`, `c t`).
rs() { for i in "$@"; do rustc "${i%.rs}.rs"; ./"${i%.rs}"; done; } # Compile/run (rs a.rs b).
# .. = up 1 dir, ... = up 2 dirs, .... = up 3 dirs (etc.). - = go to last dir.
alias next='git next && git show' # Useful for demos.
alias gm='wait; git mf' # After cd'ing into a repo, fetch will run as a background job. Use this to wait for it to finish then mf.
alias we="watchexec" # Shortcut for "run this command when something changes".

# Find-replace everything in the current directory. Use `--` to pass args to fd.
# e.g. 'sda s/foo/bar/g', 'sda --hidden -- s/foo/bar/g'
sda() {
  local arg find=() replace=()
  for arg in "$@"; do
    if [[ $arg == -- ]]; then
      find=("${replace[@]}")
      replace=()
    else
      replace+=("$arg")
    fi
  done
  find=(fd --type file --hidden --exclude .git --print0 "${find[@]}")
  replace=(xargs -0 gsed -i "${replace[@]}")
  echo "Now running:"
  # Painful hack to nicely print the args including the | and any quoted args with spaces in them:
  (set -x; : "${find[@]}" \| "${replace[@]}") 2>&1 | sed -e "s/'|'/|/" -e 's/.*fd/  fd/'
  # Actually run the command:
  "${find[@]}" | "${replace[@]}"
}

# Rename everything in the current directory according to provided sed expression. Use `--` to pass args to fd.
# e.g. 'sdr s/foo/bar/g', 'sdr --hidden -- s/foo/bar/g'
sdr() {
  local arg find=() replace=()
  for arg in "$@"; do
    if [[ $arg == -- ]]; then
      find=("${replace[@]}")
      replace=()
    else
      replace+=("$arg")
    fi
  done
  find=()
  for file_path in "${(@f)$(fd --type file --hidden --exclude .git "${find[@]}")}"; do
    new_path=$(gsed "${replace[@]}" <<<"$file_path")
    if [[ $file_path != "$new_path" ]]; then
      mv -v $file_path $new_path
    fi
  done
}

# Copy last command.
alias clc="fc -ln -1 | sed -e 's/\\\\n/\\n/g' -e 's/\\\\t/\\t/g' | ${=aliases[cpy]}" # "
# Run last command and copy the command and its output.
cr() { local a=$(r 2>&1); ${=aliases[cpy]} <<<"❯ $a"; }

# Yaml to json, e.g. "y2j <t.yml | jq .". Requires a `pip install pyyaml`.
alias j2y="python3 -c 'import sys, yaml, json; yaml.dump(json.load(sys.stdin), sys.stdout, indent=2)'"
alias y2j="python3 -c 'import sys, yaml, json; json.dump(yaml.safe_load(sys.stdin), sys.stdout, indent=2)'"
alias y2y="python3 -c 'import sys, yaml; yaml.dump(yaml.safe_load(sys.stdin), sys.stdout, indent=2)'"
alias t2j="python3 -c 'import sys, toml, json; json.dump(toml.load(sys.stdin), sys.stdout, indent=2)'"
# Markdown to html (rich text).
alias mth="pbpaste | pandoc --from markdown --to html | textutil -convert rtf -stdin -stdout -format html |  pbcopy -Prefer rtf"
# Url encode and decode stdin or first argument.
alias url_encode='python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1] if len(sys.argv) > 1 else sys.stdin.read()[0:-1]))"'
alias url_decode='python3 -c "import urllib.parse, sys; print(urllib.parse.unquote(sys.argv[1] if len(sys.argv) > 1 else sys.stdin.read()[0:-1]))"'
# Convert from UTF-16 to UTF-8
alias utf16_decode='python3 -c "import sys; sys.stdin.reconfigure(encoding=\"utf-16\"); print(sys.stdin.read())"'

if (( $+commands[kitty] )); then
  alias icat="kitty +kitten icat" # Kitty terminal specific: https://sw.kovidgoyal.net/kitty/kittens/icat.html
fi
[[ -x "/Applications/IntelliJ IDEA CE.app/Contents/MacOS/idea" ]] && alias idea="/Applications/IntelliJ IDEA CE.app/Contents/MacOS/idea" # IntelliJ CE
alias curl="noglob curl" # Don't match on ? [] etc in curl URLs, avoids needing to quote URL args.

(( $+commands[ggrep] )) && alias grep='ggrep --color=auto'

# }}} Aliases

# {{{ Functions

# Edit a file on the system.
mdc() { command mkdir -p "$@"; { [[ $# == 1 ]] && cd "$1"; } || true; } # Mkdir then cd to dir (`mdc foo` = `mkdir foo && cd foo`).
cpm() { command mkdir -p "${@: -1}" && cp "$@"; } # Mkdir then cp to dir (`cpm foo bar` = `md bar && cp foo bar`).
mvm() { command mkdir -p "${@: -1}" && mv "$@"; } # Mkdir then mv to dir (`mvm foo bar` = `md bar && mv foo bar`).

pth() { # Returns absolute path to each file or dir arg.
  local i
  for i in "$@"; do
    if [[ -d "$i" ]]; then (pushd "$i" >/dev/null || return 1; pwd) # dir.
    elif [[ -f "$i" ]]; then  # file.
      case $i in
        */*) echo "$(pushd "${i%/*}" >/dev/null || return 1; pwd)/${i##*/}" ;;
          *) echo "$PWD/$i" ;;
      esac
    fi
  done
}

# Add a trailing newline to all files in the current directory.
add_trailing_newline() {
  fd --hidden --exclude=.git --type f "$@" -x gsed -i -e '$a\' '{}'
}

# Remove trailing whitespace from all files in the current directory.
remove_trailing_whitespace() {
  fd --hidden --exclude=.git --type f "$@" -x gsed -i -e 's/\s\+$//' '{}'
}

# Convert tabs to spaces for all files in the current directory.
# $1: spaces per tab, defaults to 4.
tabs_to_spaces() {
  spaces_per_tab=${1:-4}
  fd --hidden --exclude=.git --type f -x bash -c "gexpand -i -t $spaces_per_tab {} | sponge {}"
}

# Get the App Bundle ID of a macOS/iOS/etc app, using an app store link, or an app on the system.
# Useful for adding to 1Password: https://www.reddit.com/r/1Password/comments/hk02p7/suggestions_in_apps_for_1password_for_macos/.
# Refs: StackOverflow (https://stackoverflow.com/questions/27509838/how-to-get-bundle-id-of-ios-app-either-using-ipa-file-or-app-installed-on-iph)
# Usage:
#   apple_app_bundleid https://apps.apple.com/us/app/watch/id1069511734
#   apple_app_bundleid https://apps.apple.com/gb/app/clubspark-booker/id1028325841
#   apple_app_bundleid /Applications/kitty.app
apple_app_bundleid() {
  case $1 in;
    https://*) # Assume URL (Google for the app, copy URL).
      country=$(sed -E 's;https://apps.apple.com/([^/]+)/.*;\1;' <<<"$1")
      # Assumes links like https://apps.apple.com/us/app/magic-the-gathering-arena/id1496227521#?platform=ipad
      id=$(sed -E 's;.*/id([0-9]+).*;\1;' <<<"$1")
      curl "https://itunes.apple.com/${country}/lookup?id=${id}" | jq -r '"app://\(.results[0].bundleId)"'
      ;;
    *) # Assume App Name / Path.
      id=$1
      echo "app://$(osascript -e "id of app \"$1\"")"
      ;;
  esac
}

# Show which apps made a noise in the last 30 minutes.
# Refs:
# - <https://dreness.com/blog/archives/155773>
# - <https://gist.github.com/dreness/1de1def13c83d19630ab0646ba8f0597>
mac_recent_audio_notifications() {
  log show --info --last 30m --predicate 'senderImagePath = "/usr/sbin/systemsoundserverd"' --style compact | awk '/Incoming Request/ {print $1 ":" $2 " " $14}'
}

# Extract an OCI Archive to a local directory for debugging (doesn't handle everything).
oci_extract() {
  setopt local_options err_return no_unset
  tarball=${1:?Missing argument #1: docker tarball}
  local tempdir=$(mktemp -d) exit_code=0

  tar -xzf $tarball -C $tempdir
  cd $tempdir
  mkdir root

  cat manifest.json | jq -r '.[].Layers[]' | while read layer; do
    if ! tar -xzf $layer -C root; then
      echo "Encountered error while extracting layer - continuing on best-effort basis"
      exit_code=1
    fi
  done

  echo "Docker image extracted in: $tempdir/root"
  return $exit_code
}

# Clone repo and cd into path (can't be in git config as we cd).
gcl() {
  local clone_dir ret
  clone_dir="$(set -o pipefail; git cl --progress "$@" 3>&1 1>&2 2>&3 3>&- | tee /dev/stderr | awk -F \' '/Cloning into/ {print $2}' | head -1)"
  ret="$?"
  [[ -d "$clone_dir" ]] && echo "cd $clone_dir" && cd "$clone_dir" || return 1
  return $ret
}

# Open vim with the results of the last rg/rga command in the quickfix list.
rv() {
  local cmd history_line
  history_line=$(fc -lr -100 | awk '$2 == "rg" || $2 == "rga" { print $1; exit; }')
  [[ -z "$history_line" ]] && { echo "No rg in the last 100 history commands."; return 1; }
  eval cmd="($history[$history_line])"
  # Remove 1st item (rg or rga) and replace with rg + flags, then the rest of the cmd array.
  if [[ ${cmd[1]} == rga ]]; then
    cmd=(rg --hidden --no-ignore --glob=!.git --smart-case --vimgrep "${(@)cmd[2,$#cmd]}")
  else
    cmd=(rg --glob=!.git --smart-case --vimgrep "${(@)cmd[2,$#cmd]}")
  fi

  # Use =() not <() to work around https://github.com/neovim/neovim/issues/21756
  "$=VISUAL" -q =("${cmd[@]}")
}

# vim quickfix: copy a set of file:line lines then run to populate the quickfix list.
vq() {
  ${=aliases[v]} +copen +"cexpr(getreg('+'))"
}

# Interactive move to trash..
# dli -> interactive delete files in current directory.
# dli foo/* bar/* -> interactive delete files in foo and bar subdirectories.
dli() {
  { [[ $# == 0 ]] && fd -0d 1 || print -N $@; } | fzf --reverse --read0 --print0 | xargs -0 ${=aliases[dl]}
}

# Backup watch function for machines that don't (yet) have it installed.
if ! type watch &>/dev/null; then
  watch() {
    while true; do
      clear
      echo "Running: $*"
      $@
      sleep 2
    done
  }
fi

# Generate an alphanumeric password $1 characters long.
password_gen() {
  cat /dev/urandom | LC_ALL=C tr -dc '[:alnum:]' | fold -w ${1?Missing argument 1: password length} | head -1 | tr -d '\n'
}

chpwd() { # Commands to run after changing directory (via cd or pushd).
  [[ -t 1 ]] || return # Exit if stdout is not a tty.
  setopt local_options no_monitor # This only disables the "job start", not the "job complete".
  # I know I set the ls alias earlier, so use that.
  ${=aliases[ls]} -A 1>&2 # Show dir contents.
  [[ -d .git ]] && git fetch --all --quiet & # Fetch git remotes.
  # Add new entries to the zoxide database.
  # Anything started with /Volumes/Shared-Data/ is a shared mount, see up/run/mac_volume
  zoxide add -- "${PWD#/Volumes/Shared-Data}"
}

# }}} Functions

# {{{ Run commands

command mkdir -p ${HISTFILE:h} # Create HISTFILE dir if necessary.

# ulimit -c unlimited # Uncomment to allow saving of coredumps.

# Don't send SIGTTOU to background jobs that write to the tty. Theoretically fixes this in busy commands:
# [1]  + 82656 suspended (tty output)  cargo run
# stty -tostop

# Set key repeat rate if available (Linux only). You probably want something less excessive here, like rate 250 30.
if [[ $OSTYPE = linux* ]]; then
  (( $+commands[xset] )) && xset r rate 120 45
fi

# }}} Run Commands

# {{{ Source scripts and Completions

# Source my other scripts.
source $XDG_CONFIG_HOME/zsh/deferred/macos-setdir.zsh
[[ -e $XDG_CONFIG_HOME/zsh/deferred/apple.zsh ]] && source $XDG_CONFIG_HOME/zsh/deferred/apple.zsh
[[ -e /Applications/iTerm.app/Contents/Resources/iterm2_shell_integration.zsh ]] && source /Applications/iTerm.app/Contents/Resources/iterm2_shell_integration.zsh

# Source known completions
source $XDG_DATA_HOME/fzf/shell/completion.zsh
source $XDG_DATA_HOME/fzf/shell/key-bindings.zsh
source $XDG_DATA_HOME/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source $XDG_DATA_HOME/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $XDG_DATA_HOME/zsh/plugins/zsh-completions/zsh-completions.plugin.zsh

# Source completions that need to be directly run.
for _gib_file in $XDG_DATA_HOME/zsh/completions/*(N); do
  echo $_gib_file
  source $_gib_file
done
unset _gib_file

# Add completion dirs that don't need to be directly run to the function path.
_gib_fpath_dirs=(
  ${brew_prefix:+$brew_prefix/share/zsh/site-functions} # Brew shell completions if there.
  $XDG_DATA_HOME/zfunc # Put (or symlink) autocomplete scripts in here.
)
for _gib_dir in "${_gib_fpath_dirs[@]}"; do
  [[ -d $_gib_dir ]] && fpath+=("$_gib_dir")
done
unset _gib_dir _gib_fpath_dirs

# }}} Source scripts and Completions

# {{{ Keybindings

# Fzf git files (unstaged).
_gib_git_f() {
  git -c color.status=always status --short |
  fzf "$@" --border -m --ansi --nth 2..,.. \
    --preview 'git diff -- {-1} | delta' | cut -c4- | sed 's/.* -> //'
}

# Fzf git branches.
_gib_git_b() {
  git branch -a --color=always --sort=committerdate --sort=-refname:rstrip=2 \
  | fzf "$@" --border --ansi --multi --tac --preview-window right:70% \
  --preview "git l --color=always \$(awk '{if (\$1 == \"*\") { print \$2 } else { print \$1 } }' <<< {})" \
  --bind "ctrl-o:execute: git li \$(awk '{if (\$1 == \"*\") { print \$2 } else { print \$1 } }' <<< {})" \
  | awk '{if ($1 == "*") { print $2 } else { print $1 } }' | sed 's#^remotes/##'
}

# Fzf git tags.
_gib_git_t() {
  git tag --color=always --sort -version:refname |
  fzf "$@" --border --multi --preview-window right:70% \
    --preview "git l --color=always {}" \
    --bind "ctrl-o:execute: git li {}"
}

# Fzf git hashes.
_gib_git_h() {
  git log --all --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  fzf "$@" --border --ansi --no-sort --reverse --multi --header 'Press CTRL-S to toggle sort' \
    --preview 'git show --color=always $(grep -oE "[a-f0-9]{7,}" <<< {} | head -1) | delta ' \
    --bind 'ctrl-s:toggle-sort' \
    --bind "ctrl-o:execute: git shi \$(grep -oE '[a-f0-9]{7,}' <<< {} | head -1)" \
  | grep -oE "[a-f0-9]{7,}"
}

# Fzf git stashes.
# Can't use ^G^S because it doesn't trigger for some reason.
_gib_git_a() {
  git stash list --color=always |
  fzf "$@" --border --ansi --no-sort --reverse --multi --header 'Press CTRL-S to toggle sort' \
    --preview 'git stash show --patch --color=always $(cut -d : -f 1 <<< {}) | delta ' \
    --bind 'ctrl-s:toggle-sort' \
    --bind "ctrl-o:execute: git shi \$(cut -d : -f 1 <<< {} | head -1)" \
  | cut -d : -f 1
}

# Fzf git reflog history.
_gib_git_r() {
  git reflog --date=short --pretty=oneline --color=always --decorate |
  fzf "$@" --border --ansi --no-sort --reverse --multi --header 'Press CTRL-S to toggle sort' \
    --preview 'git show --color=always $(grep -oE "[a-f0-9]{7,}" <<< {}) | delta ' \
    --bind 'ctrl-s:toggle-sort' \
    --bind "ctrl-o:execute: git shi \$(grep -oE '[a-f0-9]{7,}' <<< {} | head -1)" \
  | grep -oE '[a-f0-9]{7,}'
}

# Fzf run command in path: interactively decide what command to run.
_gib_path_run() {
  (
    # Zsh populates $path array with $PATH directory paths.
    for p in "${path[@]}"; do
      [[ -d $p ]] && ls "$p"
    done
  ) | fzf --preview 'unbuffer man {} || unbuffer {} --help'
}

# Fzf with multi-select from https://github.com/junegunn/fzf/pull/2098
# CTRL-R - Paste the selected command from history into the command line
gib-fzf-history-widget() {
  local selected num selected_line selected_line_arr
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null

  # Read history lines (split on newline) into selected array.
  selected=(
    "${(@f)$(fc -rl 1 | awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\**[ \t]+/, "", cmd); if (!seen[cmd]++) print $0 }' |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort,ctrl-z:ignore $FZF_CTRL_R_OPTS --query=${(qqq)LBUFFER} -m" $(__fzfcmd))}"
  )
  local ret=$?

  # Remove empty elements, converting ('') to ().
  selected=($selected)
  if [[ "${#selected[@]}" -ne 0 ]]; then
    local -a history_lines=()
    for selected_line in "${selected[@]}"; do
      # Split each history line on spaces, and take the 1st value (history line number).
      selected_line_arr=($=selected_line)
      num=$selected_line_arr[1]
      if [[ -n "$num" ]]; then
        # Add history at line $num to history_lines array.
        zle vi-fetch-history -n $num
        history_lines+=("$BUFFER")
        BUFFER=
      fi
    done
    # Set input buffer to newline-separated list of history lines.
    # Use echo to unescape, e.g. \n to newline, \t to tab.
    BUFFER="${(F)history_lines}"
    # Move cursor to end of buffer.
    CURSOR=$#BUFFER
  fi

  zle reset-prompt
  return $ret
}
zle -N gib-fzf-history-widget

# " Fake quote for syntax highlighting plugin issue.

# Copy whole buffer to system clipboard.
gib-yank-all() {
  printf "%s" "$BUFFER" | "${aliases[cpy]}"
}
zle -N gib-yank-all

zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} r:|[.,_-]=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # Use LS_COLORS in file completion menu.
zstyle ':completion:*:*:*:*:*' menu "select" # Make the completion selection menu a proper menu.

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path "$XDG_CACHE_HOME"/zsh

# TODO(gib): Work out why this is slow on Darwin and fix it.
zstyle ':bracketed-paste-magic' active-widgets '.self-*' # https://github.com/zsh-users/zsh-autosuggestions/issues/141

# Vim mode and keybindings in zsh:
autoload -U history-search-end # Not included by default so load (usually /usr/share/zsh/unctions/Zle/).
autoload -Uz edit-command-line # Load command to open current line in $VISUAL.
zle -N edit-command-line
zle -N history-beginning-search-backward-end history-search-end # Add it to existing widgets.
zle -N history-beginning-search-forward-end history-search-end  # Add it to existing widgets.
accept-line() {
  [ -z "$BUFFER" ] && {
    # Only use local items (don't use share_history items).
    zle set-local-history 1
    zle up-history
    zle set-local-history 0
  }
# Run original accept-line builtin command.
zle ".$WIDGET"
}
zle -N accept-line # Redefine accept-line to insert last input if empty (Enter key).

# Bind ^g^p to "interactively choose which binary from the $PATH to run".
_gib_fzf-gp-widget() { local result=$(_gib_path_run); zle reset-prompt; LBUFFER+="$result " }
zle -N _gib_fzf-gp-widget


# Bind git shortcuts to <c-g><c-$@> (see above functions for more info).
bindkey -r -M viins "^G" # Remove list-expand binding so we can use <C-g> for git.

# More fzf helpers.
_gib_join_lines() { local item; while read -r item; do echo -n "${(q)item} "; done; }
() {
  local c
  for c in "$@"; do
    eval "_gib_fzf-g$c-widget() { git rev-parse HEAD > /dev/null 2>&1 || return; local result=\$(_gib_git_$c | _gib_join_lines); zle reset-prompt; LBUFFER+=\$result }"
    eval "zle -N _gib_fzf-g$c-widget"
    eval "bindkey -M viins '^g^$c' _gib_fzf-g$c-widget"
  done
} f b t r h a # Bind <C-g><C-{f,b,t,r,h,s}> to fuzzy-find show {files,branches,tags,reflog,hashes,stashes}.

autoload -Uz select-word-style
select-word-style shell # "Word" means a shell argument, so Ctrl-w will delete one shell arg.

# More expensive keybindings, with deferred loading. Immediately loaded ones are in zshrc.

bindkey -M vicmd '^Y' gib-yank-all # Ctrl-y copies everything to the system clipboard.

bindkey -M viins "^[[A" history-beginning-search-backward-end # Up: backwards history search.
bindkey -M viins "^[[B" history-beginning-search-forward-end # Down: forwards history search.
bindkey -M viins '^G^P' _gib_fzf-gp-widget # Ctrl-g-p: search all binaries in the $PATH.
bindkey -M viins '^R' gib-fzf-history-widget # Ctrl-r: multi-select for history search.
bindkey -M viins '^Y' gib-yank-all # Ctrl-y: copy everything to the system clipboard.
bindkey -M viins '^[^M' self-insert-unmeta # Alt-Enter: insert a literal enter (newline char).

if [[ -n "${terminfo[kcbt]}" ]]; then
  bindkey "${terminfo[kcbt]}" reverse-menu-complete   # <Shift>-<Tab> - move backwards through the completion menu.
else
  echo "Warning: Variable terminfo[kcbt] wasn't set."
fi

# Run before the prompt is displayed.
_gib_prompt_precmd() {
  # Set window title to current directory.
  title="$(print -Pn "%1~")"
  if [[ $TERM_PROGRAM == iTerm.app ]]; then
    # On kitty this returns `;dot` instead of `dot`.
    printf "\033];%s\007" "${title:0:60}"
  else
    # On iTerm2 this is ignored entirely.
    printf "\e]2;%s\a" "${title:0:60}"
  fi
}

# Run between user hitting Enter key, and command being run.
_gib_prompt_preexec() {
  printf '\e[4 q' # Cursor is an underline (_) while command is running.
  # Set window title to first 40 chars of command we're about to run.
  title="$(print -Pn "%1~") ❯ $1"
  if [[ $TERM_PROGRAM == iTerm.app ]]; then
    printf "\033];%s\007" "${title:0:60}"
  else
    printf "\e]2;%s\a" "${title:0:60}"
  fi
}

autoload -Uz add-zsh-hook

add-zsh-hook precmd _gib_prompt_precmd
add-zsh-hook preexec _gib_prompt_preexec

# }}} Keybindings

# {{{ Initialize Completions

# Initialise completions after everything else.
autoload -Uz compinit
compinit

# }}} Initialize Completions

# vim: foldmethod=marker filetype=zsh tw=100
