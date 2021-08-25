# {{{ Functions

# Edit a file on the system.
e() { locate -i0 "$@" | xargs -0 realpath | sort -u | proximity-sort "$PWD" | fzf --tiebreak=index --print0 | xargs -0 "$=VISUAL"; }

mdc() { command mkdir -p "$@"; { [[ $# == 1 ]] && cd "$1"; } || true; } # Mkdir then cd to dir (`mdc foo` = `mkdir foo && cd foo`).
cpm() { command mkdir -p "${@: -1}" && cp "$@"; } # Mkdir then cp to dir (`cpm foo bar` = `md bar && cp foo bar`).
mvm() { command mkdir -p "${@: -1}" && mv "$@"; } # Mkdir then mv to dir (`mvm foo bar` = `md bar && mv foo bar`).

# Add or move to beginning of path.
pathadd() { [[ -d "$1" ]] && PATH="$1"$(echo ":$PATH:" | sed "s|:$1:|:|" | sed 's|:$||'); }
# Add or move to end of path.
pathapp() { [[ -d "$1" ]] && PATH=$(echo ":$PATH:" | sed "s|:$1:|:|" | sed 's|^:||')"$1"; }

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

add_trailing_newline() {
  fd --hidden --exclude=.git --type f "$@" -x gsed -i -e '$a\' '{}'
}

remove_trailing_whitespace() {
  fd --hidden --exclude=.git --type f "$@" -x gsed -i -e 's/\s\+$//' '{}'
}

tabs_to_spaces() {
  spaces_per_tab=${1:-4}
  fd --hidden --exclude=.git --type f -x bash -c "gexpand -i -t $spaces_per_tab {} | sponge {}"
}

# Get the App Bundle ID of a macOS/iOS/etc app, using an app store link, or an app on the system.
# Useful for adding to 1Password: https://www.reddit.com/r/1Password/comments/hk02p7/suggestions_in_apps_for_1password_for_macos/.
# Refs: StackOverflow (https://stackoverflow.com/questions/27509838/how-to-get-bundle-id-of-ios-app-either-using-ipa-file-or-app-installed-on-iph)
apple_app_bundleid() {
  case $1 in;
    https://*) # Assume URL (Google for the app, copy URL).
      id=${1##*id} # Assumes $1 is a URL like https://apps.apple.com/.../id0000000000
      curl "https://itunes.apple.com/lookup?id=${id}" | jq -r '"app://\(.results[0].bundleId)"'
      ;;
    *) # Assume App Name / Path.
      id=$1
      echo "app://$(osascript -e "id of app \"$1\"")"
      ;;
  esac
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
  local cmd
  cmd="$(fc -lnr -100 | awk '$1 == "rg" || $1 == "rga" {
    out="rg --vimgrep"
    if ($1 == "rga") { out=out" --hidden --no-ignore --glob=!.git" }
    for (i=2; i<=NF; i++) { out=out" "$i }
    print out; exit
  }')"
  [[ -z "$cmd" ]] && { echo "No rg in the last 100 history commands."; return 1; }
  "$=VISUAL" -q <(eval "$cmd")
}

works() { "$1" --version >/dev/null 2>&1; } # Check if command actually works (can get its version).

# }}} Functions

# {{{ Aliases

# Better ls commands (used below in zsh chpwd(), so needs to be above).
exists gls && _gib_ls=(gls) || _gib_ls=(ls)
if $_gib_ls --color=auto >/dev/null 2>&1; then
  _gib_ls+=(--color=auto)
fi
# l->full detail + hidden, la->no detail + hidden, ll->full detail no hidden, md->create dir.
alias ls="${_gib_ls[*]}" l='ls -lAh' la='ls -A' ll='ls -l'
unset _gib_ls

exists gsed && alias sed=gsed

alias md="mkdir -p"
# x->close terminal, g->git, h->history, path->print $PATH,
alias x=exit g=git path='echo $PATH | tr : "\n"' dt="date +%Y-%m-%d"
alias s="TERM=xterm-256color ssh" # Reset cursor to block and ssh.
# Footgun, make sure you only use this for a single command, after that exit the shell.
# e.g. sudo_later; sleep 1000; sudo halt
alias sudo_later="(while sudo -v; do sleep 60; done) &" # Preserve sudo for a command you'll run later (needs TouchID Sudo).
alias bounce="echo -n '\a'" # Ring the terminal bell (bounce the dock icon in macOS).
alias pstree="pstree -g 3" # Use the nicest pstree output (unicode).
# Run command every $1 seconds until it succeeds, e.g. `every 60 curl https://example.com`
every() { local delay=${1?}; shift; while ! "$@"; do sleep $delay; echo "❯ $*"; done; }

alias c=cargo ru=rustup  # Rust commands (try `c b`, `c r`, `c t`).
rs() { for i in "$@"; do rustc "${i%.rs}.rs"; ./"${i%.rs}"; done; } # Compile/run (rs a.rs b).
# .. = up 1 dir, ... = up 2 dirs, .... = up 3 dirs (etc.). - = go to last dir.
# shellcheck disable=SC2139 # We want this to expand when defined.
alias ..="cd .." ...="cd ../.." ....="cd ../../.." .....="cd ../../../.." ......="cd ../../../../.."
# shellcheck disable=SC2139 # We want this to expand when defined.
alias -- -="cd -"
alias next='git next && git show' # Useful for demos.
alias gm='wait; git mf' # After cd'ing into a repo, fetch will run as a background job. Use this to wait for it to finish then mf.

{ exists nvim && _gib_vim="nvim"; } || { exists vim && _gib_vim="vim"; } || _gib_vim="vi" # Take what you can get.
[[ $VISUAL == 'nvr --remote-wait' ]] && _gib_vim=$VISUAL # Allow passing through the neovim init.vim value.
export VISUAL=$_gib_vim EDITOR=$_gib_vim # Set vim/nvim as the default editor.
unset _gib_vim
alias vim='VIMINIT=":source $XDG_CONFIG_HOME/nvim/init.vim" vim' # Make vim use nvim config file.
# shellcheck disable=SC2139 # We want this to expand when defined.
alias xv="xargs $=VISUAL" v="$=VISUAL" # Work around zsh's "helpful" autoquoting.
alias vt='v ~/tmp/drafts/t' # Edit a common scratch file (allows vim history preservation).
alias k=kubectl kx=kubectx kn='kubectl config set-context --current --namespace' # Build tools.
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

# ulimit -c unlimited # Uncomment to allow saving of coredumps.
# Cross-platform copy/paste/open/ldd/delete terminal commands.
case $uname in
  Darwin) alias ldd="otool -L" o=open dl=trash ;;
  Linux) alias o=xdg-open dl="gio trash" ;;
