# Fzf git files (unstaged).
_gib_git_f() {
  git -c color.status=always status --short |
  fzf --height 50% "$@" --border -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' | cut -c4- | sed 's/.* -> //'
}
# Fzf git branches.
_gib_git_b() {
  git branch -a --color=always --sort=committerdate --sort=-refname:rstrip=2 | grep -v '/HEAD\s' |
  fzf --height 50% "$@" --border --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -'$LINES | sed 's/^..//' | cut -d' ' -f1 | sed 's#^remotes/##'
}
# Fzf git tags.
_gib_git_t() {
  git tag --sort -version:refname |
  fzf --height 50% "$@" --border --multi --preview-window right:70% \
    --preview 'git show --color=always {} | head -'$LINES
}
# Fzf git hashes.
_gib_git_h() {
  git log --all --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  fzf --height 50% "$@" --border --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -'$LINES | grep -o "[a-f0-9]\{7,\}"
}
# Fzf git remotes.
_gib_git_r() {
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  fzf --height 50% "$@" --border --tac \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1} | head -200' |
  cut -d$'\t' -f1
}
# More fzf helpers.
_gib_join-lines() { local item; while read item; do echo -n "${(q)item} "; done; }
bind-git-helper() {
  local c
  for c in $@; do
    eval "_gib_fzf-g$c-widget() { git rev-parse HEAD > /dev/null 2>&1 || return; local result=\$(_gib_git_$c | _gib_join-lines); zle reset-prompt; LBUFFER+=\$result }"
    eval "zle -N _gib_fzf-g$c-widget"
    eval "bindkey -M viins '^g^$c' _gib_fzf-g$c-widget"
  done
}

zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} r:|[.,_-]=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # Use LS_COLORS in file completion menu.
zstyle ':completion:*:*:*:*:*' menu "select" # Make the completion selection menu a proper menu.

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path "$XDG_CACHE_HOME"/zsh

autoload -U compinit
# TODO(gib): Work out why this is slow on Darwin and fix it.
[ "$ssh" -a "$uname" = Darwin ] || compinit -d "$XDG_CACHE_HOME"/zsh/.zcompdump$(hostname)
zstyle ':bracketed-paste-magic' active-widgets '.self-*' # https://github.com/zsh-users/zsh-autosuggestions/issues/141

# Vim mode and keybindings in zsh:
autoload -U history-search-end # Not included by default so load (usually /usr/share/zsh/unctions/Zle/).
autoload -Uz edit-command-line # Load command to open current line in $VISUAL.
zle -N edit-command-line
zle -N history-beginning-search-backward-end history-search-end # Add it to existing widgets.
zle -N history-beginning-search-forward-end history-search-end  # Add it to existing widgets.
accept-line() { [ -z "$BUFFER" ] && zle up-history; zle ".$WIDGET"; }
zle-keymap-select () { [ $KEYMAP = vicmd ] && printf "\033[2 q" || printf "\033[6 q"; } # Other KEYMAPs are main and viins.
zle-line-init () { zle -K viins; printf "\033[6 q"; }
zle -N accept-line # Redefine accept-line to insert last input if empty (Enter key).
zle -N zle-keymap-select # I-beam cursor in insert mode, block otherwise.
zle -N zle-line-init     # Part of above cursor hack ^.
KEYTIMEOUT=10 # Key delay of 0.1s (Esc in vim mode is quicker).

bindkey -v # Enable vim mode in zsh.

bindkey -M viins "^?" backward-delete-char # Make backspace work properly.
bindkey -M viins "^H" backward-delete-char # <Ctrl>-H = Backspace (Emacs default).
bindkey -M viins "^W" backward-kill-word # <Ctrl>-W = Delete word (Emacs default).
bindkey -M viins "^U" backward-kill-line # <Ctrl>-U = Delete line (Emacs default).
bindkey -M viins "^A" beginning-of-line # <Ctrl>-A = Go to beginning of line (Emacs default).
bindkey -M viins "^E" end-of-line       # <Ctrl>-E = Go to end of line (Emacs default).
bindkey -M viins "^R" history-incremental-search-backward # Restore <Ctrl>-R search.
bindkey -M viins "^S" history-incremental-search-forward  # Restore <Ctrl>-S forward search.
bindkey -M main "^[[A" history-beginning-search-backward-end # Re-enable up   for history search.
bindkey -M main "^[[B" history-beginning-search-forward-end  # Re-enable down for history search.
bindkey ' ' magic-space # <Space> = do history expansion
bindkey "${terminfo[kcbt]}" reverse-menu-complete   # <Shift>-<Tab> - move backwards through the completion menu.
bindkey -M vicmd ' ' edit-command-line # <Space> in cmd mode opens editor.

# Bind git shortcuts to <c-g><c-$@> (see above functions for more info).
bindkey -r -M viins "^G" # Remove list-expand binding so we can use <C-g> for git.
bind-git-helper f b t r h # Bind <C-g><C-{f,b,t,r,h}> to fuzzy-find show {files,branches,tags,remotes,hashes}.
unset -f bind-git-helper
