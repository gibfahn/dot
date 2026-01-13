# {{{ Environment Variables

export ATOM_HOME="$XDG_DATA_HOME"/atom # Atom data goes here.
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME/aws/config"
export AWS_SHARED_CREDENTIALS_FILE="$HOME/.ssh/tokens/aws/credentials"
export BABEL_CACHE_PATH=${BABEL_CACHE_PATH="$XDG_CACHE_HOME/babel/cache.json"} # Set babel cache location.
export BAT_THEME="TwoDark" # Set the default theme for bat and delta.
export CCACHE_CONFIGPATH="$XDG_CONFIG_HOME"/ccache.config
export CCACHE_DIR="$XDG_CACHE_HOME"/ccache # Ccache cache.
export FZF_ALT_C_COMMAND='fd --type d --hidden --no-ignore --follow --exclude .git'
export FZF_CTRL_R_OPTS="--height=100% --preview-window=down:30%:noborder --preview 'file-preview - --language=zsh -- <<<\$(echo {2..})', --bind='ctrl-y:execute(${aliases[cpy]} <<< {2..})'"
export FZF_CTRL_T_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_OPTS="--height=100% --preview-window=right:60%:noborder"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git' # Use fd for fuzzy finding if available.
export GNUPGHOME="$XDG_DATA_HOME"/gnupg # Gpg data.
export GRADLE_USER_HOME="$XDG_DATA_HOME"/gradle # Also contains gradle.properties (symlink from XDG_CONFIG_HOME).
export HELM_HOME="$XDG_DATA_HOME/helm" # Move Helm data dir from ~.
export HTTPIE_CONFIG_DIR="$XDG_CONFIG_HOME/httpie" # https://github.com/jakubroztocil/httpie/issues/145
export IPYTHONDIR="$XDG_CACHE_HOME/ipython" # Move iPython dir from ~.
export LESSHISTFILE="$XDG_CACHE_HOME/less/history" # Get less to put its history here.
export LESSKEY="$XDG_CACHE_HOME/less" # Less color settings.
export MINIKUBE_HOME="$XDG_CACHE_HOME/minikube" # https://github.com/kubernetes/minikube/issues/4109
export NCURSES_NO_UTF8_ACS=1 # Force UTF-8 in ncurses https://github.com/kovidgoyal/kitty/issues/7005#issuecomment-1945441687
export NODE_REPL_HISTORY="$XDG_CACHE_HOME/node_repl_history" # Set node-gyp download location.
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm" # Set npm cache location.
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/config" # Set up my npm config location.
export OP_BIOMETRIC_UNLOCK_ENABLED=true # https://developer.1password.com/docs/cli/app-integration/#set-the-biometric-unlock-environment-variable
export PAGER=less
export PEX_ROOT="$XDG_CACHE_HOME/pex" # Cache directory for https://github.com/pantsbuild/pex.
export RBENV_ROOT="$XDG_CACHE_HOME/rbenv" # Set rbenv location.
export RUSTUP_HOME="$XDG_DATA_HOME/rustup" # Rustup goes here.
export SCCACHE_DIR="$XDG_CACHE_HOME/sccache" # sccache cache dir.
export TIME_STYLE=long-iso # See `man gls` on macOS, sets the time style for `ls -l`.
export VIRTUAL_ENV_DISABLE_PROMPT=1 # Add the virtualenv prompt myself.

# Mappings:
# alt-s: sneak to line
# alt-shift-s: sneak to line + enter
# ctrl-y: copy line
export FZF_DEFAULT_OPTS="--select-1 --exit-0 --preview-window=right:50% --preview 'file-preview {}' -m \
--bind='\
alt-S:jump-accept,\
alt-down:half-page-down,\
alt-o:execute(open {}),\
alt-s:jump,\
alt-up:half-page-up,\
alt-w:toggle-preview-wrap,\
ctrl-a:toggle-all,\
ctrl-o:execute(\$VISUAL {} </dev/tty >/dev/tty),\
ctrl-p:toggle-preview,\
ctrl-s:toggle-sort,\
ctrl-y:execute(${aliases[cpy]} <<< {})\
'"

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
(( $+commands[rg] )) && alias rg='rg --smart-case' && alias rga='rg --smart-case --hidden --no-ignore --glob=!.git' # rga is grep all (don't ignore anything).
# Footgun, means your shell has sudo privileges forever, make sure you only use this for a single command, after that exit the shell.
# e.g. sudo_later; sleep 1000; sudo halt
alias sudo_later="sudo -v; (while sudo -v; do sleep 60; done) &" # Preserve sudo for a command you'll run later.
alias bounce="echo -n '\a'" # Ring the terminal bell (bounce the dock icon in macOS).
alias pstree="pstree -g 3" # Use the nicest pstree output (unicode).