esac
# Copy last command.
alias clc="fc -ln -1 | sed -e 's/\\\\n/\\n/g' -e 's/\\\\t/\\t/g' | ${=aliases[cpy]}"
# Run last command and copy the command and its output.
cr() { local a=$(r 2>&1); ${=aliases[cpy]} <<<"❯ $a"; }

# fda is find all (don't ignore anything).
{ exists fd && alias fda='fd --no-ignore --hidden --exclude=.git'; } \
  || fd() { find . -iname "*$**"; } # Find by filename (case insensitive).
exists rg && alias rg='rg' rga='rg --hidden --no-ignore --glob=!.git' # rga is grep all (don't ignore anything).

# Yaml to json, e.g. "y2j <t.yml | jq .". Requires a `pip install pyyaml`.
alias y2j="python3 -c 'import sys, yaml, json; json.dump(yaml.safe_load(sys.stdin), sys.stdout, indent=2)'"
alias y2y="python3 -c 'import sys, yaml; yaml.dump(yaml.safe_load(sys.stdin), sys.stdout, indent=2)'"
alias t2j="python3 -c 'import sys, toml, json; json.dump(toml.load(sys.stdin), sys.stdout, indent=2)'"
# Url encode and decode stdin or first argument.
alias url_encode='python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1] if len(sys.argv) > 1 else sys.stdin.read()[0:-1]))"'
alias url_decode='python3 -c "import urllib.parse, sys; print(urllib.parse.unquote(sys.argv[1] if len(sys.argv) > 1 else sys.stdin.read()[0:-1]))"'

if exists kitty; then
  alias icat="kitty +kitten icat" # Kitty terminal specific: https://sw.kovidgoyal.net/kitty/kittens/icat.html
fi
alias idea="/Applications/IntelliJ\ IDEA\ CE.app/Contents/MacOS/idea" # IntelliJ CE
alias curl="noglob curl" # Don't match on ? [] etc in curl URLs, avoids needing to quote URL args.

exists ggrep && alias grep='ggrep --color=auto'

# }}} Aliases

chpwd() { # Commands to run after changing directory.
  [[ -t 1 ]] || return # Exit if stdout is not a tty.
  setopt local_options no_monitor # This only disables the "job start", not the "job complete".
  # I know I set the ls alias earlier, so use that.
  ${=aliases[ls]} -A 1>&2 # Show dir contents.
  [[ -d .git ]] && git fetch --all --quiet & # Fetch git remotes.
}