alias c=cargo # Rust commands (try `c b`, `c r`, `c t`).
alias ru=rustup
alias gm='wait; git mf' # After cd'ing into a repo, fetch will run as a background job. Use this to wait for it to finish then mf.
alias we="watchexec" # Shortcut for "run this command when something changes".

alias mv="mv -v" # Print out what copies we're doing.
alias cp="cp -v" # Print out what moves we're doing.
alias rm="rm -v" # Print out what deletes we're doing.

# Copy last command.
alias clc="fc -ln -1 | sed -e 's/\\\\n/\\n/g' -e 's/\\\\t/\\t/g' | ${=aliases[cpy]}" # "
# Run last command and copy the command and its output.
cr() { local a=$(r 2>&1); ${=aliases[cpy]} <<<"❯ $a"; }

# Convert between config formats, e.g. "yaml_to_json t.yml | jq ."
alias csv_to_json="python3 -c 'import csv, json, sys; json.dump([row for row in csv.reader(sys.stdin)], sys.stdout, indent=2)'"
alias json_to_yaml="uv run --with pyyaml - <<<'import pathlib, sys, yaml, json; yaml.dump(json.loads(pathlib.Path(sys.argv[1]).read_text()), sys.stdout, indent=2)'"
alias toml_to_json="uv run --with toml - <<<'import pathlib, sys, toml, json; json.dump(toml.loads(pathlib.Path(sys.argv[1]).read_text()), sys.stdout, indent=2)'"
alias yaml_to_json="uv run --with pyyaml - <<<'import pathlib, sys, yaml, json; json.dump(yaml.safe_load(pathlib.Path(sys.argv[1]).read_text()), sys.stdout, indent=2)'"
alias yaml_to_yaml="uv run --with pyyaml - <<<'import pathlib, sys, yaml; yaml.dump(yaml.safe_load(pathlib.Path(sys.argv[1]).read_text()), sys.stdout, indent=2)'"
# Markdown to html (rich text).
alias markdown_to_html="pbpaste | pandoc --from markdown-smart --to html | textutil -convert rtf -stdin -stdout -format html | pbcopy -Prefer rtf"
# Url encode and decode stdin or first argument.
alias url_encode='python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1] if len(sys.argv) > 1 else sys.stdin.read().rstrip(\"\n\")))"'
alias url_decode='python3 -c "import urllib.parse, sys; print(urllib.parse.unquote(sys.argv[1] if len(sys.argv) > 1 else sys.stdin.read().rstrip(\"\n\")))"'
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

# Add a trailing newline to all files in the current directory.
add_trailing_newline() {
  fd --hidden --exclude=.git --type f "$@" -x gsed -i -e '$a\' '{}'
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

chpwd() { # Commands to run after changing directory (via cd or pushd).
  [[ -t 1 ]] || return # Exit if stdout is not a tty.
  setopt local_options no_monitor # This only disables the "job start", not the "job complete".
  # I know I set the ls alias earlier, so use that.
  ${=aliases[ls]} -A 1>&2 # Show dir contents.
  [[ -d .git ]] && git fetch --all --quiet & # Fetch git remotes.
  # Add new entries to the zoxide database.
  # Anything started with /Volumes/Shared-Data/ is a shared mount, see scripts/run/mac_volume
  zoxide add -- "${PWD#/Volumes/Shared-Data}"
}

# Save the current clipboard to a png file, copy the path to the clipboard, and show the file
# in Finder. This allows you to easily drag the file, or paste it with a ⇧⌘g in a file
# picker window.
clipboard_image_save() {
  local screenshot_path
  screenshot_path=$HOME/tmp/screen_shot_recording/screenshot_$(date "+%Y-%m-%d_%H-%M-%S").png
  osascript -e "set png_data to the clipboard as «class PNGf»
	set the_file to open for access POSIX path of (POSIX file \"$screenshot_path\") with write permission
	write png_data to the_file
	close access the_file"

  echo "Created $screenshot_path"
  pbcopy <<<$screenshot_path
  # Reveal in Finder.
  open -R $screenshot_path
}

cpm() { command mkdir -p "${@: -1}" && cp "$@"; } # Mkdir then cp to dir (`cpm foo bar` = `md bar && cp foo bar`).

# Interactive move to trash..
# dli -> interactive delete files in current directory.
# dli foo/* bar/* -> interactive delete files in foo and bar subdirectories.
dli() {
  { [[ $# == 0 ]] && fd -0d 1 || print -N $@; } | fzf --reverse --read0 --print0 | xargs -0 ${=aliases[dl]}
}

# Get docker labels from an image tag or @sha256: digest.
# Usage:
#   $0 [registry]/<org>/<repo>@sha256:<sha>
# docker_labels gibfahn/myimage:latest
# docker_labels docker.io/rust@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
docker_labels() {
  skopeo inspect --override-os=linux docker://${1?1st argument should be a docker image} | jq '.Labels'
}

# Get docker sha256 repo digest (not the image ID) from an image tag.
# docker_sha gibfahn/myimage:latest
docker_sha() {
  skopeo inspect --override-os=linux docker://${1?1st argument should be a docker image} | jq -r '.Digest' | sed 's/^sha256://'
}

# Run command every $1 seconds until it succeeds, e.g. `every 60 curl https://example.com`
every() { local delay=${1?}; shift; while ! "$@"; do sleep $delay; echo "❯ $*"; done; }

# Clone repo and cd into path (can't be in git config as we cd).
# By default will clone into a subdirectory, e.g.
# ssh://git@foo.com/~gibson_n_fahnestock/bar-baz.git -> foo.com/gibson_n_fahnestock/bar-baz/
# https://github.com/gibfahn/dot -> github.com/gibfahn/dot/
gcl() {
  local clone_dir ret args
  local magenta='\033[0;35m' nc='\033[0m'
  args=("$@")

  # If no directory specified, use a subdir following the URL path.
  # If we're in the home directory, guess the right subdir. Else clone into a subdir of the current
  # directory.
  if [[ $# == 1 ]]; then
    local url=$1 root_dir=$PWD
    url=$(git parse-url --segment url $url)
    subdir=$(git parse-url --segment host-org-repo $url)

    root_dir=~/code

    dir=$root_dir/$subdir

    if [[ -d "$dir" ]]; then
      echo >&2 "${magenta}gcl:${nc} Directory already exists, changing to $dir"
      cd "$dir"
      return 0
    fi

    args=("$url" "$dir")
  fi

  clone_dir="$(set -o pipefail; git cl --progress "${args[@]}" 3>&1 1>&2 2>&3 3>&- | tee /dev/stderr | awk -F \' '/Cloning into/ {print $2}' | head -1)"
  ret="$?"
  [[ -d "$clone_dir" ]] && echo "cd $clone_dir" && cd "$clone_dir" || return 1
  return $ret
}

# Set up things I commonly need when sshing into a machine.
ssh_setup() {
  # Login keychain is locked when you ssh in until you unlock it.
  # This prompts for auth.
  security unlock-keychain ~/Library/Keychains/login.keychain
}

# Show which apps made a noise in the last 30 minutes.
# Refs:
# - <https://dreness.com/blog/archives/155773>
# - <https://gist.github.com/dreness/1de1def13c83d19630ab0646ba8f0597>
mac_recent_audio_notifications() {
  log show --info --last 30m --predicate 'senderImagePath = "/usr/sbin/systemsoundserverd"' --style compact | awk '/Incoming Request/ {print $1 ":" $2 " " $14}'
}

# Edit a file on the system.
mdc() { command mkdir -p "$@"; { [[ $# == 1 ]] && cd "$1"; } || true; } # Mkdir then cd to dir (`mdc foo` = `mkdir foo && cd foo`).
mvm() { command mkdir -p "${@: -1}" && mv "$@"; } # Mkdir then mv to dir (`mvm foo bar` = `md bar && mv foo bar`).

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

# Generate an alphanumeric password $1 characters long.
password_gen() {
  head -c $(($1 * 10)) /dev/urandom | LC_ALL=C tr -dc '[:alnum:]' | LC_ALL=C tr -sc '[:alnum:]' | fold -w ${1?Missing argument 1: password length} | head -1 | tr -d '\n'
}

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

# Remove trailing whitespace from all files in the current directory.
remove_trailing_whitespace() {
  fd --hidden --exclude=.git --type f "$@" -x gsed -i -e 's/\s\+$//' '{}'
}

rs() { for i in "$@"; do rustc "${i%.rs}.rs"; ./"${i%.rs}"; done; } # Compile/run (rs a.rs b).

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

# Convert tabs to spaces for all files in the current directory.
# $1: spaces per tab, defaults to 4.
tabs_to_spaces() {
  spaces_per_tab=${1:-4}
  fd --hidden --exclude=.git --type f -x bash -c "gexpand -i -t $spaces_per_tab {} | sponge {}"
}

# Generate a URL with a text fragment link.
# <https://developer.mozilla.org/en-US/docs/Web/Text_fragments>
# Args:
#   $1: base URL
#   $2: plain text (unencoded).
# URL will be sent to stdout and copied.
url_text_fragment() {
  local url
  url="${1}#:~:text=$(url_encode "$2")"
  cpy <<<$url
  echo $url
}

# vim quickfix: copy a set of file:line lines then run to populate the quickfix list.
vq() {
  ${=aliases[v]} +copen +"cexpr(getreg('+'))"
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

# }}} Functions

# {{{ Run commands

command mkdir -p ${HISTFILE:h} # Create HISTFILE dir if necessary.

# ulimit -c unlimited # Uncomment to allow saving of coredumps.

# Set key repeat rate if available (Linux only). Something less excessive would be `rate 250 30`.
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
source <(fzf --zsh) # # Set up fzf key bindings and fuzzy completion for the fzf version we're using.
source $XDG_DATA_HOME/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source $XDG_DATA_HOME/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $XDG_DATA_HOME/zsh/plugins/zsh-completions/zsh-completions.plugin.zsh

# Source completions that need to be directly run.
for _gib_file in $XDG_DATA_HOME/zsh/completions/*(N); do
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

# Fzf git branches (returns local branch name, not remote one).
_gib_git_b() {
  git branch -a --color=always --sort=committerdate --sort=-refname:rstrip=2 \
  | fzf "$@" --border --ansi --multi --tac --preview-window right:70% \
  --preview "git l --color=always \$(awk '{if (\$1 == \"*\") { print \$2 } else { print \$1 } }' <<< {})" \
  --bind "ctrl-o:execute: git li \$(awk '{if (\$1 == \"*\") { print \$2 } else { print \$1 } }' <<< {})" \
  | awk '{if ($1 == "*") { print $2 } else { print $1 } }' | sed -E 's#^remotes/[^/]+/##'
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

# Fzf run gib command: interactively decide what function or alias to run.
# Greps through my functions and aliases, and uses fzf to allow choosing and previewing.
# Requires one `alias` command per alias.
_gib_func_alias_run() {
  local _gib_zsh_files=(~/.config/zsh/.zshrc ~/.config/zsh/deferred/*.zsh)
  rg --vimgrep \
    --only-matching \
    -e '\b(?<fnname>[a-zA-Z][a-zA-Z0-9_:-]+)\(\) \{' \
    -e '\balias (?:-- )?(?<aliasname>[a-zA-Z0-9_:-]+)=' \
    --replace '${fnname}${aliasname}' \
    "${_gib_zsh_files[@]}" \
    | sort \
    | fzf -d : --with-nth=4 \
      --preview 'fzf-bat-preview {1} {2}' \
    | cut -d : -f 4
}

# Fzf with multi-select from https://github.com/junegunn/fzf/pull/2098
# CTRL-R - Paste the selected command from history into the command line
# Supports pasting multiple items.
gib-fzf-history-widget() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases noglob nobash_rematch 2> /dev/null
  # Ensure the module is loaded if not already, and the required features, such
  # as the associative 'history' array, which maps event numbers to full history
  # lines, are set. Also, make sure Perl is installed for multi-line output.
  if zmodload -F zsh/parameter p:{commands,history} 2>/dev/null && (( ${+commands[perl]} )); then
    # Read history line numbers (split on newline) into selected array.
    selected=("${(@f)$(printf '%s\t%s\000' "${(kv)history[@]}" |
      perl -0 -ne 'if (!$seen{(/^\s*[0-9]+\**\t(.*)/s, $1)}++) { s/\n/\n\t/g; print; }' |
      FZF_DEFAULT_OPTS=$(__fzf_defaults "" "-n2..,.. --scheme=history --bind=ctrl-r:toggle-sort --wrap-sign '\t↳ ' --highlight-line ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} -m --read0") \
      FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd) --print0 | perl -0 -l012 -ne 'print((split("\t", $_))[0])')}")
  else
    selected=("${(@f)$(fc -rl 1 | awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\**[ \t]+/, "", cmd); if (!seen[cmd]++) print $0 }' |
      FZF_DEFAULT_OPTS=$(__fzf_defaults "" "-n2..,.. --scheme=history --bind=ctrl-r:toggle-sort --wrap-sign '\t↳ ' --highlight-line ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} -m") \
      FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd) --print0 | perl -0 -l012 -ne 'print((split("\t", $_))[0])')}")
  fi
  local ret=$?
  if [[ "${#selected[@]}" -ne 0 ]]; then
    local -a history_lines=()
    for num in "${selected[@]}"; do
      # Add history at line $num to history_lines array.
      zle vi-fetch-history -n $num
      history_lines+=("$BUFFER")
      BUFFER=
    done
    # Set input buffer to newline-separated list of history lines.
    BUFFER="${(F)history_lines}"
    # Move cursor to end of buffer.
    CURSOR=$#BUFFER
  fi
  zle reset-prompt
  return $ret
}
zle -N gib-fzf-history-widget

# " Fake quote for syntax highlighting plugin issue.

# Copy whole buffer to system clipboard, or if nothing in buffer copy current $PWD.
gib-yank-all() {
  if [[ -z "$BUFFER" ]]; then
    printf "%s" "$PWD" | "${aliases[cpy]}"
  else
    printf "%s" "$BUFFER" | "${aliases[cpy]}"
  fi
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

# Bind ^g^g to "interactively choose which function or alias to run.
_gib_fzf-gibfuncalias-widget() { local result=$(_gib_func_alias_run); zle reset-prompt; LBUFFER+="$result " }
zle -N _gib_fzf-gibfuncalias-widget

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

# Clipboard multiple entry combiner.
# <https://github.com/p0deje/Maccy/issues/239>
gib-combine-clipboard() {
  sqlite3 "$HOME/Library/Containers/org.p0deje.Maccy/Data/Library/Application Support/Maccy/Storage.sqlite" \
    "SELECT ZVALUE FROM ZHISTORYITEMCONTENT WHERE ZTYPE = 'public.utf8-plain-text' ORDER BY Z_PK DESC;" \
    | sed '/^$/d' | uniq | fzf --layout=reverse | pbcopy
}
zle -N gib-combine-clipboard

autoload -Uz select-word-style
select-word-style shell # "Word" means a shell argument, so Ctrl-w will delete one shell arg.

# More expensive keybindings, with deferred loading. Immediately loaded ones are in zshrc.

bindkey -M vicmd '^Y' gib-yank-all # Ctrl-y copies everything to the system clipboard.
bindkey -M viins "^[[A" history-beginning-search-backward-end # Up: backwards history search.
bindkey -M viins "^[[B" history-beginning-search-forward-end # Down: forwards history search.
bindkey -M viins '\em' gib-combine-clipboard # Alt-m combines clipboard history using Maccy.
bindkey -M viins '^G^G' _gib_fzf-gibfuncalias-widget # Ctrl-g-g: list my own functions and aliases.
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
  local title
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
  local title
  printf '\e[4 q' # Cursor is an underline (_) while command is running.
  # Set window title to first 40 chars of command we're about to run.
  # Do the following replacements:
  # - replace newline with `; `
  # - remove `\;`
  # - remove whitespace at start and end of line
  title="$(print -Pn "%1~") ❯ $(sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/; /g' -e 's/\\;//g' -e 's/; $//' <<<$1)"
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
